
DROP FUNCTION IF EXISTS pde.import_project(jsonb);
------------------------------------------------
-- pde.import_project
------------------------------------------------
CREATE OR REPLACE FUNCTION pde.import_project(
  _project_info jsonb
)
  RETURNS jsonb AS
$BODY$
DECLARE
  _name text;
  _artifact_type_json jsonb;
  _artifact_type pde.artifact_type;
  _patch_type_json jsonb;
  _patch_type pde.patch_type;
  _project pde.pde_project;
  _schema_json jsonb;
  _schema pde.schema;
  _artifact_json jsonb;
  _artifact pde.artifact;
  _release_json jsonb;
  _release pde.release;
  _major_json jsonb;
  _major pde.major;
  _minor_json jsonb;
  _minor pde.minor;
  _patch_json jsonb;
  _patch pde.patch;
  _artifact_type_mappings jsonb;
  _patch_type_mappings jsonb;
  _artifact_type_id bigint;
  _patch_type_id bigint;
  _mapping jsonb;
  _result jsonb;
BEGIN
  _result := '{}';
  _artifact_type_mappings := '[]';
  _patch_type_mappings := '[]';

  --RAISE EXCEPTION '_result: %', _result;

  -- pre-process artifactTypes and patchTypes to properly hook up id values
  for _artifact_type_json in
    select jsonb_array_elements(_project_info->'artifactTypes')
  loop
    _name := _artifact_type_json->>'name'::text;
    SELECT * INTO _artifact_type FROM pde.artifact_type WHERE name = _name;

    IF _artifact_type.id IS NULL THEN
      INSERT INTO pde.artifact_type(id, name, properties) 
        SELECT _artifact_type_json->>'id', _artifact_type_json->>'name', _artifact_type_json->>'properties' 
        RETURNING * INTO _artifact_type;
    END IF;
    _mapping := ('[{"old": ' || (_artifact_type_json->>'id') || ', "new": ' || (_artifact_type.id) || '}]');
    _artifact_type_mappings := _artifact_type_mappings ||  (_mapping);

    for _patch_type_json in
      select jsonb_array_elements((_artifact_type_json->'patchTypes')->'nodes')
    loop
      RAISE NOTICE '  patch_type: %', _patch_type_json->'name';
      _name := _patch_type_json->>'name'::text;
      SELECT * INTO _patch_type FROM pde.patch_type WHERE name = _name;

      IF _patch_type.id IS NULL THEN
        -- _artifact_type_id := _patch_type_json->>'artifact_type_id';
        _artifact_type_id := (
          SELECT mapping->>'new'
          FROM jsonb_array_elements(_artifact_type_mappings) mapping
          WHERE mapping->>'old' = _patch_type_json->>'artifact_type_id'
        );
        INSERT INTO pde.patch(
          id
          ,name
          ,key
          ,ddl_up_template
          ,ddl_down_template
          ,properties
          ,execution_order
          ,artifact_type_id
          ,action
          ,documentation_url
        ) 
          SELECT 
            _patch_type_json->>'id'
            ,_patch_type_json->>'name'
            ,_patch_type_json->>'key' 
            ,_patch_type_json->>'ddl_up_template' 
            ,_patch_type_json->>'ddl_down_template' 
            ,_patch_type_json->>'properties' 
            ,_patch_type_json->>'execution_order' 
            ,_artifact_type_id 
            ,_patch_type_json->>'action'
            ,_patch_type_json->>'documentation_url'
          RETURNING * INTO _patch_type;
      END IF;
      _mapping := ('[{"old": ' || (_patch_type_json->>'id') || ', "new": ' || (_patch_type.id) || '}]');
      _patch_type_mappings := _patch_type_mappings ||  (_mapping);
    end loop;
  end loop;

  -- project
  RAISE NOTICE 'project name: %', (_project_info->'project')->>'name';
  SELECT * INTO _project FROM pde.pde_project WHERE name = ((_project_info->'project')->>'name')::text;

  IF _project.id IS NOT NULL THEN
    RAISE EXCEPTION 'Project already exists: %', (_project_info->'project')->'name';
  END IF;

  INSERT INTO pde.pde_project(
    id
    ,name
  )
  SELECT
    ((_project_info->'project')->>'id')::bigint
    ,(_project_info->'project')->>'name'
  RETURNING * INTO _project
  ;

  -- schemas
  for _schema_json in
    select jsonb_array_elements(((_project_info->'project')->'schemata')->'nodes')
  loop
    RAISE NOTICE 'schema: %', _schema_json->'name';
    INSERT INTO pde.schema(
      id
      ,name
      ,project_id
    )
    SELECT
      (_schema_json->>'id')::bigint
      ,_schema_json->>'name'
      ,_project.id
    RETURNING * INTO _schema
    ;

    -- artifacts
    for _artifact_json in
      select jsonb_array_elements((_schema_json->'artifacts')->'nodes')
    loop
      _artifact_type_id := (
        SELECT mapping->>'new'
        FROM jsonb_array_elements(_artifact_type_mappings) mapping
        WHERE mapping->>'old' = _artifact_json->>'artifactTypeId'
      );

      INSERT INTO pde.artifact(
        id
        ,name
        ,project_id
        ,schema_id
        ,artifact_type_id
        ,description
      )
      SELECT
        (_artifact_json->>'id')::bigint
        ,_artifact_json->>'name'
        ,_project.id
        ,_schema.id
        ,_artifact_type_id
        ,_artifact_json->>'description'
      RETURNING * INTO _artifact
      ;      
    end loop;
  end loop;


  -- releases
  for _release_json in
    select jsonb_array_elements(((_project_info->'project')->'releases')->'nodes')
  loop
    -- RAISE NOTICE 'release: %', jsonb_pretty(_release_json);
    -- RAISE NOTICE 'release: % - %', _release_json->>'id', _release_json->>'name';
    -- RAISE NOTICE '_project: %', _project.id;
    RAISE NOTICE 'parent: %', _release_json->>'parent_release_id';
    INSERT INTO pde.release(
      id
      ,project_id
      ,name
      ,status
      ,number
      ,parent_release_id
      ,locked
    )
    SELECT
      (_release_json->>'id')::bigint
      ,_project.id::bigint
      ,_release_json->>'name'
      ,(_release_json->>'status')::pde.release_status
      ,_release_json->>'number'
      ,(_release_json->>'parent_release_id')::bigint
      ,(_release_json->>'locked')::boolean
    RETURNING * INTO _release
    ;

    -- minors
    for _minor_json in
      select jsonb_array_elements((_release_json->'minors')->'nodes')
    loop
      _major_json := _minor_json->'major';
      SELECT * INTO _major FROM pde.major WHERE id = (_major_json->>'id')::bigint;
      IF _major.id IS NULL THEN
        INSERT INTO pde.major(
          id
          ,project_id
          ,name
          ,revision
        )
        SELECT
          (_major_json->>'id')::bigint
          ,_project.id::bigint
          ,_major_json->>'name'
          ,(_major_json->>'revision')::integer
        RETURNING * INTO _major
        ;
      END IF;

      SELECT * INTO _minor FROM pde.minor WHERE id = (_minor_json->>'id')::bigint;
      IF _minor.id IS NULL THEN
        INSERT INTO pde.minor(
          id
          ,major_id
          ,release_id
          ,project_id
          ,number
          ,name
          ,revision
          ,locked
        )
        SELECT
          (_minor_json->>'id')::bigint
          ,_major.id::bigint
          ,_release.id::bigint
          ,_project.id::bigint
          ,_minor_json->>'number'
          ,_minor_json->>'name'
          ,(_minor_json->>'revision')::integer
          ,(_minor_json->>'locked')::boolean
        RETURNING * INTO _minor
        ;
      END IF;

      -- patches
      for _patch_json in
        select jsonb_array_elements((_minor_json->'patches')->'nodes')
      loop
        RAISE NOTICE '  patch: %', _patch_json->'number';
        RAISE NOTICE '  patch: %', jsonb_pretty(_patch_json);
        _patch_type_id := (
          SELECT mapping->>'new'
          FROM jsonb_array_elements(_patch_type_mappings) mapping
          WHERE mapping->>'old' = _patch_json->>'patchTypeId'
        );
        INSERT INTO pde.patch(
          id
          ,minor_id
          ,artifact_id
          ,revision
          ,number
          ,ddl_up
          ,ddl_down
          ,locked
          ,project_id
          ,patch_type_id
        )
        SELECT
          (_patch_json->>'id')::bigint
          ,_minor.id
          ,(_patch_json->>'artifactId')::bigint
          ,(_patch_json->>'revision')::bigInt
          ,_patch_json->>'number'
          ,_patch_json->>'ddlUp'
          ,_patch_json->>'ddlDown'
          ,(_patch_json->>'locked')::boolean
          ,_project.id
          ,_patch_type_id
        RETURNING *
        INTO _patch
        ;

      end loop;
    end loop;
  end loop;

  -- major

  -- minor

  -- patches
 
  return _result;
