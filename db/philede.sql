drop schema if exists pde cascade;

CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE SCHEMA pde;

-- artifact type
CREATE TABLE pde.artifact_type (
  id uuid UNIQUE NOT NULL DEFAULT uuid_generate_v1(),
  name text NOT NULL,
  display_order integer NOT NULL,
  execution_order integer NOT NULL,
  properties jsonb NOT NULL DEFAULT '{}'::jsonb,
  CONSTRAINT pk_pde_artifact_ype PRIMARY KEY (id)
);
--||--
INSERT INTO pde.artifact_type(name, display_order, execution_order) SELECT 'extension', 0, 0; 
INSERT INTO pde.artifact_type(name, display_order, execution_order) SELECT 'table', 0, 0; 
INSERT INTO pde.artifact_type(name, display_order, execution_order) SELECT 'view', 0, 0; 
INSERT INTO pde.artifact_type(name, display_order, execution_order) SELECT 'function', 0, 0; 
INSERT INTO pde.artifact_type(name, display_order, execution_order) SELECT 'schema', 0, 0; 
INSERT INTO pde.artifact_type(name, display_order, execution_order) SELECT 'trigger', 0, 0; 
INSERT INTO pde.artifact_type(name, display_order, execution_order) SELECT 'index', 0, 0; 
INSERT INTO pde.artifact_type(name, display_order, execution_order) SELECT 'comment', 0, 0; 

--artifact
CREATE TABLE pde.artifact (
  id uuid UNIQUE NOT NULL DEFAULT uuid_generate_v1(),
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL,
  name text NOT NULL,
  artifact_type_id UUID NOT NULL,
  ddl text,
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

--working_artifact
CREATE TABLE pde.working_artifact (
  id uuid UNIQUE NOT NULL DEFAULT uuid_generate_v1(),
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL,
  name text NOT NULL,
  artifact_id uuid not null unique,
  artifact_type_id uuid NOT NULL,
  ddl text,
  CONSTRAINT pk_working_artifact PRIMARY KEY (id)
);

  --||--
  CREATE FUNCTION pde.fn_timestamp_update_working_artifact() RETURNS trigger AS $$
  BEGIN
    NEW.updated_at = current_timestamp;
    RETURN NEW;
  END; $$ LANGUAGE plpgsql;
  --||--
  CREATE TRIGGER tg_timestamp_update_working_artifact
    BEFORE INSERT OR UPDATE ON pde.working_artifact
    FOR EACH ROW
    EXECUTE PROCEDURE pde.fn_timestamp_update_working_artifact();


ALTER TABLE pde.working_artifact ADD CONSTRAINT fk_working_artifact_type FOREIGN KEY (artifact_type_id) REFERENCES pde.artifact_type (id);
ALTER TABLE pde.working_artifact ADD CONSTRAINT fk_working_artifact_artifact FOREIGN KEY (artifact_id) REFERENCES pde.artifact (id);

-- get working artifact
CREATE OR REPLACE FUNCTION pde.get_working_artifact(
  _artifact_id uuid
)
  RETURNS pde.working_artifact AS
$BODY$
DECLARE
  _working_artifact pde.working_artifact;
  _artifact pde.artifact;
BEGIN
  SELECT *
  INTO _working_artifact
  FROM pde.working_artifact
  WHERE artifact_id = _artifact_id;

  IF _working_artifact.id IS NULL THEN
    SELECT *
    INTO _artifact
    FROM pde.artifact
    WHERE id = _artifact_id;

    IF _artifact.id IS NULL THEN
      RAISE EXCEPTION 'NO ARTIFACT FOR THIS ID: %', _artifact_id USING ERRCODE = 'PD001';
    END IF;

    INSERT INTO pde.working_artifact(
      artifact_type_id
      ,artifact_id
      ,name
      ,ddl
    )
    SELECT
      _artifact.artifact_type_id
      ,_artifact.id
      ,_artifact.name
      ,_artifact.ddl
    RETURNING *
    INTO _working_artifact;
  END IF;

  RETURN _working_artifact;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT SECURITY DEFINER
  COST 100;

-- commit working artifact
CREATE OR REPLACE FUNCTION pde.commit_working_artifact(
  _id uuid
)
  RETURNS pde.artifact AS
$BODY$
DECLARE
  _working_artifact pde.working_artifact;
  _artifact pde.artifact;
BEGIN
  SELECT *
  INTO _working_artifact
  FROM pde.working_artifact
  WHERE id = _id;

  UPDATE pde.artifact
  SET ddl = _working_artifact.ddl
  WHERE id = _working_artifact.artifact_id
  RETURNING * 
  INTO _artifact;

  DELETE FROM pde.working_artifact WHERE id = _id;

  return _artifact;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT SECURITY DEFINER
  COST 100;


-- dummy data
INSERT INTO pde.artifact(  
  name
  ,artifact_type_id
  ,ddl
)
SELECT
  'example_table'
  ,(select id from pde.artifact_type where name = 'table')
  ,'select your_mom;'
;


INSERT INTO pde.artifact(  
  name
  ,artifact_type_id
  ,ddl
)
SELECT
  'example_function'
  ,(select id from pde.artifact_type where name = 'function')
  ,'function your_mom;'
;


INSERT INTO pde.working_artifact(  
  name
  ,artifact_id
  ,artifact_type_id
  ,ddl
)
SELECT
  'example_function'
  ,(select id from pde.artifact where name = 'example_function')
  ,(select id from pde.artifact_type where name = 'function')
  ,'function your_mom in progress;'
;