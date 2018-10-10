------------------------------------------------
-- release_ddl_up
------------------------------------------------
CREATE OR REPLACE FUNCTION pde.release_ddl_up(
  release pde.release
)
  RETURNS text AS
$BODY$
DECLARE
  _ddl_up text;
  _minor pde.minor;
  _patch pde.patch;
  _artifact pde.artifact;
  _artifact_type pde.artifact_type;
BEGIN
  _ddl_up := '-- phile-de generated script
  -- action:   up
  -- release:  ' || release.number || '  
  ';
  
  for _minor in
    select * from pde.minor where release_id = release.id
  loop
    _ddl_up := _ddl_up || '
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--    minor patch set: ' || _minor.name || ' - ' || _minor.number || '  
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
';

    for _patch in
      select * from pde.patch where minor_id = _minor.id
    loop
      select * into _artifact from pde.artifact where id = _patch.artifact_id;
      select * into _artifact_type from pde.artifact_type where id = _artifact.artifact_type_id;

      _ddl_up := _ddl_up || '
  -------------------------------------------------------------------------------
  --    patch:             ' || _patch.number || '
  --    artifact type:     ' || _artifact_type.name || '
  --    artifact:          ' || _artifact.name || '
  -------------------------------------------------------------------------------
  ';
      _ddl_up := _ddl_up || '

    ' || _patch.ddl_up || '

      ';

      _ddl_up := _ddl_up || '
  ---------------------------------------------------------------------------------
  --    end patch: ' || _patch.number || '
  ---------------------------------------------------------------------------------

  ';
    end loop;

    _ddl_up := _ddl_up || '
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--    end minor patch set: ' || _minor.name || ' - ' || _minor.number || '  
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
';
  end loop;

  return _ddl_up;
END;
$BODY$
  LANGUAGE plpgsql STABLE
  COST 100;

------------------------------------------------
-- release_ddl_down
------------------------------------------------
CREATE OR REPLACE FUNCTION pde.release_ddl_down(
  release pde.release
)
  RETURNS text AS
$BODY$
DECLARE
  _ddl_down text;
  _minor pde.minor;
  _patch pde.patch;
  _artifact pde.artifact;
  _artifact_type pde.artifact_type;
BEGIN
  _ddl_down := '-- phile-de generated script
  -- action:   down
  -- release:  ' || release.number || '  
  ';
  
  for _minor in
    select * from pde.minor where release_id = release.id order by revision desc
  loop
    _ddl_down := _ddl_down || '
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--    minor patch set: ' || _minor.name || ' - ' || _minor.number || '  
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
';

    for _patch in
      select * from pde.patch where minor_id = _minor.id order by revision desc
    loop
      select * into _artifact from pde.artifact where id = _patch.artifact_id;
      select * into _artifact_type from pde.artifact_type where id = _artifact.artifact_type_id;

      _ddl_down := _ddl_down || '
  ---------------------------------------------------------------------------------
  --    patch:             ' || _patch.number || '
  --    artifact type:     ' || _artifact_type.name || '
  --    artifact:          ' || _artifact.name || '
  ---------------------------------------------------------------------------------
  ';
      _ddl_down := _ddl_down || '

    ' || _patch.ddl_down || '

      ';

      _ddl_down := _ddl_down || '
---------------------------------------------------------------------------------
--      end patch: ' || _patch.number || '
---------------------------------------------------------------------------------

  ';
    end loop;

    _ddl_down := _ddl_down || '
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--    end minor patch set: ' || _minor.name || ' - ' || _minor.number || '  
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
';
  end loop;

  return _ddl_down;
END;
$BODY$
  LANGUAGE plpgsql STABLE
  COST 100;


select *
from pde.minor
limit 1
;

select *
from pde.release release 
where status = 'DEVELOPMENT'
;

select pde.release_ddl_down(release)
from pde.release release where status = 'DEVELOPMENT'
;