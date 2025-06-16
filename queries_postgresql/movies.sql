-- name: CreateMovie :one
insert into movies (title, year, runtime, genres)
values ($1, $2, $3, $4)
returning id, created_at, version;

-- name: GetMovie :one
select id, created_at, title, year, runtime, genres, version
from movies
where id = $1
limit 1;

-- name: UpdateMovie :one
update movies
set title = $3, year = $4, runtime = $5, genres = $6, version = version + 1
where id = $1 and version = $2
returning version;

-- name: DeleteMovie :exec
delete from movies
where id = $1;

-- name: GetMovies :many
select count(*) over(), id, created_at, title, year, runtime, genres, version
from movies
where (to_tsvector('simple', title) @@ plainto_tsquery('simple', $1) or $1 = '')
and (genres @> $2 or $2 = '{}')
-- order by $3 $4, id asc
order by $3::text asc, id asc
limit $4 offset $5;
