------------------------------------------------
-- build_patch_new_schema
------------------------------------------------
CREATE OR REPLACE FUNCTION pde.build_patch_new_schema(
    _minor_id bigint
    ,_name text
  )
  RETURNS pde.patch AS
$BODY$
DECLARE
  _revision integer;
  _artifact_type pde._artifact_type;
  _minor pde.minor;
  _schema pde.schema;
  _artifact pde.artifact;
  _patch pde.patch;
BEGIN
  IF _name IS NULL OR _name = '' THEN
    RAISE EXCEPTION 'Name cannot be empty';
  END IF;

  SELECT *
  INTO _minor
  FROM pde.minor
  WHERE id = _minor_id
  ;

  IF _minor.id IS NULL THEN
    RAISE EXCEPTION 'Minor does not exist';
  END IF;

  SELECT *
  INTO _schema
  FROM pde.schema
  WHERE id = _artifact_type_id
  ;

  IF _artifact_type.id IS NULL THEN
    RAISE EXCEPTION 'Artifact type does not exists';
  END IF;

  _revision := (SELECT count(*) FROM pde.patch WHERE minor_id = _minor.id) + 1;

  return _patch;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT SECURITY DEFINER
  COST 100;


------------------------------------------------
-- build_patch_new_artifact
------------------------------------------------
CREATE OR REPLACE FUNCTION pde.build_patch_new_artifact(
    _minor_id bigint
    ,_artifact_type_id bigint
    ,_schema_id bigint
    ,_name text
  )
  RETURNS pde.patch AS
$BODY$
DECLARE
  _revision integer;
  _artifact_type pde._artifact_type;
  _minor pde.minor;
  _schema pde.schema;
  _artifact pde.artifact;
  _patch pde.patch;
BEGIN
  IF _name IS NULL OR _name = '' THEN
    RAISE EXCEPTION 'Name cannot be empty';
  END IF;

  SELECT *
  INTO _minor
  FROM pde.minor
  WHERE id = _minor_id
  ;

  IF _minor.id IS NULL THEN
    RAISE EXCEPTION 'Minor does not exist';
  END IF;

  SELECT *
  INTO _artifact_type
  FROM pde.artifact_type
  WHERE id = _artifact_type_id
  ;

  IF _artifact_type.id IS NULL THEN
    RAISE EXCEPTION 'Artifact type does not exists';
  END IF;

  _revision := (SELECT count(*) FROM pde.patch WHERE minor_id = _minor.id) + 1;

  return _patch;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT SECURITY DEFINER
  COST 100;

------------------------------------------------
-- build_patch_existing_artifact
------------------------------------------------
CREATE OR REPLACE FUNCTION pde.build_patch_existing_artifact(
    _minor_id bigint
    ,_artifact_id bigint
  )
  RETURNS pde.patch AS
$BODY$
DECLARE
  _revision integer;
  _minor pde.minor;
  _artifact pde.artifact;
  _patch pde.patch;
BEGIN
  SELECT *
  INTO _minor
  FROM pde.minor
  WHERE id = _minor_id
  ;

  IF _minor.id IS NULL THEN
    RAISE EXCEPTION 'Minor does not exist';
  END IF;

  SELECT *
  INTO _artifact
  FROM pde.artifact
  WHERE id = _artifact_id
  ;

  IF _artifact.id IS NULL THEN
    RAISE EXCEPTION 'No artifact exists';
  END IF;

  _revision := (SELECT count(*) FROM pde.patch WHERE minor_id = _minor.id) + 1;


  return _patch;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT SECURITY DEFINER
  COST 100;


------------------------------------------------
-- build_minor
------------------------------------------------
CREATE OR REPLACE FUNCTION pde.build_minor(
    _release_id bigint
    ,_name text
  )
  RETURNS pde.minor AS
$BODY$
DECLARE
  _release pde.release;
  _current_major pde.major;
  _revision integer;
  _minor pde.minor;
