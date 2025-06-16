create table snippets (
  id bigserial primary key,
  title varchar(100) not null,
  content text not null,
  created timestamp not null,
  expires timestamp not null
  -- created_at timestamp(0) with time zone not null default now(),
);
