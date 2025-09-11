drop database if exists local_db with (force);
create database local_db;
\c local_db

-- drop extension if exists "uuid-ossp" cascade;
-- drop extension if exists citext cascade;
-- drop extension if exists hstore cascade;
-- drop extension if exists pg_stat_statements cascade;
-- drop extension if exists pg_trgm cascade;
-- drop extension if exists pgcrypto cascade;
-- drop extension if exists plpgsql cascade;
-- drop extension if exists postgis cascade;

create extension "uuid-ossp";
create extension citext;
create extension hstore;
create extension pg_stat_statements;
create extension pg_trgm;
create extension plpgsql;
-- create extension pgcrypto;
-- create extension if not exists postgis;

-- drop role if exists local_admin;
-- create role local_admin;
-- alter role local_admin with login password :'password';
-- alter database local_db owner to local_admin;
-- grant create on database local_db to local_admin;

-- schemas
drop schema if exists greenlight;
drop schema if exists snippets;
create schema if not exists greenlight;
create schema if not exists snippets;
-- alter schema greenlight owner to local_admin;
-- alter schema snippets owner to local_admin;
-- grant all on schema greenlight to local_admin;
-- grant all on schema snippets to local_admin;

select current_user;
select current_user;
show config_file;
select CONCAT(:'password', 'foobarbaz') as password_cast;
select :'password' as password_cast;
-- psql ${POSTGRESQL_DB_DSN} -v password=123456 -f ./queries_postgresql/local_db.sql
-- export LOCAL_DB_DSN='postgres://local_admin:123456@localhost/local_db?sslmode=disable&options=-csearch_path%3Dsnippets%2Cpublic'
-- psql ${POSTGRESQL_DB_DSN}
-- psql ${LOCAL_DB_DSN}
