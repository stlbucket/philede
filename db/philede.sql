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

--||--
CREATE FUNCTION pde.fn_create_project_releases() RETURNS trigger AS $$
BEGIN
  INSERT INTO pde.release(
    project_id
    ,name
    ,number
    ,status
  )
  VALUES
    (
      NEW.id
      ,'Future'
      ,'9999.9999.9999'
      ,'Future'
    ),
    (
      NEW.id
      ,'Next'
      ,'Development'
      ,'Development'
    )
  ;
  RETURN NEW;
END; $$ LANGUAGE plpgsql;
--||--
CREATE TRIGGER tg_after_insert_pde_project
  AFTER INSERT ON pde.pde_project
  FOR EACH ROW
  EXECUTE PROCEDURE pde.fn_create_project_releases();


------------------------------------------------
-- release
------------------------------------------------
CREATE TYPE pde.release_status AS ENUM
  (
    'Current',           -- singleton.  release to staging will move to Historic any current Staging release and clone current Testing release
    'Staging',           -- singleton.  release to staging will move to Deprecated any current Staging release and clone current Testing release
    'Testing',           -- singleton.  release to testing will move to Deprecated any current Testing release and clone current Development release
    'Development',       -- singleton.  the current release being worked on
    'Stashed',           -- collection. a place to park releases to support hot-fixes, dev work while testing another release, etc.
    'Future',            -- singleton.  deferred items are placed in this bucket and later promoted to Development
    'StagingLocked',     -- singleton.  when a staging release is created, the associated Development release becomes StagingLocked
    'Archived',          -- collection. old Development releases
    'Historic',          -- collection. old Current releasees.  should have 1:1 correspondence to Archived releases and they could be checksummed 
    'TestingDeprecated',  -- collection. releases discarded during Staging
    'StagingDeprecated'  -- collection. releases discarded during Testing
  );

CREATE TABLE pde.release (
  id bigint UNIQUE NOT NULL DEFAULT shard_1.id_generator(),
  project_id bigint NOT NULL,
  name text NOT NULL,
  number text NOT NULL,
  status pde.release_status NOT NULL DEFAULT 'Development',
  ddl_up text NOT NULL DEFAULT '<ddl>',
  ddl_down text NOT NULL DEFAULT '<ddl>',
  parent_release_id bigint NULL,
  locked boolean not null default false,
  CONSTRAINT pk_pde_release PRIMARY KEY (id),
  CHECK (name <> '')
);
ALTER TABLE pde.release ADD CONSTRAINT fk_release_project FOREIGN KEY (project_id) REFERENCES pde.pde_project (id);
ALTER TABLE pde.release ADD CONSTRAINT fk_release_parent FOREIGN KEY (parent_release_id) REFERENCES pde.release (id);

------------------------------------------------
-- major
------------------------------------------------
CREATE TABLE pde.major (
  id bigint UNIQUE NOT NULL DEFAULT shard_1.id_generator(),
  name text NOT NULL,
  project_id bigint NOT NULL,
  revision integer,
  CONSTRAINT pk_pde_major PRIMARY KEY (id),
  CHECK (name <> '')
);
ALTER TABLE pde.major ADD CONSTRAINT fk_major_project FOREIGN KEY (project_id) REFERENCES pde.pde_project (id);

------------------------------------------------
-- minor
------------------------------------------------
CREATE TABLE pde.minor (
  id bigint UNIQUE NOT NULL DEFAULT shard_1.id_generator(),
  name text NOT NULL,
  major_id bigint NOT NULL,
  release_id bigint NOT NULL,
  revision integer,
  number text NOT NULL,
  CONSTRAINT pk_pde_minor PRIMARY KEY (id),
  CHECK (number <> ''),
  CHECK (name <> '')
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
  ddl_up_template text,
  ddl_down_template text,
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
  CONSTRAINT pk_schema PRIMARY KEY (id)
);

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
  ddl_up text NOT NULL DEFAULT '<ddl>',
  ddl_up_working text NOT NULL DEFAULT '<ddl>',
  ddl_down text NOT NULL DEFAULT '<ddl>',
  ddl_down_working text NOT NULL DEFAULT '<ddl>',
  number text NOT NULL,
  locked boolean NOT NULL default false,
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
CREATE TRIGGER tg_timestamp_before_update_patch
  BEFORE INSERT OR UPDATE ON pde.patch
  FOR EACH ROW
  EXECUTE PROCEDURE pde.fn_timestamp_update_patch();
