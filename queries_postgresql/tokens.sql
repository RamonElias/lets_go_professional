-- name: InsertToken :exec
insert into tokens (hash, user_id, expiry, scope)
values ($1, $2, $3, $4);

-- name: DeleteAllTokensForUserInScope :exec
delete from tokens
where scope = $1 and user_id = $2;
