# include .envrc
include .env

# Define variables for GOOS and GOARCH
GOOS ?= linux
GOARCH ?= amd64

# ================================================================================= #
# HELPERS
# ================================================================================= #

## help: print this help message
.PHONY: help
help:
	@echo 'Usage:'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' |  sed -e 's/^/ /'

.PHONY: confirm
confirm:
	@echo -n 'Are you sure? [y/N] ' && read ans && [ $${ans:-N} = y ]

.PHONY: set-deployenv
set-deployenv:
ifneq ($(deployenv),production)
ifneq ($(deployenv),development)
	@echo "Error: deployenv must be either 'production' or 'development'"
	@exit 1
endif
endif
	sed -i 's/^APP_ENV=.*/APP_ENV=$(deployenv)/' ./.env
	@echo "environment set to $(deployenv)"
# make set-deployenv deployenv=production

# ================================================================================= #
# DEVELOPMENT
# ================================================================================= #

## with/fresh: run the application with fresh
.PHONY: with/fresh
with/fresh:
	# export $(grep -v '^#' ./.env | xargs) IS NOT LOADING
	rm -rf ./tmp
	fresh -c ./scripts/other_runner.conf

## db/fresh/local: drop and recreate the database
.PHONY: db/fresh/local
db/fresh/local:
	echo ${POSTGRESQL_DB_DSN}
	echo ${LOCAL_DB_DSN}
	# psql ${POSTGRESQL_DB_DSN} -v password=123456 -f ./queries_postgresql/local_db.sql
	psql ${POSTGRESQL_DB_DSN} --set password=${DB_PASSWORD} --no-psqlrc -f ./queries_postgresql/local_db.sql

## db/seed/schema: seed the database with initial data for schema snippets
.PHONY: db/seed/schema
db/seed/schema:
	@echo 'Running up migrations ...'
	# rm -rf ./migrations
	# cp -R ./migrations_postgresql ./migrations
	migrate -path ./migrations -database ${LOCAL_DB_DSN} up
	# go run ./cmd/api/ -db-dsn=${LOCAL_DB_DSN} -seed=true
	psql ${LOCAL_DB_DSN} --no-psqlrc -f ./queries_postgresql/snippets_web_records.sql

## db/psql: connect to the database using psql
.PHONY: db/psql
db/psql:
	psql ${LOCAL_DB_DSN}

## db/dump: dump the database using psql
.PHONY: db/dump
db/dump:
	# pg_dump --clean --if-exists --quote-all-identifiers -h $HOST -U $USER -d $DATABASE --no-owner --no-privileges > dump.sql
	pg_dump ${LOCAL_DB_DSN} --clean --if-exists --quote-all-identifiers --no-owner --no-privileges > ./dump.sql

## db/export_to_supabase: export the database to supabase
.PHONY: db/export_to_supabase
db/export_to_supabase:
	# https://supabase.com/dashboard/project/towfalbwwquceqrzzpgg?showConnect=true
	# https://supabase.com/docs/guides/platform/migrating-to-supabase/postgres?queryGroups=migrate-method&migrate-method=cli
	rm ./dump.sql
	# pg_dump ${SNIPPETS_WEB_DB_DSN} --clean --if-exists --quote-all-identifiers --no-owner --no-privileges --schema=PATTERN > ./dump.sql
	pg_dump ${LOCAL_DB_DSN} --clean --if-exists --quote-all-identifiers --no-owner --no-privileges > ./dump.sql
	psql ${SUPABASE_SESSION_POOLER_STRING} -f ./queries_postgresql/supabase_db.sql
	# psql -d ${SUPABASE_DIRECT_CONNECTION_STRING} -f ./dump.sql
	# psql -d ${SUPABASE_TRANSACTION_POOLER_STRING} -f ./dump.sql
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
	migrate -path ./migrations -database ${LOCAL_DB_DSN} up

# .PHONY: sqlc_generate_sqlite
# sqlc_generate_sqlite:
# 	rm -rf ./migrations
# 	cp -R ./migrations_sqlite ./migrations
# 	migrate -path ./migrations -database ${} down
# 	migrate -path ./migrations -database ${} up
# 	rm -rf ./repository
# 	mkdir ./repository
# 	sqlc generate

# ================================================================================= #
# QUALITY CONTROL
# ================================================================================= #

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

# ================================================================================= #
# BUILD
# ================================================================================= #

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

# ================================================================================= #
# LOCAL
# ================================================================================= #

## local/deploy: deploy the api to local
.PHONY: local/deploy
local/deploy: build/web
	@APP_ENV_VALUE=$$(awk -F= '/^APP_ENV=/ {print $$2}' ./.env); \
	echo `date '+%d/%m/%Y_%H:%M:%S'` > ${DEPLOY_PATH}/deploy \
	&& echo "web app $$APP_ENV_VALUE" >> ${DEPLOY_PATH}/deploy \
	&& sudo systemctl stop web_app \
	&& cp ./.env ${DEPLOY_PATH}/ \
	&& rm -rf ${DEPLOY_PATH}/tls \
	&& cp -R ./tls/ ${DEPLOY_PATH}/ \
	&& cp ./bin/linux_amd64/web ${DEPLOY_PATH}/ \
	&& sudo cp ./remote/local/web_app.service /etc/systemd/system/ \
	&& sudo cp ./remote/local/Caddyfile /etc/caddy/ \
	&& sudo systemctl enable web_app \
	&& sudo systemctl restart web_app \
	&& cat ${DEPLOY_PATH}/deploy
	# && echo "web app" >> ~/coding/golang_code/deploys/web_app/deploy \
	# && sed -i 's/^APP_ENV=.*/APP_ENV=production/' ./.env \
	# && sudo systemctl stop caddy \
	# && sudo systemctl restart web_app \
	# && sudo systemctl restart caddy \
	# && sudo systemctl reload caddy

