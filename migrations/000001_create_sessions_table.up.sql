-- Establece la ruta de búsqueda para que el schema 'snippets' sea el predeterminado
-- set search_path to snippets, public;

create table sessions (
  token text primary key,
  data bytea not null,
  expiry timestamptz not null
);

create index sessions_expiry_idx on sessions (expiry);
