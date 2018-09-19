------------------------------------------------
-- release_to_test
------------------------------------------------
CREATE OR REPLACE FUNCTION pde.release_to_testing(_project_id bigint)
  RETURNS pde.release AS
$BODY$
DECLARE
  _new_testing_release pde.release;
  _development_release pde.release;
  _test_release_number integer;
BEGIN
  UPDATE pde.release SET
    status = 'Deprecated'
  WHERE status = 'Testing'
  AND project_id = _project_id
  ;

  SELECT *
  INTO _development_release
  FROM pde.release
  WHERE project_id = _project_id
  AND status = 'Development';

  SELECT count(*) INTO _test_release_number FROM pde.release WHERE parent_release_id = _development_release.id;

  IF _development_release.id IS NULL THEN
    RAISE EXCEPTION 'NO DEVELOPMENT RELEASE FOR PROJECT ID: %', _project_id;
  END IF;

  INSERT INTO pde.release(
    name
    ,number
    ,status
    ,ddl_up
    ,ddl_down
    ,project_id
    ,parent_release_id
  )
  SELECT
    _development_release.name
    ,_development_release.number||'.test.'||(_test_release_number+1)
    ,'Testing'
    ,_development_release.ddl_up
    ,_development_release.ddl_down
    ,_project_id
    ,_development_release.id
  RETURNING *
  INTO _new_testing_release
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
    ,_new_testing_release.id
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
    (SELECT id FROM pde.minor WHERE release_id = _new_testing_release.id AND number = m.number)
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

  return _new_testing_release;
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