# ================================================================================= #
# PRODUCTION
# ================================================================================= #

aws_ip = "ec2-44-204-169-221.compute-1.amazonaws.com"
aws_key = "~/.ssh/ED25519-i-03bf3e399564b8523.pem"
aws_user = "ubuntu"
binary = "./bin/linux_amd64/web"
caddy_file = "./remote/aws/Caddyfile"
deploy_aws_path = "/home/ubuntu/coding/deploys/web_app"
env_file = ".env"
env_file_temp = "env"
home_aws_path = "/home/ubuntu/"
package_file = "package.zip"
scp_path = "ubuntu@ec2-44-204-169-221.compute-1.amazonaws.com:/home/ubuntu/coding/deploys/web_app"
service_file = "./remote/aws/web_app.service"
tls_path = "./tls"

## production/connect: connect to the production server
.PHONY: production/connect
production/connect:
	ssh -o IdentitiesOnly=yes -i ${aws_key} ${aws_user}@${aws_ip}

## aws/deploy: deploy the web_app to aws
.PHONY: aws/deploy
aws/deploy:
	mkdir -p ./to_package
	cp ${env_file} ${env_file_temp}
	cp -R ${env_file_temp} ${binary} ${service_file} ${caddy_file} ${tls_path} ./to_package
	zip -r ${package_file} -j ./to_package/*
	scp -o IdentitiesOnly=yes -i ${aws_key} ${package_file} ${aws_user}@${aws_ip}:${home_aws_path}/
	rm -rf ./to_package ${env_file_temp} ${package_file}
	ssh -t -o IdentitiesOnly=yes -i ${aws_key} ${aws_user}@${aws_ip} '\
		echo `date '+%d/%m/%Y_%H:%M:%S'` > ~/deploy_snippets \
		&& echo "web app" >> ~/deploy_snippets \
		&& sudo systemctl stop web_app \
		&& sudo systemctl stop caddy \
		&& rm -rf ${deploy_aws_path} \
		&& unzip -d ${deploy_aws_path} ${package_file} \
		&& mv ${deploy_aws_path}/${env_file_temp} ${deploy_aws_path}/${env_file} \
		&& mkdir -p ${deploy_aws_path}/${tls_path} \
		&& mv ${deploy_aws_path}/*pem ${deploy_aws_path}/${tls_path} \
		&& mv ${deploy_aws_path}/selfsigned* ${deploy_aws_path}/${tls_path} \
		&& sudo cp ${deploy_aws_path}/web_app.service /etc/systemd/system/ \
		&& sudo systemctl enable web_app \
		&& sudo systemctl restart web_app \
		&& sudo cp ${deploy_aws_path}/Caddyfile /etc/caddy/ \
		&& sudo systemctl restart caddy \
		&& sudo systemctl reload caddy \
	'

# scp -o IdentitiesOnly=yes -i ${aws_key} ${env} ${binary} ${service_file} ${caddy_file} ${scp_path}
# scp -o IdentitiesOnly=yes -i ${aws_key} ./.env ./bin/linux_amd64/web ./remote/aws/web_app.service ./remote/aws/Caddyfile ${aws_user}@${aws_ip}:/home/ubuntu/coding/deploys/web_app/
#
# https://stackoverflow.com/questions/19331497/set-environment-variables-from-file-of-key-value-pairs
# export $(grep -v '^#' ./.env | xargs)
# unset $(grep -v '^#' .env | sed -E 's/(.*)=.*/\1/' | xargs)
#
# export $(grep -v '^#' ./.env | xargs) ; make with/fresh
# export $(grep -v '^#' ./.env | xargs) ; go run ./cmd/api -db-dsn=${SUPABASE_SESSION_POOLER_STRING}
#
# export $(grep -v '^#' ./.env | xargs) ; ./bin/api -db-dsn=${SNIPPETS_WEB_DB_DSN}
# export $(grep -v '^#' ./.env | xargs) ; ./bin/linux_amd64/api -db-dsn=${SNIPPETS_WEB_DB_DSN}
#
# base64 ./.env | xclip -selection clipboard
#
# base64 ./ED25519-i-03bf3e399564b8523.pem | xclip -selection clipboard
#
# sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
# -keyout /etc/ssl/private/selfsigned.key \
# -out /etc/ssl/private/selfsigned.crt \
# -subj "/C=VE/ST=DF/L=Caracas/O=Acme Ltd/OU=DevOps/CN=localhost/emailAddress=foobarbaz@gmail.com"
#
# sudo cp /etc/ssl/private/selfsigned.crt /etc/ssl/certs/
# sudo cp /etc/ssl/private/selfsigned.key /etc/ssl/certs/
#
# sudo chmod 644 /etc/ssl/certs/selfsigned.crt
# sudo chmod 644 /etc/ssl/certs/selfsigned.key
