------------------------------------------------
-- shard_1 schema - from https://rob.conery.io/2014/05/28/a-better-id-generator-for-postgresql/
------------------------------------------------
drop schema if exists shard_1 cascade;

create schema shard_1;
create sequence shard_1.global_id_sequence;

CREATE OR REPLACE FUNCTION shard_1.id_generator(OUT result bigint) AS $$
DECLARE
    our_epoch bigint := 1314220021721;
    seq_id bigint;
    now_millis bigint;
    -- the id of this DB shard, must be set for each
    -- schema shard you have - you could pass this as a parameter too
    shard_id int := 1;
BEGIN
    SELECT nextval('shard_1.global_id_sequence') % 1024 INTO seq_id;

    SELECT FLOOR(EXTRACT(EPOCH FROM clock_timestamp()) * 1000) INTO now_millis;
    result := (now_millis - our_epoch) << 23;
    result := result | (shard_id << 10);
    result := result | (seq_id);
END;
$$ LANGUAGE PLPGSQL;

------------------------------------------------
-- pde schema
------------------------------------------------
drop schema if exists pde cascade;

CREATE SCHEMA pde;

------------------------------------------------
-- pde_project
------------------------------------------------
CREATE TABLE pde.pde_project (
  id bigint UNIQUE NOT NULL DEFAULT shard_1.id_generator(),
  name text NOT NULL,
  CONSTRAINT pk_pde_pde_project PRIMARY KEY (id),
  CHECK (name <> '')
);

------------------------------------------------
-- release
------------------------------------------------
CREATE TYPE pde.release_status AS ENUM
   ('Planned',
    'Working',
    'Released');

CREATE TABLE pde.release (
  id bigint UNIQUE NOT NULL DEFAULT shard_1.id_generator(),
  project_id bigint NOT NULL,
  name text NOT NULL,
  status pde.release_status NOT NULL DEFAULT 'Planned',
  ddl text,
  CONSTRAINT pk_pde_release PRIMARY KEY (id),
  CHECK (name <> '')
);
ALTER TABLE pde.release ADD CONSTRAINT fk_release_project FOREIGN KEY (project_id) REFERENCES pde.pde_project (id);


------------------------------------------------
-- major
------------------------------------------------
CREATE TABLE pde.major (
  id bigint UNIQUE NOT NULL DEFAULT shard_1.id_generator(),
  project_id bigint NOT NULL,
  revision integer,
  CONSTRAINT pk_pde_major PRIMARY KEY (id)
);
ALTER TABLE pde.major ADD CONSTRAINT fk_major_project FOREIGN KEY (project_id) REFERENCES pde.pde_project (id);

------------------------------------------------
-- minor
------------------------------------------------
CREATE TABLE pde.minor (
  id bigint UNIQUE NOT NULL DEFAULT shard_1.id_generator(),
  major_id bigint NOT NULL,
  release_id bigint NOT NULL,
  revision integer,
  number text NOT NULL,
  CONSTRAINT pk_pde_minor PRIMARY KEY (id),
  CHECK (number <> '')
);
ALTER TABLE pde.minor ADD CONSTRAINT fk_minor_major FOREIGN KEY (major_id) REFERENCES pde.major (id);
ALTER TABLE pde.minor ADD CONSTRAINT fk_minor_release FOREIGN KEY (release_id) REFERENCES pde.release (id);

  --||--
  CREATE FUNCTION pde.fn_timestamp_update_minor() RETURNS trigger AS $$
  BEGIN
    NEW.number = (select lpad(mj.revision::text,4,'0') || '.' || lpad(NEW.revision::text,4,'0') from pde.major mj where mj.id = NEW.major_id);
    RETURN NEW;
  END; $$ LANGUAGE plpgsql;
  --||--
  CREATE TRIGGER tg_timestamp_update_minor
    BEFORE INSERT OR UPDATE ON pde.minor
    FOR EACH ROW
    EXECUTE PROCEDURE pde.fn_timestamp_update_minor();

