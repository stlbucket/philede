------------------------------------------------
-- seed data
------------------------------------------------
-- INSERT INTO pde.artifact_type(name) SELECT 'extension'; 
-- INSERT INTO pde.patch_type(name, artifact_type_id, execution_order, key, properties, action, ddl_up_template, ddl_down_template, documentation_url) SELECT 'install extension', (SELECT id FROM pde.artifact_type WHERE NAME = 'extension'), 1, 'extension-install', '{}', 'Create';

INSERT INTO pde.artifact_type(name, requires_schema) SELECT 'schema', false; 
INSERT INTO pde.patch_type(name, artifact_type_id, execution_order, key, properties, action, ddl_up_template, ddl_down_template, documentation_url) SELECT 'create schema', (SELECT id FROM pde.artifact_type WHERE NAME = 'schema'), 20, 'schema-create', '{}', 'Create'
 ,'CREATE SCHEMA {{schemaName}};'
 ,'DROP SCHEMA {{schemaName}} CASCADE;'
 ,'https://www.graphile.org/postgraphile/namespaces/'
 ;

INSERT INTO pde.artifact_type(name) SELECT 'type'; 
INSERT INTO pde.patch_type(name, artifact_type_id, execution_order, key, properties, action, ddl_up_template, ddl_down_template, documentation_url) SELECT 'create type', (SELECT id FROM pde.artifact_type WHERE NAME = 'type'), 30, 'type-create', '{}', 'Create'
 ,'CREATE TYPE {{schemaName}}.{{typeName}} AS ENUM
(
  ''foo'',
  ''bar''
);
'
,'DROP TYPE {{{schemaName}}.{typeName}} CASCADE;'
,'https://www.postgresql.org/docs/9.6/static/sql-createtype.html'
;
INSERT INTO pde.patch_type(name, artifact_type_id, execution_order, key, properties, action, ddl_up_template, ddl_down_template, documentation_url) SELECT 'modify type', (SELECT id FROM pde.artifact_type WHERE NAME = 'type'), 33, 'type-modify', '{}', 'Append'
 ,'ALTER TYPE ucs.ucs_import_result ADD VALUE ''Linked'';'
 ,''
 ,''
;

INSERT INTO pde.artifact_type(name) SELECT 'table'; 
INSERT INTO pde.patch_type(name, artifact_type_id, execution_order, key, properties, action, ddl_up_template, ddl_down_template, documentation_url) SELECT 'create table', (SELECT id FROM pde.artifact_type WHERE NAME = 'table'), 40, 'table-create', '{}', 'Create'
  ,'
CREATE TABLE {{schemaName}}.{{tableName}} (
  id bigint UNIQUE NOT NULL DEFAULT shard_1.id_generator(),
  CONSTRAINT pk_{{schemaName}}_{{tableName}} PRIMARY KEY (id)
);
'
,'DROP TABLE {{schemaName}}.{{tableName}} CASCADE;'
,'https://www.graphile.org/postgraphile/tables/'
;

INSERT INTO pde.patch_type(name, artifact_type_id, execution_order, key, properties, action, ddl_up_template, ddl_down_template, documentation_url) SELECT 'add column(s)', (SELECT id FROM pde.artifact_type WHERE NAME = 'table'), 50, 'table-add-column', '{}', 'Append'
 ,'ALTER TABLE {{schemaName}}.{{tableName}} ADD COLUMN {{columnName}} {{typeName}};'
 ,'ALTER TABLE {{schemaName}}.{{tableName}} DROP COLUMN {{columnName}};'
 ,'https://www.graphile.org/postgraphile/relations/'
;
INSERT INTO pde.patch_type(name, artifact_type_id, execution_order, key, properties, action, ddl_up_template, ddl_down_template, documentation_url) SELECT 'add foreign key(s)', (SELECT id FROM pde.artifact_type WHERE NAME = 'table'), 60, 'table-add-foreign-key', '{}', 'Append'
 ,'ALTER TABLE {{localSchemaName}}.{{localTableName}} ADD CONSTRAINT fk_{{localTableName}}_{{targetTableName}} FOREIGN KEY ({{localColumnName}}) REFERENCES {{targetSchemaName}}.{{targetTableName}} (targetColumnName);'
 ,'ALTER TABLE {{localSchemaName}}.{{localTableName}} DROP CONSTRAINT fk_{{localTableName}}_{{targetTableName}};'
