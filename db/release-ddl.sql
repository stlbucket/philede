------------------------------------------------
-- release_ddl_up
------------------------------------------------
create or replace function pde.release_ddl_up(release pde.release)
returns text as $$
  select 'ddl_up'::text;
$$ language sql stable;

------------------------------------------------
-- release_ddl_down
------------------------------------------------
create or replace function pde.release_ddl_down(release pde.release)
returns text as $$
  select 'ddl_down'::text;
$$ language sql stable;