END;
$BODY$
  LANGUAGE plpgsql volatile
  COST 100;

-- \echo -------------------------------------------------------------
-- \echo -------------------------------------------------------------
-- \echo -------------------------------------------------------------
-- \echo -------------------------------------------------------------
-- select id, name from pde.pde_project;
-- select id, name from pde.schema;
-- select id, name from pde.artifact;
-- select id, name from pde.release
-- \echo -------------------------------------------------------------
-- \echo -------------------------------------------------------------
-- \echo -------------------------------------------------------------
-- \echo -------------------------------------------------------------

-- begin;

-- select pde.import_project('{"artifactTypes":[{"id":"1886559442418271233","name":"schema","properties":{},"requiresSchema":false,"patchTypes":{"nodes":[{"id":"1886559442460214274","name":"create schema","key":"schema-create","ddlUpTemplate":"CREATE SCHEMA {{schemaName}};","ddlDownTemplate":"DROP SCHEMA {{schemaName}} CASCADE;","action":"CREATE","documentationUrl":"https://www.graphile.org/postgraphile/namespaces/","executionOrder":20,"properties":{},"__typename":"PatchType"}],"__typename":"PatchTypesConnection"},"__typename":"ArtifactType"},{"id":"1886559442493768707","name":"type","properties":{},"requiresSchema":true,"patchTypes":{"nodes":[{"id":"1886559442502157316","name":"create type","key":"type-create","ddlUpTemplate":"CREATE TYPE {{schemaName}}.{{typeName}} AS ENUM\n(\n  ''foo'',\n  ''bar''\n);\n","ddlDownTemplate":"DROP TYPE {{{schemaName}}.{typeName}} CASCADE;","action":"CREATE","documentationUrl":"https://www.postgresql.org/docs/9.6/static/sql-createtype.html","executionOrder":30,"properties":{},"__typename":"PatchType"},{"id":"1886559442518934533","name":"modify type","key":"type-modify","ddlUpTemplate":"ALTER TYPE ucs.ucs_import_result ADD VALUE ''Linked'';","ddlDownTemplate":"","action":"APPEND","documentationUrl":"","executionOrder":33,"properties":{},"__typename":"PatchType"}],"__typename":"PatchTypesConnection"},"__typename":"ArtifactType"},{"id":"1886559442527323142","name":"table","properties":{},"requiresSchema":true,"patchTypes":{"nodes":[{"id":"1886559442544100359","name":"create table","key":"table-create","ddlUpTemplate":"\nCREATE TABLE {{schemaName}}.{{tableName}} (\n  id bigint UNIQUE NOT NULL DEFAULT shard_1.id_generator(),\n  CONSTRAINT pk_{{schemaName}}_{{tableName}} PRIMARY KEY (id)\n);\n","ddlDownTemplate":"DROP TABLE {{schemaName}}.{{tableName}} CASCADE;","action":"CREATE","documentationUrl":"https://www.graphile.org/postgraphile/tables/","executionOrder":40,"properties":{},"__typename":"PatchType"},{"id":"1886559442560877576","name":"add column(s)","key":"table-add-column","ddlUpTemplate":"ALTER TABLE {{schemaName}}.{{tableName}} ADD COLUMN {{columnName}} {{typeName}};","ddlDownTemplate":"ALTER TABLE {{schemaName}}.{{tableName}} DROP COLUMN {{columnName}};","action":"APPEND","documentationUrl":"https://www.graphile.org/postgraphile/relations/","executionOrder":50,"properties":{},"__typename":"PatchType"},{"id":"1886559442577654793","name":"add foreign key(s)","key":"table-add-foreign-key","ddlUpTemplate":"ALTER TABLE {{localSchemaName}}.{{localTableName}} ADD CONSTRAINT fk_{{localTableName}}_{{targetTableName}} FOREIGN KEY ({{localColumnName}}) REFERENCES {{targetSchemaName}}.{{targetTableName}} (targetColumnName);","ddlDownTemplate":"ALTER TABLE {{localSchemaName}}.{{localTableName}} DROP CONSTRAINT fk_{{localTableName}}_{{targetTableName}};","action":"APPEND","documentationUrl":"https://www.graphile.org/postgraphile/postgresql-indexes/","executionOrder":60,"properties":{},"__typename":"PatchType"},{"id":"1886559442594432010","name":"add index(es)","key":"table-add-index","ddlUpTemplate":"CREATE INDEX IF NOT EXISTS idx_{{schemaName}}_{{tableName}}_{{columnName}} ON {{schemaName}}_{{tableName}}({{columnName}});","ddlDownTemplate":"DROP INDEX idx_{{schemaName}}_{{tableName}}_{{columnName}};","action":"APPEND","documentationUrl":"","executionOrder":70,"properties":{},"__typename":"PatchType"},{"id":"1886559442602820619","name":"add computed column","key":"table-add-computed-column","ddlUpTemplate":"\ncreate or replace function {{schemaName}}.{{tableName}}_{{columnName}}(u {{schemaName}}_{{tableName}})\nreturns {{returnType}} as $$\n  -- this, you must do\n$$ language sql stable;\n","ddlDownTemplate":"drop function {{schemaName}}.{{tableName}}_{{columnName}}({{schemaName}}_{{tableName}});","action":"APPEND","documentationUrl":"https://www.graphile.org/postgraphile/computed-columns/","executionOrder":90,"properties":{},"__typename":"PatchType"},{"id":"1886559442619597836","name":"modify computed column","key":"table-modify-computed-column","ddlUpTemplate":"\ncreate or replace function {{schemaName}}.{{tableName}}_{{columnName}}(u {{schemaName}}_{{tableName}})\nreturns {{returnType}} as $$\n  -- this, you must do\n$$ language sql stable;\n","ddlDownTemplate":"","action":"APPEND","documentationUrl":"https://www.graphile.org/postgraphile/computed-columns/","executionOrder":93,"properties":{},"__typename":"PatchType"},{"id":"1886559442636375053","name":"manage smart comments","key":"table-smart-comments","ddlUpTemplate":"-- https://www.graphile.org/postgraphile/smart-comments/","ddlDownTemplate":"-- https://www.graphile.org/postgraphile/smart-comments/","action":"APPEND","documentationUrl":"https://www.graphile.org/postgraphile/smart-comments/","executionOrder":103,"properties":{},"__typename":"PatchType"},{"id":"1886559442653152270","name":"manage security","key":"table-security","ddlUpTemplate":"\n-- https://www.graphile.org/postgraphile/security/\n REVOKE ALL PRIVILEGES ON {{schemaName}}_{{tableName}} FROM PUBLIC;\n ALTER TABLE {{schemaName}}_{{tableName}} DISABLE ROW LEVEL SECURITY;\n DROP POLICY IF EXISTS all_{{schemaName}}_{{tableName}} ON {{schemaName}}_{{tableName}};\n\n GRANT select, update, delete ON TABLE {{schemaName}}_{{tableName}} TO {{roleName}};\n \n ALTER TABLE {{schemaName}}_{{tableName}} ENABLE ROW LEVEL SECURITY;\n CREATE POLICY all_{{schemaName}}_{{tableName}} ON {{schemaName}}_{{tableName}} FOR SELECT\n USING {{rlsClause}};\n","ddlDownTemplate":"","action":"APPEND","documentationUrl":"https://www.graphile.org/postgraphile/security/","executionOrder":110,"properties":{},"__typename":"PatchType"},{"id":"1886559442661540879","name":"manage trigger","key":"table-triggers","ddlUpTemplate":"\n  CREATE FUNCTION {{triggerSchemaName}}.{{functionName}}() RETURNS trigger AS $$\n  BEGIN\n    NEW.updated_at = current_timestamp;\n    RETURN NEW;\n  END; $$ LANGUAGE plpgsql;\n\n  CREATE TRIGGER tg_{{action}}_{{tableSchemaName}}_{{tableName}}\n    BEFORE INSERT OR UPDATE ON {{tableSchemaName}}_{{tableName}}\n    FOR EACH ROW\n    EXECUTE PROCEDURE {{triggerSchemaName}}.{{functionName}}();\n","ddlDownTemplate":"\nDROP TRIGGER tg_{{action}}_{{tableSchemaName}}_{{tableName}};\nDROP FUNCTION {{triggerSchemaName}}.{{functionName}}();\n","action":"APPEND","documentationUrl":"https://www.postgresql.org/docs/9.6/static/triggers.html","executionOrder":120,"properties":{},"__typename":"PatchType"}],"__typename":"PatchTypesConnection"},"__typename":"ArtifactType"},{"id":"1886559442669929488","name":"function","properties":{},"requiresSchema":true,"patchTypes":{"nodes":[{"id":"1886559442686706705","name":"create function","key":"function-create","ddlUpTemplate":"\ncreate or replace function {{schemaName}}.{{functionName}}(\n  -- add parameters here\n)\nreturns {{returnType}} as $$\n  -- this, you must do\n$$ language sql stable;\n","ddlDownTemplate":"drop function {{schemaName}}.{{functionName}}(\n  -- add parameter types here\n);","action":"CREATE","documentationUrl":"https://www.graphile.org/postgraphile/custom-mutations/","executionOrder":130,"properties":{},"__typename":"PatchType"},{"id":"1886559442695095314","name":"modify function","key":"function-modify","ddlUpTemplate":"\ncreate or replace function {{schemaName}}.{{functionName}}(\n  -- add parameters here\n)\nreturns {{returnType}} as $$\n  -- this, you must do\n$$ language sql stable;\n","ddlDownTemplate":"drop function {{schemaName}}.{{functionName}}(\n  -- add parameter types here\n);","action":"APPEND","documentationUrl":"https://www.graphile.org/postgraphile/custom-mutations/","executionOrder":140,"properties":{},"__typename":"PatchType"},{"id":"1886559442711872531","name":"manage smart comments","key":"function-comments","ddlUpTemplate":"-- https://www.graphile.org/postgraphile/smart-comments/","ddlDownTemplate":"","action":"APPEND","documentationUrl":"https://www.graphile.org/postgraphile/smart-comments/","executionOrder":150,"properties":{},"__typename":"PatchType"},{"id":"1886559442728649748","name":"manage security","key":"function-security","ddlUpTemplate":"\n-- https://www.graphile.org/postgraphile/security/\nGRANT EXECUTE ON FUNCTION {{schemaName}}.{{functionName}}() TO {{roleName}};\n","ddlDownTemplate":"\nREVOKE EXECUTE ON FUNCTION {{schemaName}}.{{functionName}}() FROM {{roleName}};\n","action":"APPEND","documentationUrl":"https://www.graphile.org/postgraphile/security/","executionOrder":160,"properties":{},"__typename":"PatchType"}],"__typename":"PatchTypesConnection"},"__typename":"ArtifactType"},{"id":"1886559442737038357","name":"custom script","properties":{},"requiresSchema":true,"patchTypes":{"nodes":[{"id":"1886559442745426966","name":"create custom script","key":"custom-script","ddlUpTemplate":"-- do anything you want here","ddlDownTemplate":"-- undo anything you want here","action":"CREATE","documentationUrl":"https://www.graphile.org/postgraphile/introduction/","executionOrder":170,"properties":{},"__typename":"PatchType"}],"__typename":"PatchTypesConnection"},"__typename":"ArtifactType"}],"project":{"id":"1886559526354682903","name":"cards","schemata":{"nodes":[{"id":"1886559760480732188","name":"cards","artifacts":{"nodes":[{"id":"1886559760665281565","name":"cards","description":"tacos","artifactTypeId":"1886559442418271233","__typename":"Artifact"},{"id":"1886562983249708063","name":"suit","description":"tacos","artifactTypeId":"1886559442527323142","__typename":"Artifact"},{"id":"1886563572599751713","name":"deck","description":"tacos","artifactTypeId":"1886559442527323142","__typename":"Artifact"},{"id":"1886569168136832036","name":"deal_hand","description":"tacos","artifactTypeId":"1886559442669929488","__typename":"Artifact"}],"__typename":"ArtifactsConnection"},"__typename":"Schema"}],"__typename":"SchemataConnection"},"releases":{"nodes":[{"id":"1886559526405014553","name":"Next","number":"0001.0002.0000.development","status":"DEVELOPMENT","projectId":"1886559526354682903","locked":false,"minors":{"nodes":[{"id":"1886559617605960731","number":"0001.0001","name":"structure","revision":1,"locked":false,"major":{"id":"1886559617564017690","name":"0001","revision":1,"__typename":"Major"},"patches":{"nodes":[{"id":"1886559760866608158","number":"0001.0001.0000","revision":0,"ddlUp":"CREATE SCHEMA cards;","ddlDown":"DROP SCHEMA cards CASCADE;","locked":false,"artifactId":"1886559760665281565","patchTypeId":"1886559442460214274","__typename":"Patch"},{"id":"1886562983417480224","number":"0001.0001.0001","revision":1,"ddlUp":"\nCREATE TABLE cards.suit (\n  id bigint UNIQUE NOT NULL DEFAULT shard_1.id_generator(),\n  name text,\n  CONSTRAINT pk_cards_suit PRIMARY KEY (id)\n);\n","ddlDown":"DROP TABLE cards.suit CASCADE;","locked":false,"artifactId":"1886562983249708063","patchTypeId":"1886559442544100359","__typename":"Patch"},{"id":"1886563572784301090","number":"0001.0001.0002","revision":2,"ddlUp":"\nCREATE TABLE cards.deck (\n  id bigint UNIQUE NOT NULL DEFAULT shard_1.id_generator(),\n  name text,\n  CONSTRAINT pk_cards_deck PRIMARY KEY (id)\n);\n","ddlDown":"DROP TABLE cards.deck CASCADE;","locked":false,"artifactId":"1886563572599751713","patchTypeId":"1886559442544100359","__typename":"Patch"}],"__typename":"PatchesConnection"},"__typename":"Minor"},{"id":"1886568989157491747","number":"0001.0002","name":"cards functions","revision":2,"locked":false,"major":{"id":"1886559617564017690","name":"0001","revision":1,"__typename":"Major"},"patches":{"nodes":[{"id":"1886569168346547237","number":"0001.0002.0000","revision":0,"ddlUp":"\ncreate or replace function cards.deal_hand(\n  -- add parameters here\n)\nreturns cards[] as $$\n  -- this, you must do\n$$ language sql stable;\n","ddlDown":"drop function cards.deal_hand(\n  -- add parameter types here\n);","locked":false,"artifactId":"1886569168136832036","patchTypeId":"1886559442686706705","__typename":"Patch"}],"__typename":"PatchesConnection"},"__typename":"Minor"}],"__typename":"MinorsConnection"},"__typename":"Release"},{"id":"1886559526388237336","name":"FUTURE","number":"9999.9999.9999","status":"FUTURE","projectId":"1886559526354682903","locked":false,"minors":{"nodes":[],"__typename":"MinorsConnection"},"__typename":"Release"}],"__typename":"ReleasesConnection"},"__typename":"PdeProject"}}')
-- ;


-- select id, name from pde.pde_project;
-- select id, name from pde.schema;
-- select id, name from pde.artifact;
-- select id, name from pde.release;
-- select id, name from pde.major;
-- select id, name from pde.minor;
-- select id, number from pde.patch;

-- rollback;


-- \echo -------------------------------------------------------------
-- \echo -------------------------------------------------------------
-- \echo -------------------------------------------------------------
-- \echo -------------------------------------------------------------
-- select id, name from pde.pde_project;
-- select id, name from pde.schema;
-- select id, name from pde.artifact;
-- select id, name from pde.release;
-- select id, name from pde.major;
-- select id, name from pde.minor;
-- select id, number from pde.patch;
