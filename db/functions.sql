-- SELECT 
--   n.nspname as "Schema",
--   p.proname as "Name",
--   pg_catalog.pg_get_function_result(p.oid) as "Result data type",
--   pg_catalog.pg_get_function_arguments(p.oid) as "Argument data types",
--   pg_catalog.pg_get_functiondef(p.oid),
--  CASE
--   WHEN p.proisagg THEN 'agg'
--   WHEN p.proiswindow THEN 'window'
--   WHEN p.prorettype = 'pg_catalog.trigger'::pg_catalog.regtype THEN 'trigger'
--   ELSE 'normal'
--  END as "Type"
-- FROM pg_catalog.pg_proc p
--      LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
-- WHERE n.nspname OPERATOR(pg_catalog.~) '^(pde)$'
-- ORDER BY 1, 2, 4;


-- SELECT pg_catalog.pg_get_functiondef('pde.build_minor'::regproc);



SELECT schema_name
FROM information_schema.schemata
WHERE schema_name NOT LIKE 'pg_%'
AND schema_name != 'public'
AND schema_name != 'information_schema'
;


-- SELECT table_name
-- FROM information_schema.tables
-- WHERE table_type='BASE TABLE'
-- AND table_schema = 'pde'
-- ;

-- SELECT
--   column_name
--   ,data_type
--   ,is_nullable
--   ,column_default
-- FROM information_schema.columns
-- WHERE table_name='minor'
-- AND table_schema = 'pde'
-- ;

-- SELECT
--   *
-- FROM information_schema.columns
-- WHERE table_name='minor'
-- AND table_schema = 'pde'
-- limit 1
-- ;

-- SELECT
--   table_schema
--   ,table_name
--   ,column_name
--   ,constraint_schema
--   ,constraint_name
-- FROM information_schema.constraint_column_usage
-- WHERE table_name='minor'
-- AND table_schema = 'pde'
-- ;

-- SELECT
--  *
-- from information_schema.key_column_usage
-- WHERE table_name='minor'
-- AND table_schema = 'pde'
-- ;

-- SELECT
-- *
-- FROM information_schema.constraint_column_usage
-- WHERE table_name='minor'
-- AND table_schema = 'pde'
-- limit 1
-- ;

