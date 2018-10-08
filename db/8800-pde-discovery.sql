------------------------------------------------
-- create and discover pde project
------------------------------------------------

INSERT INTO pde.pde_project(name) SELECT 'PostgraphIle-DE';

INSERT INTO pde.major(project_id, revision, name) SELECT id, 1, 'Major Name' from pde.pde_project where name = 'PostgraphIle-DE';

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
  ,(SELECT id from pde.release where status = 'Development')
  ,'pde discovery'
  ,(SELECT id from pde.pde_project where name = 'PostgraphIle-DE')
;

INSERT INTO pde.schema(  
  name
  ,project_id
)
SELECT
  'pde'
  ,(SELECT id from pde.pde_project where name = 'PostgraphIle-DE')
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
  ,(SELECT id from pde.pde_project where name = 'PostgraphIle-DE')
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
  ,3
  ,'CREATE TRIGGER STATEMENT;'
  ,(select id from pde.artifact where name = 'example_table')
  ,(SELECT id from pde.pde_project where name = 'PostgraphIle-DE')
  ,(SELECT id from pde.patch_type where key = 'table-triggers')
  from pde.minor where revision = 2;