------------------------------------------------
-- artifact type
------------------------------------------------
CREATE TABLE pde.artifact_type (
  id bigint UNIQUE NOT NULL DEFAULT shard_1.id_generator(),
  name text NOT NULL,
  execution_order integer NOT NULL,
  properties jsonb NOT NULL DEFAULT '{}'::jsonb,
  CONSTRAINT pk_pde_artifact_ype PRIMARY KEY (id)
);
--||--

------------------------------------------------
--artifact_type_relationship
------------------------------------------------
CREATE TABLE pde.artifact_type_relationship (
  id bigint UNIQUE NOT NULL DEFAULT shard_1.id_generator(),
  parent_artifact_type_id bigint NOT NULL,
  child_artifact_type_id bigint NOT NULL,
  CONSTRAINT pk_artifact_type_relationship PRIMARY KEY (id)
);

ALTER TABLE pde.artifact_type_relationship ADD CONSTRAINT fk_artifact_type_relationship_parent FOREIGN KEY (parent_artifact_type_id) REFERENCES pde.artifact_type (id);
ALTER TABLE pde.artifact_type_relationship ADD CONSTRAINT fk_artifact_type_relationship_child FOREIGN KEY (child_artifact_type_id) REFERENCES pde.artifact_type (id);


------------------------------------------------
--schema
------------------------------------------------
CREATE TABLE pde.schema (
  id bigint UNIQUE NOT NULL DEFAULT shard_1.id_generator(),
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  name text NOT NULL,
  release_id bigint NOT NULL UNIQUE,
  CONSTRAINT pk_schema PRIMARY KEY (id)
);

ALTER TABLE pde.schema ADD CONSTRAINT fk_schema_release FOREIGN KEY (release_id) REFERENCES pde.release (id);

------------------------------------------------
--artifact
------------------------------------------------
CREATE TABLE pde.artifact (
  id bigint UNIQUE NOT NULL DEFAULT shard_1.id_generator(),
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL,
  name text NOT NULL,
  description text NOT NULL DEFAULT '',
  artifact_type_id bigint NOT NULL,
  schema_id bigint NOT NULL,
  CHECK (name <> ''),
  CONSTRAINT pk_artifact PRIMARY KEY (id)
);

  --||--
  CREATE FUNCTION pde.fn_timestamp_update_artifact() RETURNS trigger AS $$
  BEGIN
    NEW.updated_at = current_timestamp;
    RETURN NEW;
  END; $$ LANGUAGE plpgsql;
  --||--
  CREATE TRIGGER tg_timestamp_update_artifact
    BEFORE INSERT OR UPDATE ON pde.artifact
    FOR EACH ROW
    EXECUTE PROCEDURE pde.fn_timestamp_update_artifact();

ALTER TABLE pde.artifact ADD CONSTRAINT fk_artifact_type FOREIGN KEY (artifact_type_id) REFERENCES pde.artifact_type (id);
ALTER TABLE pde.artifact ADD CONSTRAINT fk_artifact_schema FOREIGN KEY (schema_id) REFERENCES pde.schema (id);

------------------------------------------------
--artifact_relationship
------------------------------------------------
CREATE TABLE pde.artifact_relationship (
  id bigint UNIQUE NOT NULL DEFAULT shard_1.id_generator(),
  parent_artifact_id bigint NOT NULL,
  child_artifact_id bigint NOT NULL,
  CONSTRAINT pk_artifact_relationship PRIMARY KEY (id)
);

ALTER TABLE pde.artifact_relationship ADD CONSTRAINT fk_artifact_relationship_parent FOREIGN KEY (parent_artifact_id) REFERENCES pde.artifact (id);
ALTER TABLE pde.artifact_relationship ADD CONSTRAINT fk_artifact_relationship_child FOREIGN KEY (child_artifact_id) REFERENCES pde.artifact (id);

