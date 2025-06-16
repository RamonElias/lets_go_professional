#!/bin/sh
# curl -s -X GET \
#     'https://jsonplaceholder.typicode.com/todos'

HTTP_ADRESS='http://localhost:12397'
# https://dev.to/22mahmoud/no-more-postman-just-use-curl-vim-2mha

if false; then
  # curl -s -X GET "$HTTP_ADRESS/foo"
  # curl -s -X GET "$HTTP_ADRESS/bar"

  curl -s -X GET "$HTTP_ADRESS/hi/joe"
  echo "\n"
  curl -s -X GET "$HTTP_ADRESS/hi/doe"
  echo "\n"
  curl -s -X GET "$HTTP_ADRESS/query?who=me"
  echo "\n"
  curl -s -X GET "$HTTP_ADRESS/query?who=you"
  echo "\n"
  curl -s -X GET "$HTTP_ADRESS/query?who=they"
  echo "\n"
  # curl -s -X POST -H "Content-Type: application/json" "$HTTP_ADRESS/input" --data '{"who":"xyz","password":"xyz"}'
  echo "\n"
  # curl -v -X POST -H "Content-Type: application/json" -d '{"who":"xyz"}' "$HTTP_ADRESS/input"
  curl -s -X POST -H "Content-Type: application/json" -d '{"who":"xyz"}' "$HTTP_ADRESS/input"
  echo "\n"
  curl -s -X POST -H "who: HTTP_ADRESS" "$HTTP_ADRESS/header"
  echo "\n"
  curl -s -X POST -H "who: HTTP_ADRESS" "$HTTP_ADRESS/agent"
  echo "\n"
  curl -s -X GET "$HTTP_ADRESS/even"
  echo "\n"
  curl -s -X GET "$HTTP_ADRESS/random"
  echo "\n"
  curl -s -X GET "$HTTP_ADRESS/users/foobar/123"
  echo "\n"
  curl -s -X GET "$HTTP_ADRESS/users/admin/123"
  echo "\n"
  curl -s -X GET "$HTTP_ADRESS/query_users?page=5&size=50"
  echo "\n"
  curl -s -X GET "$HTTP_ADRESS/query_users"
  # echo "\n"
  # http POST "$HTTP_ADRESS/users" name="foobar" age=67 --ignore-stdin -v
  # echo "\n"
  # curl -s -X POST -H "Content-Type: application/json" -d '{"name":"foobar","age":"67"}' "$HTTP_ADRESS/users"
  # echo "\n"
  # http POST "$HTTP_ADRESS/users" name="foobar" age=67 --ignore-stdin
  echo "\n"
  echo '{"user": {"name": "Joe", "age": 90}, "company": {"name": "ACME"}}' | http POST "$HTTP_ADRESS/users" -v
  echo "\n"
  # http -v --form POST "$HTTP_ADRESS/fusers" name=John age=30 --ignore-stdin
  http -v -f POST "$HTTP_ADRESS/fusers" name=Joe age=30 --ignore-stdin
  echo "\n"
  # http --form POST "$HTTP_ADRESS/files" file@./cat.jpg --ignore-stdin
  http --form POST "$HTTP_ADRESS/files" files@./cat.jpg files@./cat.jpg --ignore-stdin
  echo "\n"
  http -v GET "$HTTP_ADRESS/sayheader" 'Hi: Yoo!!'
  echo "\n"
  http -v POST "$HTTP_ADRESS/posts" title="foobarbaz" --ignore-stdin
  echo "\n"
  http -v DELETE "$HTTP_ADRESS/posts/101"
  echo "\n"
  http GET "$HTTP_ADRESS/posts/1"
  echo "\n"
  http -v GET "$HTTP_ADRESS/custom_header"
  echo "\n"
  http -v POST "$HTTP_ADRESS/password" password="foo" password_confirm="bar" --ignore-stdin
  echo "\n"
  http -v POST "$HTTP_ADRESS/password" password="baz" password_confirm="baz" --ignore-stdin
  echo "\n"
  http GET "$HTTP_ADRESS/redirect"
  echo "\n"
  http GET "$HTTP_ADRESS/cat"
  # curl -X 'GET' 'http://localhost:12397/items?skip=7&limit=3' -H 'accept: application/json'
  echo "\n"
  http GET "$HTTP_ADRESS/items" skip==7 limit==3
  echo "\n"
  http -v GET "$HTTP_ADRESS/things" skip==7 limit==300
  echo "\n"
  http GET "$HTTP_ADRESS/posts/1"
  echo "\n"
  http GET "$HTTP_ADRESS/posts/101"
  echo "\n"
  echo '{"title": "foobaz"}' | http PATCH "$HTTP_ADRESS/posts/3"
  echo "\n"
  echo '{"title": "foobaz"}' | http PATCH "$HTTP_ADRESS/posts/0"
  echo "\n"
  http GET "$HTTP_ADRESS/router/route1" SECRET-HEADER:SECRET_VALUE
  echo "\n"
  http GET "$HTTP_ADRESS/router/route2" SECRET-HEADER:SECRET_VALUE
  echo "\n"
  # http GET "$HTTP_ADRESS/protected-route" SECRET-HEADER:SECRET_VALUE ACCEPT:application/json TOKEN:SECRET_API_TOKEN
  http GET "$HTTP_ADRESS/protected-route" SECRET-HEADER:SECRET_VALUE TOKEN:SECRET_API_TOKEN
  echo "\n"
  echo '{"email":"eliasramondos@gmail.com", "password":"eliasramondos@gmail.com"}' | http -v POST "$HTTP_ADRESS/register"
  echo "\n"
  http -v -f POST "$HTTP_ADRESS/token" username=eliasramondos@gmail.com password=eliasramondos@gmail.com --ignore-stdin

  ACCESS_TOKEN='D02izRkD1B0PsZEM_9iG5URrvCL3rJO201qHapcmTwM'
  echo "\n"
  # curl -s -X GET "$HTTP_ADRESS/protected-route" -H 'accept: application/json' -H "Authorization: Bearer $ACCESS_TOKEN"
  # http -v GET "$HTTP_ADRESS/protected-route" -A bearer -a $ACCESS_TOKEN
  http GET "$HTTP_ADRESS/protected-route" -A bearer -a $ACCESS_TOKEN
  echo "\n"
  echo '{"text": "foo bar baz"}' | http POST "$HTTP_ADRESS/prediction"
  echo "\n"
  echo '{"text": "car bike chain"}' | http POST "$HTTP_ADRESS/prediction"
  echo "\n"
  echo '{"text": "movies script token"}' | http POST "$HTTP_ADRESS/prediction"
  echo "\n"
  echo '{"text": "zoo party pool"}' | http POST "$HTTP_ADRESS/prediction"
  echo "\n"
  echo '{"text": "walk toe shoe"}' | http POST "$HTTP_ADRESS/prediction"
  echo "\n"
  echo '{"text": "laptop pc mouse"}' | http POST "$HTTP_ADRESS/prediction"
  echo "\n"
  echo '{"text": "one two tres"}' | http POST "$HTTP_ADRESS/prediction"
  echo "\n"
  echo '{"text": "text category lit"}' | http POST "$HTTP_ADRESS/prediction"
  echo "\n"
  echo '{"text": "correct limit route"}' | http POST "$HTTP_ADRESS/prediction"
else
  echo "\n"
  http GET "$HTTP_ADRESS/slow-async"
  echo "\n"
  http GET "$HTTP_ADRESS/slow-sync"
  echo "\n"
  http GET "$HTTP_ADRESS/fast"
fi
