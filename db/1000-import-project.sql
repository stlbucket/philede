DROP FUNCTION IF EXISTS pde.import_project(jsonb);
------------------------------------------------
-- pde.import_project
------------------------------------------------
CREATE OR REPLACE FUNCTION pde.import_project(
  _project jsonb
)
  RETURNS jsonb AS
$BODY$
DECLARE
  _result jsonb;
BEGIN
  _result := '{}';

  -- pre-process artifactTypes and patchTypes to properly hook up id values

  -- project

  -- schemas

  -- artifacts

  -- releases

  -- major

  -- minor

  -- patches
 
  return _project;
END;
$BODY$
  LANGUAGE plpgsql volatile
  COST 100;