------------------------------------------------
-- patch
------------------------------------------------
CREATE TABLE pde.patch (
  id bigint UNIQUE NOT NULL DEFAULT shard_1.id_generator(),
  minor_id bigint NOT NULL,
  artifact_id bigint NOT NULL,
  revision integer,
  ddl text NOT NULL DEFAULT '<ddl>',
  working_ddl text NOT NULL DEFAULT '<ddl>',
  number text NOT NULL,
  CHECK (number <> ''),
  CONSTRAINT pk_pde_patch PRIMARY KEY (id)
);
ALTER TABLE pde.patch ADD CONSTRAINT fk_patch_minor FOREIGN KEY (minor_id) REFERENCES pde.minor (id);
ALTER TABLE pde.patch ADD CONSTRAINT fk_patch_artifact FOREIGN KEY (artifact_id) REFERENCES pde.artifact (id);
--||--
CREATE FUNCTION pde.fn_timestamp_update_patch() RETURNS trigger AS $$
BEGIN
  NEW.number = (select mi.number || '.' || lpad(NEW.revision::text,4,'0') from pde.minor mi where mi.id = NEW.minor_id);
  RETURN NEW;
END; $$ LANGUAGE plpgsql;
--||--
CREATE TRIGGER tg_timestamp_update_patch
  BEFORE INSERT OR UPDATE ON pde.patch
  FOR EACH ROW
  EXECUTE PROCEDURE pde.fn_timestamp_update_patch();


------------------------------------------------
-- pde_project_schemas
------------------------------------------------
create or replace function pde.pde_project_schemas(p pde.pde_project)
returns setof pde.schema as $$
  select s.*
  from pde.schema s
  join pde.release r on r.id = s.release_id
  where r.project_id = p.id
  ;
$$ language sql stable;

------------------------------------------------
-- artifact_type_children
------------------------------------------------
create or replace function pde.artifact_type_children(artifact_type pde.artifact_type)
returns setof pde.artifact_type as $$
  select ac.*
  from pde.artifact_type_relationship atr
  join pde.artifact_type ac on ac.id = atr.child_artifact_type_id
  where atr.parent_artifact_type_id = artifact_type.id
  ;
$$ language sql stable;



------------------------------------------------
-- dummy data
------------------------------------------------
INSERT INTO pde.artifact_type(name, execution_order) SELECT 'extension', 1; 
INSERT INTO pde.artifact_type(name, execution_order) SELECT 'type', 2; 
INSERT INTO pde.artifact_type(name, execution_order) SELECT 'table', 3; 
INSERT INTO pde.artifact_type(name, execution_order) SELECT 'foreign key', 4; 
INSERT INTO pde.artifact_type(name, execution_order) SELECT 'index', 5; 
INSERT INTO pde.artifact_type(name, execution_order) SELECT 'trigger', 6; 
INSERT INTO pde.artifact_type(name, execution_order) SELECT 'function', 7; 
INSERT INTO pde.artifact_type(name, execution_order) SELECT 'view', 8; 
INSERT INTO pde.artifact_type(name, execution_order) SELECT 'comment', 9; 
INSERT INTO pde.artifact_type(name, execution_order) SELECT 'permission', 10; 

-- table children
INSERT INTO pde.artifact_type_relationship(parent_artifact_type_id, child_artifact_type_id) SELECT 
  (SELECT id from pde.artifact_type WHERE name = 'table')
  ,(SELECT id from pde.artifact_type WHERE name = 'index')
  ; 
INSERT INTO pde.artifact_type_relationship(parent_artifact_type_id, child_artifact_type_id) SELECT 
  (SELECT id from pde.artifact_type WHERE name = 'table')
  ,(SELECT id from pde.artifact_type WHERE name = 'trigger')
  ; 