--||--
CREATE FUNCTION pde.fn_update_release_number() RETURNS trigger AS $$
BEGIN
  WITH max_patch_info AS (
    SELECT 
      max(p.id) max_patch_id
      ,r.id release_id
    FROM pde.patch p
    JOIN pde.minor m ON p.minor_id = m.id
    JOIN pde.release r ON r.id = m.release_id
    WHERE r.id = (SELECT release_id FROM pde.minor WHERE id = NEW.minor_id)
    GROUP BY r.id
  )
  UPDATE pde.release
  SET number = (
    SELECT 
      lpad(ma.revision::text,4,'0') || '.' || lpad(mi.revision::text,4,'0') || '.' || lpad(pa.revision::text,4,'0')
    FROM max_patch_info mpi
    JOIN pde.patch pa ON mpi.max_patch_id = pa.id
    JOIN pde.minor mi ON pa.minor_id = mi.id
    JOIN pde.major ma ON mi.major_id = ma.id
  )
  FROM max_patch_info mpi
  WHERE id = mpi.release_id
  AND locked = false
  AND status = 'Development'
  ;

  RETURN NEW;
END; $$ LANGUAGE plpgsql;
--||--
CREATE TRIGGER tg_timestamp_after_update_patch
  AFTER INSERT OR UPDATE ON pde.patch
  FOR EACH ROW
  EXECUTE PROCEDURE pde.fn_update_release_number();

------------------------------------------------
-- test
------------------------------------------------
CREATE TYPE pde.test_type AS ENUM
   (
    'PgTap',
    'GraphQL'
    );

CREATE TABLE pde.test (
  id bigint UNIQUE NOT NULL DEFAULT shard_1.id_generator(),
  type pde.test_type NOT NULL DEFAULT 'GraphQL',
  name text,
  script text NOT NULL DEFAULT '<test ddl>',
  script_working text NOT NULL DEFAULT '<test ddl>',
  minor_id bigint NOT NULL,
  CONSTRAINT pk_pde_test PRIMARY KEY (id)
);
ALTER TABLE pde.test ADD CONSTRAINT fk_test_minor FOREIGN KEY (minor_id) REFERENCES pde.minor (id);

-- ------------------------------------------------
-- -- pde_project_schemas
-- ------------------------------------------------
-- create or replace function pde.pde_project_schemas(p pde.pde_project)
-- returns setof pde.schema as $$
--   select s.*
--   from pde.schema s
--   join pde.release r on r.id = s.release_id
--   where r.project_id = p.id
--   ;
-- $$ language sql stable;

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
-- release_display_name
------------------------------------------------
create or replace function pde.release_display_name(release pde.release)
returns text as $$
  select r.name || ' - ' || r.status::text
  from pde.release r
  ;
$$ language sql stable;

------------------------------------------------
-- minor_schemas
------------------------------------------------
create or replace function pde.minor_schemas(minor pde.minor)
returns setof pde.schema as $$
  select s.*
  from pde.schema s
  join pde.artifact a on a.schema_id = s.id
  join pde.patch p on p.artifact_id = a.id and p.minor_id = minor.id
  ;
$$ language sql stable;

------------------------------------------------
-- defer_minor
------------------------------------------------
CREATE OR REPLACE FUNCTION pde.defer_minor(minor_id bigint)
  RETURNS pde.minor AS
$BODY$
DECLARE
  _minor pde.minor;
  _release pde.release;
BEGIN
  SELECT *
  INTO _minor
  FROM pde.minor
  WHERE id = minor_id
  ;

  IF _minor.id IS NULL THEN
    RAISE EXCEPTION 'Cannot defer because minor does not exist: %', minor_id;
  END IF;

  SELECT *
  INTO _release
  FROM pde.release
  WHERE id = _minor.release_id
  ;

  IF _release.status != 'Development' THEN
    RAISE EXCEPTION 'Cannot defer because patch is not in development release: %', minor_id;
  END IF;

  SELECT *
  INTO _release
  FROM pde.release
  WHERE project_id = _release.project_id
  AND status = 'Future'
  ;

  IF _release.status != 'Future' THEN
    RAISE EXCEPTION 'Cannot defer because future release does not exist: %', minor_id;
  END IF;
  
  UPDATE pde.minor SET
    release_id = _release.id
  WHERE id = minor_id
  RETURNING *
  INTO _minor
  ;

  return _minor;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT SECURITY DEFINER
  COST 100;

------------------------------------------------
-- promote_minor
------------------------------------------------
CREATE OR REPLACE FUNCTION pde.promote_minor(minor_id bigint)
  RETURNS pde.minor AS
$BODY$
DECLARE
  _minor pde.minor;
  _release pde.release;
BEGIN
  SELECT *
  INTO _minor
  FROM pde.minor
  WHERE id = minor_id
  ;

  IF _minor.id IS NULL THEN
    RAISE EXCEPTION 'Cannot promote because minor does not exist: %', minor_id;
  END IF;

  SELECT *
  INTO _release
  FROM pde.release
  WHERE id = _minor.release_id
  ;

  IF _release.status != 'Future' THEN
    RAISE EXCEPTION 'Cannot promote because patch is not in future release: %', _patch_id;
  END IF;

  UPDATE pde.minor SET
    release_id = (SELECT id FROM pde.release WHERE project_id = _release.project_id AND status = 'Development')
  WHERE id = minor_id
  RETURNING *
  INTO _minor
  ;

  return _minor;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT SECURITY DEFINER
  COST 100;


