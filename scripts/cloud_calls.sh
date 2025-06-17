#!/bin/bash
# curl -s -X GET \
    # 'https://jsonplaceholder.typicode.com/todos'

# https://dev.to/22mahmoud/no-more-postman-just-use-curl-vim-2mha
# https://techinscribed.com/5-ways-to-live-reloading-go-applications/
# go install github.com/gravityblast/fresh@latest
#
# HTTP_ADRESS='http://localhost:20203'
HTTP_ADDRESS='http://44.204.169.221:8087'
HTTPS_ADDRESS='https://localhost:22333'
EMAIL='eliasramondos@gmail.com'
PASSWORD=$EMAIL
SIGNUP_ADDRESS="$HTTPS_ADDRESS/user/signup"
LOGIN_ADDRESS="$HTTP_ADDRESS/user/login"

# echo $SIGNUP_ADDRESS
# CSRF_TOKEN=$(http --verify=no GET "$SIGNUP_ADDRESS" | grep -oP '<input[^>]*name=["'\'']csrf_token["'\''][^>]*value=["'\'']\K[^"'\'']+' | sed "s/&#43;/+/g; s/&#[0-9]\+;/ /g")
# echo '$CSRF_TOKEN'
# echo $CSRF_TOKEN
# BODY='{"name": "foobarbaz", "email":"'"$EMAIL"'", "password":"'"$PASSWORD"'", "csrf_token":"'"$CSRF_TOKEN"'"}'
# echo $BODY | http --verify=no -vv POST "$SIGNUP_ADDRESS"
# echo " * - * - * - * - * - * - * - * - * - * - * - * - * \n"
# CSRF_TOKEN=$(echo $BODY | http --verify=no POST "$SIGNUP_ADDRESS" --headers | sed -n 's/.*Set-Cookie:.*csrf_token=\([^;]*\).*/\1/pi')
# echo "Token extraído: $CSRF_TOKEN"
echo " * - * - * - * - * - * - * - * - * - * - * - * - * \n"
echo $LOGIN_ADDRESS
CSRF_TOKEN=$(http --verify=no GET "$LOGIN_ADDRESS" | grep -oP '<input[^>]*name=["'\'']csrf_token["'\''][^>]*value=["'\'']\K[^"'\'']+' | sed "s/&#43;/+/g; s/&#[0-9]\+;/ /g")
echo '$CSRF_TOKEN'
echo $CSRF_TOKEN
BODY='{"email":"'"$EMAIL"'", "password":"'"$PASSWORD"'", "csrf_token":"'"$CSRF_TOKEN"'"}'
echo $BODY | http --verify=no -vv POST "$LOGIN_ADDRESS"
echo " * - * - * - * - * - * - * - * - * - * - * - * - * \n"
# $ curl -ki -d "" https://localhost:22333/snippet/create
# $ curl -ki -d "" https://localhost:22333/snippet/create