INSERT INTO pde.artifact_type_relationship(parent_artifact_type_id, child_artifact_type_id) SELECT 
  (SELECT id from pde.artifact_type WHERE name = 'table')
  ,(SELECT id from pde.artifact_type WHERE name = 'comment')
  ; 
INSERT INTO pde.artifact_type_relationship(parent_artifact_type_id, child_artifact_type_id) SELECT 
  (SELECT id from pde.artifact_type WHERE name = 'table')
  ,(SELECT id from pde.artifact_type WHERE name = 'permission')
  ; 
-- function children
INSERT INTO pde.artifact_type_relationship(parent_artifact_type_id, child_artifact_type_id) SELECT 
  (SELECT id from pde.artifact_type WHERE name = 'function')
  ,(SELECT id from pde.artifact_type WHERE name = 'comment')
  ; 
INSERT INTO pde.artifact_type_relationship(parent_artifact_type_id, child_artifact_type_id) SELECT 
  (SELECT id from pde.artifact_type WHERE name = 'function')
  ,(SELECT id from pde.artifact_type WHERE name = 'permission')
  ; 


INSERT INTO pde.pde_project(name) SELECT 'Todo';
INSERT INTO pde.release(  
  project_id,
  name,
  status
)
SELECT
  id
  ,'0001.0001.0002'
  ,'Planned'
FROM pde.pde_project where name = 'Todo';

INSERT INTO pde.major(project_id, revision) SELECT id, 1 from pde.pde_project where name = 'Todo';
INSERT INTO pde.minor(major_id, revision, release_id) SELECT
  (SELECT id from pde.major where revision = 1)
  ,1
  ,(SELECT id from pde.release where name = '0001.0001.0002')
;

INSERT INTO pde.schema(  
  name
  ,release_id
)
SELECT
  'todo'
  ,(SELECT id from pde.release where name = '0001.0001.0002')
;

INSERT INTO pde.artifact(  
  name
  ,artifact_type_id
  ,description
  ,schema_id
)
SELECT
  'example_table'
  ,(select id from pde.artifact_type where name = 'table')
  ,'a description of your mom''s table'
  ,(SELECT id from pde.schema where name = 'todo')
;

INSERT INTO pde.artifact(  
  name
  ,artifact_type_id
  ,description
  ,schema_id
)
SELECT
  'example_function'
  ,(select id from pde.artifact_type where name = 'function')
  ,'a description of your mom''s function'
  ,(SELECT id from pde.schema where name = 'todo')
;

INSERT INTO pde.artifact(  
  name
  ,artifact_type_id
  ,description
  ,schema_id
)
SELECT
  'example_trigger'
  ,(select id from pde.artifact_type where name = 'trigger')
  ,'a description of your mom''s trigger'
  ,(SELECT id from pde.schema where name = 'todo')
;

INSERT INTO pde.artifact_relationship(
  parent_artifact_id
  ,child_artifact_id
)
SELECT
  (select id from pde.artifact where name = 'example_table')
  ,(select id from pde.artifact where name = 'example_trigger')
;

INSERT INTO pde.patch(minor_id, revision, ddl, working_ddl, artifact_id) SELECT 
  id 
  ,1
  ,'select your mom;'
  ,'select your mom;'
  ,(select id from pde.artifact where name = 'example_table')
  from pde.minor where revision = 1;
INSERT INTO pde.patch(minor_id, revision, ddl, working_ddl, artifact_id) SELECT 
  id
  ,2 
  ,'function your mom;'
  ,'function your mom;'
  ,(select id from pde.artifact where name = 'example_function')
  from pde.minor where revision = 1;
INSERT INTO pde.patch(minor_id, revision, ddl, working_ddl, artifact_id) SELECT 
  id
  ,3
  ,'trigger your mom;'
  ,'trigger your mom;'
  ,(select id from pde.artifact where name = 'example_trigger')
  from pde.minor where revision = 1;
