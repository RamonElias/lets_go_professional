create table users (
  id bigserial primary key,
  name varchar(500) not null,
  email varchar(255) not null,
  hashed_password char(60) not null,
  created timestamp not null
  -- created timestamptz not null
);

alter table users add constraint users_uc_email unique (email);
