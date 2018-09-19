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
  AND status = 'Staging';

  IF _staging_release.id IS NULL THEN
    RAISE EXCEPTION 'NO STAGING RELEASE FOR PROJECT ID: %', _project_id;
  END IF;

RAISE NOTICE 'WTF';
  SELECT *
  INTO _parent_release
  FROM pde.release
  WHERE id = _staging_release.parent_release_id;

RAISE NOTICE 'WTF';
  UPDATE pde.release SET
    status = 'Historic'
  WHERE status = 'Current'
  AND project_id = _project_id
  ;

RAISE NOTICE 'WTF';
  UPDATE pde.release SET
    status = 'Current'
    ,number = _parent_release.number
  WHERE id = _staging_release.id
  RETURNING *
  INTO _current_release
  ;

RAISE NOTICE 'WTF';
  UPDATE pde.release SET
    status = 'Archived'
  WHERE id = _parent_release.id
  ;

RAISE NOTICE 'WTF';
  PERFORM pde.ensure_development_release(_project_id);

RAISE NOTICE 'WTF';
  return _current_release;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT SECURITY DEFINER
  COST 100;


begin;
select pde.release_to_current(1871902195952124946);
rollback;