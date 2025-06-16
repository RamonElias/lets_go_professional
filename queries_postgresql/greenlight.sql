drop database greenlight with (force);
create database greenlight;
\c greenlight
drop role if exists greenlight;
-- create role greenlight with login password 'pa55word';
create role greenlight with login password :'password';
alter database greenlight owner to greenlight;
grant create on database greenlight to greenlight;
create extension if not exists citext;
select current_user;
show config_file;
-- select CONCAT(:'password', 'foobarbaz') as password_cast;
-- select :'password' as password_cast;