,'https://www.graphile.org/postgraphile/postgresql-indexes/'
;
INSERT INTO pde.patch_type(name, artifact_type_id, execution_order, key, properties, action, ddl_up_template, ddl_down_template, documentation_url) SELECT 'add index(es)', (SELECT id FROM pde.artifact_type WHERE NAME = 'table'), 70, 'table-add-index', '{}', 'Append'
 ,'CREATE INDEX IF NOT EXISTS idx_{{schemaName}}_{{tableName}}_{{columnName}} ON {{schemaName}}_{{tableName}}({{columnName}});'
 ,'DROP INDEX idx_{{schemaName}}_{{tableName}}_{{columnName}};'
,''
;
INSERT INTO pde.patch_type(name, artifact_type_id, execution_order, key, properties, action, ddl_up_template, ddl_down_template, documentation_url) SELECT 'add computed column', (SELECT id FROM pde.artifact_type WHERE NAME = 'table'), 90, 'table-add-computed-column', '{}', 'Append'
 ,'
create or replace function {{schemaName}}.{{tableName}}_{{columnName}}(u {{schemaName}}_{{tableName}})
returns {{returnType}} as $$
  -- this, you must do
$$ language sql stable;
'
,'drop function {{schemaName}}.{{tableName}}_{{columnName}}({{schemaName}}_{{tableName}});'
,'https://www.graphile.org/postgraphile/computed-columns/'
;
INSERT INTO pde.patch_type(name, artifact_type_id, execution_order, key, properties, action, ddl_up_template, ddl_down_template, documentation_url) SELECT 'modify computed column', (SELECT id FROM pde.artifact_type WHERE NAME = 'table'), 93, 'table-modify-computed-column', '{}', 'Append'
 ,'
create or replace function {{schemaName}}.{{tableName}}_{{columnName}}(u {{schemaName}}_{{tableName}})
returns {{returnType}} as $$
  -- this, you must do
$$ language sql stable;
'
,''
,'https://www.graphile.org/postgraphile/computed-columns/'
;
INSERT INTO pde.patch_type(name, artifact_type_id, execution_order, key, properties, action, ddl_up_template, ddl_down_template, documentation_url) SELECT 'manage smart comments', (SELECT id FROM pde.artifact_type WHERE NAME = 'table'), 103, 'table-smart-comments', '{}', 'Append'
 ,'-- https://www.graphile.org/postgraphile/smart-comments/'
 ,'-- https://www.graphile.org/postgraphile/smart-comments/'
 ,'https://www.graphile.org/postgraphile/smart-comments/'
;
INSERT INTO pde.patch_type(name, artifact_type_id, execution_order, key, properties, action, ddl_up_template, ddl_down_template, documentation_url) SELECT 'manage security', (SELECT id FROM pde.artifact_type WHERE NAME = 'table'), 110, 'table-security', '{}', 'Append'
 ,'
-- https://www.graphile.org/postgraphile/security/
 REVOKE ALL PRIVILEGES ON {{schemaName}}_{{tableName}} FROM PUBLIC;
 ALTER TABLE {{schemaName}}_{{tableName}} DISABLE ROW LEVEL SECURITY;
 DROP POLICY IF EXISTS all_{{schemaName}}_{{tableName}} ON {{schemaName}}_{{tableName}};

 GRANT select, update, delete ON TABLE {{schemaName}}_{{tableName}} TO {{roleName}};
 
 ALTER TABLE {{schemaName}}_{{tableName}} ENABLE ROW LEVEL SECURITY;
 CREATE POLICY all_{{schemaName}}_{{tableName}} ON {{schemaName}}_{{tableName}} FOR SELECT
 USING {{rlsClause}};
