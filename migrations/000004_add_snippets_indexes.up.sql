create index if not exists idx_snippets_created on snippets (created);
-- If you specifically need a GIN index for full-text search capabilities on the timestamp (which would be unusual), you would first need to convert it to a searchable format. For example, you could create a text representation:
-- create index if not exists idx_snippets_created_gin on snippets using gin(to_tsvector('simple', created::text));
