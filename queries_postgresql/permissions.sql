-- name: CreatePermissionForUser :exec
insert into users_permissions (user_id, permission_id)
select $1, permissions.id
from permissions
where permissions.code = any($2);

-- name: GetPermissionsForUser :many
select permissions.code
from permissions
inner join users_permissions on users_permissions.permission_id = permissions.id
inner join users on users_permissions.user_id = users.id
where users.id = $1;