'
,''
,'https://www.graphile.org/postgraphile/security/'
;
INSERT INTO pde.patch_type(name, artifact_type_id, execution_order, key, properties, action, ddl_up_template, ddl_down_template, documentation_url) SELECT 'manage trigger', (SELECT id FROM pde.artifact_type WHERE NAME = 'table'), 120, 'table-triggers', '{}', 'Append'
 ,'
  CREATE FUNCTION {{triggerSchemaName}}.{{functionName}}() RETURNS trigger AS $$
  BEGIN
    NEW.updated_at = current_timestamp;
    RETURN NEW;
  END; $$ LANGUAGE plpgsql;

  CREATE TRIGGER tg_{{action}}_{{tableSchemaName}}_{{tableName}}
    BEFORE INSERT OR UPDATE ON {{tableSchemaName}}_{{tableName}}
    FOR EACH ROW
    EXECUTE PROCEDURE {{triggerSchemaName}}.{{functionName}}();
'
,'
DROP TRIGGER tg_{{action}}_{{tableSchemaName}}_{{tableName}};
DROP FUNCTION {{triggerSchemaName}}.{{functionName}}();
'
,'https://www.postgresql.org/docs/9.6/static/triggers.html'
;


INSERT INTO pde.artifact_type(name) SELECT 'function';
INSERT INTO pde.patch_type(name, artifact_type_id, execution_order, key, properties, action, ddl_up_template, ddl_down_template, documentation_url) SELECT 'create function', (SELECT id FROM pde.artifact_type WHERE NAME = 'function'), 130, 'function-create', '{}', 'Create'
 ,'
create or replace function {{schemaName}}.{{functionName}}(
  -- add parameters here
)
returns {{returnType}} as $$
  -- this, you must do
$$ language sql stable;
'
,'drop function {{schemaName}}.{{functionName}}(
  -- add parameter types here
);'
,'https://www.graphile.org/postgraphile/custom-mutations/'
;
INSERT INTO pde.patch_type(name, artifact_type_id, execution_order, key, properties, action, ddl_up_template, ddl_down_template, documentation_url) SELECT 'modify function', (SELECT id FROM pde.artifact_type WHERE NAME = 'function'), 140, 'function-modify', '{}', 'Append'
 ,'
create or replace function {{schemaName}}.{{functionName}}(
  -- add parameters here
)
returns {{returnType}} as $$
  -- this, you must do
$$ language sql stable;
'
,'drop function {{schemaName}}.{{functionName}}(
  -- add parameter types here
);'
,'https://www.graphile.org/postgraphile/custom-mutations/'
;
INSERT INTO pde.patch_type(name, artifact_type_id, execution_order, key, properties, action, ddl_up_template, ddl_down_template, documentation_url) SELECT 'manage smart comments', (SELECT id FROM pde.artifact_type WHERE NAME = 'function'), 150, 'function-comments', '{}', 'Append'
 ,'-- https://www.graphile.org/postgraphile/smart-comments/'
 ,''
 ,'https://www.graphile.org/postgraphile/smart-comments/'
;
INSERT INTO pde.patch_type(name, artifact_type_id, execution_order, key, properties, action, ddl_up_template, ddl_down_template, documentation_url) SELECT 'manage security', (SELECT id FROM pde.artifact_type WHERE NAME = 'function'), 160, 'function-security', '{}', 'Append'
 ,'
-- https://www.graphile.org/postgraphile/security/
GRANT EXECUTE ON FUNCTION {{schemaName}}.{{functionName}}() TO {{roleName}};
',
'
REVOKE EXECUTE ON FUNCTION {{schemaName}}.{{functionName}}() FROM {{roleName}};
'
,'https://www.graphile.org/postgraphile/security/'
;

INSERT INTO pde.artifact_type(name) SELECT 'custom script'; 
INSERT INTO pde.patch_type(name, artifact_type_id, execution_order, key, properties, action, ddl_up_template, ddl_down_template, documentation_url) SELECT 'create custom script', (SELECT id FROM pde.artifact_type WHERE NAME = 'custom script'), 170, 'custom-script', '{}', 'Create'
 ,'-- do anything you want here'
 ,'-- undo anything you want here'
 ,'https://www.graphile.org/postgraphile/introduction/'
;