BEGIN
  IF _name IS NULL OR _name = '' THEN
    RAISE EXCEPTION 'Name cannot be empty';
  END IF;

  SELECT *
  INTO _release
  FROM pde.release
  WHERE id = _release_id
  ;

  IF _release.id IS NULL THEN
    RAISE EXCEPTION 'Release does not exist';
  END IF;

  SELECT *
  INTO _current_major
  FROM pde.major
  WHERE project_id = _release.project_id
  AND id = (SELECT max(id) from pde.major where project_id = _release.project_id)
  ;

  IF _current_major.id IS NULL THEN
    INSERT INTO pde.major(project_id, revision, name) SELECT _release.project_id, 1, '0001' RETURNING * INTO _current_major;
  END IF;

  _revision := (SELECT count(*) FROM pde.minor WHERE major_id = _current_major.id and release_id = _release.id) + 1;

  INSERT INTO pde.minor(
    major_id
    ,revision
    ,release_id
    ,name
    ,project_id
    ,locked
  ) 
  SELECT
    _current_major.id
    ,_revision
    ,_release.id
    ,_name
    ,_release.project_id
    ,false
  RETURNING *
  INTO _minor;

  return _minor;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT SECURITY DEFINER
  COST 100;


------------------------------------------------
-- build_development_release
------------------------------------------------
CREATE OR REPLACE FUNCTION pde.build_development_release(
    _project_id bigint
    ,_name text
  )
  RETURNS pde.release AS
$BODY$
DECLARE
  _development_release pde.release;
BEGIN
  IF _name IS NULL OR _name = '' THEN
    RAISE EXCEPTION 'Name cannot be empty';
  END IF;

  SELECT *
  INTO _development_release
  FROM pde.release
  WHERE project_id = _project_id
  AND status = 'DEVELOPMENT';

  IF _development_release.id IS NOT NULL THEN
    RAISE EXCEPTION 'This project already has a development release';
  END IF;

  INSERT INTO pde.release(
    name
    ,number
    ,status
    ,project_id
    ,parent_release_id
    ,locked
  )
  SELECT
    _name
    ,'N/A.development'
    ,'DEVELOPMENT'
    ,_project_id
    ,null
    ,false
  RETURNING *
  INTO _development_release
  ;

  return _development_release;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT SECURITY DEFINER
  COST 100;


------------------------------------------------
-- release_to_current
------------------------------------------------
CREATE OR REPLACE FUNCTION pde.release_to_current(_project_id bigint)
  RETURNS pde.release AS
$BODY$
DECLARE
  _staging_release pde.release;
  _current_release pde.release;
  _parent_release pde.release;
BEGIN
  SELECT *
  INTO _staging_release
  FROM pde.release
  WHERE project_id = _project_id
  AND status = 'STAGING';

  IF _staging_release.id IS NULL THEN
    RAISE EXCEPTION 'NO STAGING RELEASE FOR PROJECT ID: %', _project_id;
  END IF;

  SELECT *
  INTO _parent_release
  FROM pde.release
  WHERE id = _staging_release.parent_release_id;

  UPDATE pde.release SET
    status = 'HISTORIC'
  WHERE status = 'CURRENT'
  AND project_id = _project_id
  ;

  UPDATE pde.release SET
    status = 'CURRENT'
    ,number = replace(_parent_release.number, '.development', '')
    ,locked = true
  WHERE id = _staging_release.id
  RETURNING *
  INTO _current_release
  ;

  UPDATE pde.release SET
    status = 'ARCHIVED'
  WHERE id = _parent_release.id
  ;

--  PERFORM pde.build_development_release(_project_id);

  return _current_release;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT SECURITY DEFINER
  COST 100;

------------------------------------------------
-- release_to_staging
------------------------------------------------
CREATE OR REPLACE FUNCTION pde.release_to_staging(_project_id bigint)
  RETURNS pde.release AS
$BODY$
DECLARE
  _staging_release pde.release;
  _testing_release pde.release;
  _parent_release pde.release;
  _staging_release_count integer;
