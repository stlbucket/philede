------------------------------------------------
-- move_to_staging
------------------------------------------------
CREATE OR REPLACE FUNCTION pde.move_to_staging(_project_id bigint)
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
  AND status = 'Testing';

  IF _testing_release.id IS NULL THEN
    RAISE EXCEPTION 'NO TESTING RELEASE FOR PROJECT ID: %', _project_id;
  END IF;

  SELECT *
  INTO _parent_release
  FROM pde.release
  WHERE id = _testing_release.parent_release_id;

  UPDATE pde.release SET
    status = 'StagingDeprecated'
  WHERE status = 'Staging'
  AND project_id = _project_id
  ;

  _staging_release_count := (SELECT count(*) FROM pde.release WHERE parent_release_id = _parent_release.id AND status = 'StagingDeprecated');

  UPDATE pde.release SET
    status = 'Staging'
    ,number = (_parent_release.number||'.staging.'||(_staging_release_count+1)::text)
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
    status = 'TestingDeprecated'
  WHERE status = 'Testing'
  AND project_id = _project_id
  ;

  SELECT *
  INTO _development_release
  FROM pde.release
  WHERE project_id = _project_id
  AND status = 'Development';

  IF _development_release.id IS NULL THEN
    RAISE EXCEPTION 'NO DEVELOPMENT RELEASE FOR PROJECT ID: %', _project_id;
  END IF;

  _testing_release_count := (SELECT count(*) FROM pde.release WHERE parent_release_id = _development_release.id AND status = 'TestingDeprecated');

  INSERT INTO pde.release(
    name
    ,number
    ,status
    ,ddl_up
    ,ddl_down
    ,project_id
    ,parent_release_id
    ,locked
  )
  SELECT
    _development_release.name
    ,(_development_release.number||'.testing.'||(_testing_release_count+1)::text)
    ,'Testing'
    ,_development_release.ddl_up
    ,_development_release.ddl_down
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
  )
  SELECT
    major_id
    ,revision
    ,number
    ,name
    ,_testing_release.id
  FROM pde.minor
  WHERE release_id = _development_release.id
  ;

  INSERT INTO pde.patch(
    minor_id
    ,revision
    ,artifact_id
    ,number
    ,ddl_up
    ,ddl_up_working
    ,ddl_down
    ,ddl_down_working
    ,locked
  )
  SELECT
    (SELECT id FROM pde.minor WHERE release_id = _testing_release.id AND number = m.number)
    ,p.revision
    ,p.artifact_id
    ,p.number
    ,p.ddl_up
    ,p.ddl_up_working
    ,p.ddl_down
    ,p.ddl_down_working
    ,true
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
  WHERE status = 'Development'
  ;

  IF _release.id IS NULL THEN
    RAISE EXCEPTION 'Cannot stash because there is no development release';
  END IF;
  
  UPDATE pde.release SET
    status = 'Stashed'
  WHERE id = minor_id
  RETURNING *
  INTO _release
  ;

  return _release;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT SECURITY DEFINER
  COST 100;