------------------------------------------------
-- dummy data
------------------------------------------------
INSERT INTO pde.artifact_type(name, execution_order) SELECT 'extension', 1; 
INSERT INTO pde.artifact_type(name, execution_order) SELECT 'schema', 2; 
INSERT INTO pde.artifact_type(name, execution_order) SELECT 'type', 3; 
INSERT INTO pde.artifact_type(name, execution_order) SELECT 'table', 4; 
INSERT INTO pde.artifact_type(name, execution_order) SELECT 'foreign key', 5; 
INSERT INTO pde.artifact_type(name, execution_order) SELECT 'index', 6; 
INSERT INTO pde.artifact_type(name, execution_order) SELECT 'trigger', 7; 
INSERT INTO pde.artifact_type(name, execution_order) SELECT 'function', 8; 
INSERT INTO pde.artifact_type(name, execution_order) SELECT 'view', 9; 
INSERT INTO pde.artifact_type(name, execution_order) SELECT 'comment', 10; 
INSERT INTO pde.artifact_type(name, execution_order) SELECT 'permission', 11; 

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

INSERT INTO pde.major(project_id, revision, name) SELECT id, 1, 'Major Name' from pde.pde_project where name = 'Todo';

INSERT INTO pde.minor(major_id, revision, release_id, name) SELECT
  (SELECT id from pde.major where revision = 1)
  ,1
  ,(SELECT id from pde.release where status = 'Development')
  ,'Todo Schema'
;
INSERT INTO pde.minor(major_id, revision, release_id, name) SELECT
  (SELECT id from pde.major where revision = 1)
  ,2
  ,(SELECT id from pde.release where status = 'Development')
  ,'First Feature'
;
INSERT INTO pde.minor(major_id, revision, release_id, name) SELECT
  (SELECT id from pde.major where revision = 1)
  ,3
  ,(SELECT id from pde.release where status = 'Development')
  ,'Second Feature'
;

INSERT INTO pde.schema(  
  name
)
SELECT
  'todo'
;

INSERT INTO pde.artifact(  
  name
  ,artifact_type_id
  ,description
  ,schema_id
)
SELECT
  'todo schema'
  ,(select id from pde.artifact_type where name = 'schema')
  ,'the todo schema'
  ,(SELECT id from pde.schema where name = 'todo')
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
  ,'a description of your table'
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
  ,'a description of your function'
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
  ,'a description of your trigger'
  ,(SELECT id from pde.schema where name = 'todo')
;

INSERT INTO pde.artifact(  
  name
  ,artifact_type_id
  ,description
  ,schema_id
)
SELECT
  'second_function'
  ,(select id from pde.artifact_type where name = 'function')
  ,'a description of another function'
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

INSERT INTO pde.patch(minor_id, revision, ddl_up, ddl_up_working, artifact_id) SELECT 
  id 
  ,1
  ,'CREATE SCHEMA todo;'
  ,'CREATE SCHEMA todo;'
  ,(select id from pde.artifact where name = 'todo schema')
  from pde.minor where revision = 1;
INSERT INTO pde.patch(minor_id, revision, ddl_up, ddl_up_working, artifact_id) SELECT 
  id 
  ,1
  ,'CREATE TABLE STATEMENT;'
  ,'CREATE TABLE STATEMENT;'
  ,(select id from pde.artifact where name = 'example_table')
  from pde.minor where revision = 2;
INSERT INTO pde.patch(minor_id, revision, ddl_up, ddl_up_working, artifact_id) SELECT 
  id
  ,2 
  ,'CREATE FUNCTION STATEMENT;'
  ,'CREATE FUNCTION STATEMENT;'
  ,(select id from pde.artifact where name = 'example_function')
  from pde.minor where revision = 2;
INSERT INTO pde.patch(minor_id, revision, ddl_up, ddl_up_working, artifact_id) SELECT 
  id
  ,3
  ,'CREATE TRIGGER STATEMENT;'
  ,'CREATE TRIGGER STATEMENT;'
  ,(select id from pde.artifact where name = 'example_trigger')
  from pde.minor where revision = 2;
INSERT INTO pde.patch(minor_id, revision, ddl_up, ddl_up_working, artifact_id) SELECT 
  id
  ,1
  ,'second function;'
  ,'second function;'
  ,(select id from pde.artifact where name = 'second_function')
  from pde.minor where revision = 3;

INSERT INTO pde.test(name, minor_id, type) SELECT 'GQL-1', id, 'GraphQL' FROM pde.minor;
INSERT INTO pde.test(name, minor_id, type) SELECT 'GQL-2', id, 'GraphQL' FROM pde.minor;
INSERT INTO pde.test(name, minor_id, type) SELECT 'PGT-1', id, 'PgTap' FROM pde.minor;
INSERT INTO pde.test(name, minor_id, type) SELECT 'PGT-2', id, 'PgTap' FROM pde.minor;
