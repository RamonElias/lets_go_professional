#!/bin/bash
# curl -s -X GET \
    # 'https://jsonplaceholder.typicode.com/todos'

# https://dev.to/22mahmoud/no-more-postman-just-use-curl-vim-2mha
# https://techinscribed.com/5-ways-to-live-reloading-go-applications/
# go install github.com/gravityblast/fresh@latest
# ctrl + f + g
# ctrl + q (quicklist)
# cdo s/distance/qwerty/gc
# cdo s/greenlight.custom/sqlc_greenlight/gc
# egrep -lir "GREENLIGHT_DB_DSN"
# export PGHOST=${PGHOST-localhost} ; export PGPORT=${PGPORT-5432} ; export PGUSER=${PGUSER-postgres} ; export PGPASSWORD=${PGPASSWORD-123456} ; export VISUAL=vim ; export EDITOR=vim ; export POSTGRESQL_DB_DSN='postgres://postgres:123456@localhost/tickets' ; export GREENLIGHT_DB_DSN='postgres://greenlight:greenlight@localhost/greenlight'

# HTTP_ADRESS='http://localhost:20203'
HTTP_ADDRESS='http://localhost:22333'
HTTPS_ADDRESS='https://localhost:22333'
# curl -i -X GET "$HTTP_ADRESS/"
# echo "\n"
# curl -i -X GET "$HTTP_ADRESS/v1/movies/1"
# echo "\n"
# curl -i -X GET "$HTTP_ADRESS/v1/healthcheck"
# echo "\n"
# curl --head "$HTTP_ADRESS/"
# curl -i -X POST -d "" "$HTTP_ADRESS/"
# curl -i -d "" "$HTTP_ADRESS/"
# echo "\n"
BODY='{}'
# echo $BODY | http -vv POST "$HTTPS_ADDRESS/snippet/create"
echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \n"
EMAIL='foobarbaz@gmail.com'
PASSWORD=$EMAIL
SIGNUP_ADDRESS="$HTTPS_ADDRESS/user/signup"
echo $SIGNUP_ADDRESS
CSRF_TOKEN=$(http --verify=no GET "$SIGNUP_ADDRESS" | grep -oP '<input[^>]*name=["'\'']csrf_token["'\''][^>]*value=["'\'']\K[^"'\'']+' | sed "s/&#43;/+/g; s/&#[0-9]\+;/ /g")
echo '$CSRF_TOKEN'
echo $CSRF_TOKEN
BODY='{"name": "foobarbaz", "email":"'"$EMAIL"'", "password":"'"$PASSWORD"'", "csrf_token":"'"$CSRF_TOKEN"'"}'
# form.Add("csrf_token", tt.csrfToken)
echo $BODY | http --verify=no -vv POST "$SIGNUP_ADDRESS"
echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \n"
CSRF_TOKEN=$(echo $BODY | http --verify=no POST "$SIGNUP_ADDRESS" --headers | sed -n 's/.*Set-Cookie:.*csrf_token=\([^;]*\).*/\1/pi')
echo "Token extraído: $CSRF_TOKEN"
echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \n"
BODY='{"name": "foobarbaz", "email":"'"$EMAIL"'", "password":"'"$PASSWORD"'", "csrf_token":"'"$CSRF_TOKEN"'"}'
echo $BODY | http --verify=no -vv POST "$SIGNUP_ADDRESS"
# http --verify=no -vv GET "$SIGNUP_ADDRESS"
# http --verify=no -vv GET "$SIGNUP_ADDRESS" | grep -oP '<input[^>]*name="csrf_token"[^>]*value="\K[^"]+'
# http --verify=no GET "$SIGNUP_ADDRESS" | grep -oP '<input[^>]*name=["'\'']csrf_token["'\''][^>]*value=["'\'']\K[^"'\'']+' | sed "s/&#43;/+/g; s/&#[0-9]\+;/ /g"
echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \n"
# file:///home/lenovo/Downloads/letsgo/lets-go-professional-package231024/html/10.06-user-authorization.html
# $ curl -ki -d "" https://localhost:22333/snippet/create
# curl -i "$HTTP_ADRESS/snippet/create"
# echo "\n"
# curl -i "$HTTP_ADRESS/snippet/view/123"
# echo "\n"
# curl -iL -d "" "$HTTP_ADRESS/snippet/create"
# echo "\n"
# curl -i -X PUT "$HTTP_ADRESS/v1/healthcheck"
# echo "\n"
# curl -i -X GET "$HTTP_ADRESS/v1/movies/foo"
# echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \n"
# BODY='{"title":"Moana","runtime":107, "genres":["animation","adventure"]}'
# BODY='{"title":"Moana","year":2016,"runtime":107, "genres":["animation","adventure"]}'
# # echo $BODY | http -vv POST "$HTTP_ADRESS/v1/movies"
# echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \n"
# BODY='{"title": "Moana", }'
# # echo $BODY | http -vv POST "$HTTP_ADRESS/v1/movies"
# echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \n"
# BODY='["foo", "bar"]'
# # echo $BODY | http -vv POST "$HTTP_ADRESS/v1/movies"
# echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \n"
# BODY='{"title": 123}'
# # echo $BODY | http -vv POST "$HTTP_ADRESS/v1/movies"
# echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \n"
# # http -vv POST "$HTTP_ADRESS/v1/movies"
# echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \n"
# BODY='{"title": "Moana", "rating":"PG"}'
# # echo $BODY | http -vv POST "$HTTP_ADRESS/v1/movies"
# echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \n"
# BODY='{"title": "Moana"}{"title": "Top Gun"}'
# # echo $BODY | http -vv POST "$HTTP_ADRESS/v1/movies"
# echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \n"
# BODY='{"title": "Moana"} :~()'
# # echo $BODY | http -vv POST "$HTTP_ADRESS/v1/movies"
# echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \n"
# BODY1='{"title":"Black Panther","year":2018,"runtime":"134 mins","genres":["action","adventure"]}'
# BODY2='{"title":"Deadpool","year":2016, "runtime":"108 mins","genres":["action","comedy"]}'
# BODY3='{"title":"The Breakfast Club","year":1986, "runtime":"96 mins","genres":["drama"]}'
# # movies=("$BODY1","$BODY2","$BODY3")
# declare -A movies=(
#   [BODY1]="$BODY1"
#   [BODY2]="$BODY2"
#   [BODY3]="$BODY3"
# )
# for movie in "${movies[@]}"; do
#   echo "$movie"
#   # echo "$movie" | http -vv POST "$HTTP_ADRESS/v1/movies"
#   echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \n"
# done
# BODY='{"title":"Black Panther","year":2018,"runtime":"134 mins","genres":["sci-fi","action","adventure"]}'
# # echo $BODY | http -vv PUT "$HTTP_ADRESS/v1/movies/3"
