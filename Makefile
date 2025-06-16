# include .envrc
include .env

# Define variables for GOOS and GOARCH
GOOS ?= linux
GOARCH ?= amd64

# ==================================================================================== #
# HELPERS
# ==================================================================================== #

## help: print this help message
.PHONY: help
help:
	@echo 'Usage:'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' |  sed -e 's/^/ /'

.PHONY: confirm
confirm:
	@echo -n 'Are you sure? [y/N] ' && read ans && [ $${ans:-N} = y ]

# ==================================================================================== #
# DEVELOPMENT
# ==================================================================================== #

## with/fresh: run the application with fresh
.PHONY: with/fresh
with/fresh:
	# IS NOT LOADING
	# export $(grep -v '^#' ./.env | xargs)
	rm -rf ./tmp
	fresh -c ./scripts/other_runner.conf

## run/api: run the cmd/api application
# .PHONY: run/api
# run/api:
# 	go run ./cmd/api -db-dsn=${GREENLIGHT_DB_DSN}

## db/fresh/local: drop and recreate the database
.PHONY: db/fresh/local
db/fresh/local:
	psql ${POSTGRESQL_DB_DSN} --set password=${DB_PASSWORD} --no-psqlrc -f ./queries_postgresql/snippets_web.sql
	@echo 'Running up migrations ...'
	# rm -rf ./migrations
	# cp -R ./migrations_postgresql ./migrations
	migrate -path ./migrations -database ${SNIPPETS_WEB_DB_DSN} up
	# go run ./cmd/api/ -db-dsn=${SNIPPETS_WEB_DB_DSN} -seed=true
	psql ${SNIPPETS_WEB_DB_DSN} --no-psqlrc -f ./queries_postgresql/snippets_web_records.sql

## db/psql: connect to the database using psql
.PHONY: db/psql
db/psql:
	psql ${SNIPPETS_WEB_DB_DSN}

## db/dump: dump the database using psql
.PHONY: db/dump
db/dump:
	# pg_dump --clean --if-exists --quote-all-identifiers -h $HOST -U $USER -d $DATABASE --no-owner --no-privileges > dump.sql
	pg_dump ${SNIPPETS_WEB_DB_DSN} --clean --if-exists --quote-all-identifiers --no-owner --no-privileges > ./dump.sql

## db/export_to_supabase: export the database to supabase
.PHONY: db/export_to_supabase
db/export_to_supabase:
	# https://supabase.com/docs/guides/platform/migrating-to-supabase/postgres?queryGroups=migrate-method&migrate-method=cli
	rm ./dump.sql
	pg_dump ${SNIPPETS_WEB_DB_DSN} --clean --if-exists --quote-all-identifiers --no-owner --no-privileges > ./dump.sql
	# pg_dump ${SNIPPETS_WEB_DB_DSN} --clean --if-exists --quote-all-identifiers --no-owner --no-privileges --schema=PATTERN > ./dump.sql
	# psql -d "$YOUR_CONNECTION_STRING" -f dump.sql
	# psql -d ${SUPABASE_DIRECT_CONNECTION_STRING} -f ./dump.sql # psql -d ${SUPABASE_TRANSACTION_POOLER_STRING} -f ./dump.sql
	psql -d ${SUPABASE_SESSION_POOLER_STRING} -f ./dump.sql

## db/migrations/new name=$1: create a new database migration
.PHONY: db/migrations/new
db/migrations/new:
	@echo 'Creating migration files for ${name}...'
	migrate create -seq -ext=.sql -dir=./migrations ${name}

## db/migrations/up: apply all up database migrations
.PHONY: db/migrations/up
db/migrations/up: confirm
	@echo 'Running up migrations...'
	migrate -path ./migrations -database ${SNIPPETS_WEB_DB_DSN} up

.PHONY: sqlc_generate_sqlite
sqlc_generate_sqlite:
	rm -rf ./migrations
	cp -R ./migrations_sqlite ./migrations
	# migrate -path ./migrations -database ${} down
	# migrate -path ./migrations -database ${} up
	rm -rf ./repository
	mkdir ./repository
	sqlc generate

# ==================================================================================== #
# QUALITY CONTROL
# ==================================================================================== #

## tidy: format all .go files, and tidy and vendor module dependencies
.PHONY: tidy
tidy:
	@echo 'Formatting .go files...'
	go fmt ./...
	@echo 'Tidying module dependencies...'
	go mod tidy
	@echo 'Verifying and vendoring module dependencies...'
	go mod verify
	# go mod vendor

## audit: run quality control checks
.PHONY: audit
audit:
	go install honnef.co/go/tools/cmd/staticcheck@latest
	@echo 'Checking module dependencies'
	go mod tidy -diff
	go mod verify
	@echo 'Vetting code...'
	go vet ./...
	staticcheck ./...
	@echo 'Running tests...'
	go test -race -vet=off ./...

# ==================================================================================== #
# BUILD
# ==================================================================================== #

## build/web: build the cmd/web application
.PHONY: build/web
build/web:
	# go clean -cache
	# go clean -modcache
	@echo 'Building cmd/web ...'
	rm -rf ./bin
	mkdir ./bin
	go build -ldflags="-s -w" -o=./bin/web ./cmd/web
	GOOS=$(GOOS) GOARCH=$(GOARCH) go build -ldflags="-s -w" -o=./bin/$(GOOS)_$(GOARCH)/web ./cmd/web

## build/web/in-gitlab: build the cmd/web application in gitlab
.PHONY: build/web/in-gitlab
build/web/in-gitlab:
	# go clean -cache
	# go clean -modcache
	@echo 'Building cmd/web in gitlab ...'
	rm -rf ./mybinaries
	mkdir ./mybinaries
	go build -ldflags="-s -w" -o=./mybinaries/web ./cmd/web
	GOOS=$(GOOS) GOARCH=$(GOARCH) go build -ldflags="-s -w" -o=./mybinaries/$(GOOS)_$(GOARCH)/web ./cmd/web

# ==================================================================================== #
# PRODUCTION
# ==================================================================================== #

aws_key = "~/.ssh/ED25519-i-03bf3e399564b8523.pem"
aws_user = "ubuntu"
aws_ip = "ec2-44-204-169-221.compute-1.amazonaws.com"

## production/connect: connect to the production server
.PHONY: production/connect
production/connect:
	ssh -o IdentitiesOnly=yes -i ${aws_key} ${aws_user}@${aws_ip}

## aws/deploy: deploy the api to aws
.PHONY: aws/deploy
aws/deploy:
	scp -o IdentitiesOnly=yes -i ${aws_key} ./.env ./bin/linux_amd64/web ./remote/aws/web_app.service ./remote/aws/Caddyfile ${aws_user}@${aws_ip}:/home/ubuntu/coding/deploys/web_app/
	ssh -t -o IdentitiesOnly=yes -i ${aws_key} ${aws_user}@${aws_ip} '\
		echo `date '+%d/%m/%Y_%H:%M:%S'` > ~/deploy \
		&& echo "web app" >> ~/deploy \
		&& sudo systemctl stop web_app \
		&& sudo systemctl stop caddy \
		&& sudo cp ~/coding/deploys/web_app/web_app.service /etc/systemd/system/ \
		&& sudo systemctl enable web_app \
		&& sudo systemctl restart web_app \
		&& sudo cp ~/coding/deploys/web_app/Caddyfile /etc/caddy/ \
		&& sudo systemctl restart caddy \
		&& sudo systemctl reload caddy \
	'