BEGIN
  SELECT *
  INTO _testing_release
  FROM pde.release
  WHERE project_id = _project_id
  AND status = 'TESTING';

  IF _testing_release.id IS NULL THEN
    RAISE EXCEPTION 'NO TESTING RELEASE FOR PROJECT ID: %', _project_id;
  END IF;

  SELECT *
  INTO _parent_release
  FROM pde.release
  WHERE id = _testing_release.parent_release_id;

  UPDATE pde.release SET
    status = 'STAGING_DEPRECATED'
    ,locked = true
  WHERE status = 'STAGING'
  AND project_id = _project_id
  ;

  _staging_release_count := (SELECT count(*) FROM pde.release WHERE parent_release_id = _parent_release.id); -- AND status = 'STAGING_DEPRECATED');

  UPDATE pde.release SET
    status = 'STAGING'
    ,number = replace (_testing_release.number, 'testing', 'staging')
  WHERE id = _testing_release.id
  RETURNING *
  INTO _staging_release
  ;

  return _staging_release;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT SECURITY DEFINER
  COST 100;

------------------------------------------------
-- release_to_test
------------------------------------------------
CREATE OR REPLACE FUNCTION pde.release_to_testing(_project_id bigint)
  RETURNS pde.release AS
$BODY$
DECLARE
  _testing_release pde.release;
  _development_release pde.release;
  _testing_release_count integer;
BEGIN
  UPDATE pde.release SET
    status = 'TESTING_DEPRECATED'
  WHERE status = 'TESTING'
  AND project_id = _project_id
  ;

  SELECT *
  INTO _development_release
  FROM pde.release
  WHERE project_id = _project_id
  AND status = 'DEVELOPMENT';

  IF _development_release.id IS NULL THEN
    RAISE EXCEPTION 'NO DEVELOPMENT RELEASE FOR PROJECT ID: %', _project_id;
  END IF;

  _testing_release_count := (SELECT count(*) FROM pde.release WHERE parent_release_id = _development_release.id); -- AND status = 'TESTING_DEPRECATED');

  INSERT INTO pde.release(
    name
    ,number
    ,status
    ,project_id
    ,parent_release_id
    ,locked
  )
  SELECT
    _development_release.name
    ,(replace(_development_release.number, 'development', 'testing')||'.'||(_testing_release_count+1)::text)
    ,'TESTING'
    ,_project_id
    ,_development_release.id
    ,true
  RETURNING *
  INTO _testing_release
  ;

  INSERT INTO pde.minor(
    major_id
    ,revision
    ,number
    ,name
    ,release_id
    ,project_id
    ,locked
  )
  SELECT
    major_id
    ,revision
    ,number
    ,name
    ,_testing_release.id
    ,_testing_release.project_id
    ,true
  FROM pde.minor
  WHERE release_id = _development_release.id
  ;

  INSERT INTO pde.patch(
    minor_id
    ,revision
    ,artifact_id
    ,number
    ,ddl_up
    ,ddl_down
    ,patch_type_id
    ,locked
    ,project_id
  )
  SELECT
    (SELECT id FROM pde.minor WHERE release_id = _testing_release.id AND number = m.number)
    ,p.revision
    ,p.artifact_id
    ,p.number
    ,p.ddl_up
    ,p.ddl_down
    ,p.patch_type_id
    ,true
    ,_testing_release.project_id
  FROM pde.patch p
  JOIN pde.minor m on m.id = p.minor_id
  WHERE m.release_id = _development_release.id
  ;

  return _testing_release;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT SECURITY DEFINER
  COST 100;

------------------------------------------------
-- stash
------------------------------------------------
CREATE OR REPLACE FUNCTION pde.stash()
  RETURNS pde.release AS
$BODY$
DECLARE
  _release pde.release;
BEGIN
  SELECT *
  INTO _release
  FROM pde.release
  WHERE status = 'DEVELOPMENT'
  ;

  IF _release.id IS NULL THEN
    RAISE EXCEPTION 'Cannot stash because there is no development release';
  END IF;
  
  UPDATE pde.release SET
    status = 'STASHED'
  WHERE id = minor_id
  RETURNING *
  INTO _release
  ;

  return _release;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT SECURITY DEFINER
  COST 100;
