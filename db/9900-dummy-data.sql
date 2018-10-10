------------------------------------------------
-- dummy data
------------------------------------------------

INSERT INTO pde.pde_project(name) SELECT 'Todo';

INSERT INTO pde.major(project_id, revision, name) SELECT id, 1, 'Major Name' from pde.pde_project where name = 'Todo';

INSERT INTO pde.minor(
  major_id
  ,revision
  ,release_id
  ,name
  ,project_id
) 
SELECT
  (SELECT id from pde.major where revision = 1)
  ,1
  ,(SELECT id from pde.release where status = 'DEVELOPMENT')
  ,'Todo Schema'
  ,(SELECT id from pde.pde_project where name = 'Todo')
;
INSERT INTO pde.minor(
  major_id
  ,revision
  ,release_id
  ,name
  ,project_id
)
SELECT
  (SELECT id from pde.major where revision = 1)
  ,2
  ,(SELECT id from pde.release where status = 'DEVELOPMENT')
  ,'First Feature'
  ,(SELECT id from pde.pde_project where name = 'Todo')
;
INSERT INTO pde.minor(  
  major_id
  ,revision
  ,release_id
  ,name
  ,project_id
) 
SELECT
  (SELECT id from pde.major where revision = 1)
  ,3
  ,(SELECT id from pde.release where status = 'DEVELOPMENT')
  ,'Second Feature'
  ,(SELECT id from pde.pde_project where name = 'Todo')
;

INSERT INTO pde.schema(  
  name
  ,project_id
)
SELECT
  'todo'
  ,(SELECT id from pde.pde_project where name = 'Todo')
;

INSERT INTO pde.artifact(  
  name
  ,artifact_type_id
  ,description
  ,schema_id
  ,project_id
)
SELECT
  'todo schema'
  ,(select id from pde.artifact_type where name = 'schema')
  ,'the todo schema'
  ,(SELECT id from pde.schema where name = 'todo')
  ,(SELECT id from pde.pde_project where name = 'Todo')
;

INSERT INTO pde.artifact(  
  name
  ,artifact_type_id
  ,description
  ,schema_id
  ,project_id
)
SELECT
  'example_table'
  ,(select id from pde.artifact_type where name = 'table')
  ,'a description of your table'
  ,(SELECT id from pde.schema where name = 'todo')
  ,(SELECT id from pde.pde_project where name = 'Todo')
;

INSERT INTO pde.artifact(  
  name
  ,artifact_type_id
  ,description
  ,schema_id
  ,project_id
)
SELECT
  'example_function'
  ,(select id from pde.artifact_type where name = 'function')
  ,'a description of your function'
  ,(SELECT id from pde.schema where name = 'todo')
  ,(SELECT id from pde.pde_project where name = 'Todo')
;

-- INSERT INTO pde.artifact(  
--   name
--   ,artifact_type_id
--   ,description
--   ,schema_id
--   ,project_id
-- )
-- SELECT
--   'example_trigger'
--   ,(select id from pde.artifact_type where name = 'trigger')
--   ,'a description of your trigger'
--   ,(SELECT id from pde.schema where name = 'todo')
--   ,(SELECT id from pde.pde_project where name = 'Todo')
-- ;

INSERT INTO pde.artifact(  
  name
  ,artifact_type_id
  ,description
  ,schema_id
  ,project_id
)
SELECT
  'second_function'
  ,(select id from pde.artifact_type where name = 'function')
  ,'a description of another function'
  ,(SELECT id from pde.schema where name = 'todo')
  ,(SELECT id from pde.pde_project where name = 'Todo')
;

INSERT INTO pde.patch(
  minor_id
  ,revision
  ,ddl_up
  ,artifact_id
  ,project_id
  ,patch_type_id
) 
SELECT 
  id 
  ,1
  ,'CREATE SCHEMA todo;'
  ,(select id from pde.artifact where name = 'todo schema')
  ,(SELECT id from pde.pde_project where name = 'Todo')
  ,(SELECT id from pde.patch_type where key = 'schema-create')
  from pde.minor where revision = 1;

INSERT INTO pde.patch(
  minor_id
  ,revision
  ,ddl_up
  ,artifact_id
  ,project_id
  ,patch_type_id
) 
SELECT
  id 
  ,1
  ,'CREATE TABLE STATEMENT;'
  ,(select id from pde.artifact where name = 'example_table')
  ,(SELECT id from pde.pde_project where name = 'Todo')
  ,(SELECT id from pde.patch_type where key = 'table-create')
  from pde.minor where revision = 2;

INSERT INTO pde.patch(
  minor_id
  ,revision
  ,ddl_up
  ,artifact_id
  ,project_id
  ,patch_type_id
) 
SELECT
  id
  ,2 
  ,'CREATE FUNCTION STATEMENT;'
  ,(select id from pde.artifact where name = 'example_function')
  ,(SELECT id from pde.pde_project where name = 'Todo')
  ,(SELECT id from pde.patch_type where key = 'function-create')
  from pde.minor where revision = 2;

INSERT INTO pde.patch(
  minor_id
  ,revision
  ,ddl_up
  ,artifact_id
  ,project_id
  ,patch_type_id
) 
SELECT
  id
  ,3
  ,'CREATE TRIGGER STATEMENT;'
  ,(select id from pde.artifact where name = 'example_table')
  ,(SELECT id from pde.pde_project where name = 'Todo')
  ,(SELECT id from pde.patch_type where key = 'table-triggers')
  from pde.minor where revision = 2;

INSERT INTO pde.patch(
  minor_id
  ,revision
  ,ddl_up
  ,artifact_id
  ,project_id
  ,patch_type_id
) 
SELECT
  id
  ,1
  ,'second function;'
  ,(select id from pde.artifact where name = 'second_function')
  ,(SELECT id from pde.pde_project where name = 'Todo')
  ,(SELECT id from pde.patch_type where key = 'function-create')
  from pde.minor where revision = 3;

INSERT INTO pde.test(name, minor_id, type) SELECT 'GQL-1', id, 'GraphQL' FROM pde.minor;
INSERT INTO pde.test(name, minor_id, type) SELECT 'GQL-2', id, 'GraphQL' FROM pde.minor;
INSERT INTO pde.test(name, minor_id, type) SELECT 'PGT-1', id, 'PgTap' FROM pde.minor;
INSERT INTO pde.test(name, minor_id, type) SELECT 'PGT-2', id, 'PgTap' FROM pde.minor;
