-- name: CreateUser :one
insert into users (name, email, password_hash, activated)
values ($1, $2, $3, $4)
returning id, created_at, version;

-- name: GetUserByEmail :one
select id, created_at, name, email, password_hash, activated, version
from users
where email = $1
limit 1;

-- name: UpdateUser :one
update users
set name = $3, email = $4, password_hash = $5, activated = $6, version = version + 1
where id = $1 and version = $2
returning version;

-- name: GetUserForToken :one
select users.id, users.created_at, users.name, users.email, users.password_hash, users.activated, users.version
from users inner join tokens
on users.id = tokens.user_id
where tokens.hash = $1
and tokens.scope = $2
and tokens.expiry > $3
limit 1;
