drop database snippets_web with (force);
create database snippets_web;
\c snippets_web
-- drop role if exists snippets_web;
-- create role snippets_web with login password :'password';
-- alter database snippets_web owner to snippets_web;
-- grant create on database snippets_web to snippets_web;
create extension if not exists citext;
select current_user;
show config_file;
-- select CONCAT(:'password', 'foobarbaz') as password_cast;
-- select :'password' as password_cast;
