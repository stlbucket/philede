#!/bin/bash

# Config:
DB=soro_sales
U=postgres
# tablename searchpattern, if you want all tables enter "":
P=""
# directory to dump files without trailing slash:
DIR=./outfiles

mkdir -p $DIR

pg_dump $DB -U $U -w -s -f $DIR/all.sql;

#SCHEMAS="$(psql -d $DB -U $U -t -c "
#SELECT schema_name
#FROM information_schema.schemata
#WHERE schema_name NOT LIKE 'pg_%'
#AND schema_name != 'public'
#AND schema_name != 'information_schema'
#")"
#for schema in $SCHEMAS; do
#  echo backup schema $schema ...
#  mkdir -p $DIR/$schema
#  mkdir -p $DIR/$schema/functions
#  mkdir -p $DIR/$schema/tables
#  mkdir -p $DIR/$schema/views
#
## tables
#  TABLES="$(psql -d $DB -U $U -t -c "
 SELECT table_name
 FROM information_schema.tables
 WHERE table_type='BASE TABLE'
 AND table_schema = '$schema'
 ")"
##  echo tables $TABLES
#  for table in $TABLES; do
#    echo backup $schema.$table ...
#    pg_dump $DB -U $U -s -w -t $schema.$table > $DIR/$schema/tables/$table.sql;
#  done;
#
##views
#  VIEWS="$(psql -d $DB -U $U -t -c "
#  SELECT table_name
#  FROM information_schema.tables
#  WHERE table_type='VIEW'
#  AND table_schema = '$schema'
#  ")"
##  echo views $VIEWS
#  for view in $VIEWS; do
#    echo backup $schema.$view ...
#    pg_dump $DB -U $U -s -w -t $schema.$view > $DIR/$schema/views/$view.sql;
#  done;
#
##functions
#  FUNCTIONS="$(psql -d $DB -U $U -t -c "
  SELECT p.proname AS function_name
  FROM   (SELECT oid, * FROM pg_proc p WHERE NOT p.proisagg) p
  JOIN   pg_namespace n ON n.oid = p.pronamespace
  AND    n.nspname = 'soro'
  order by function_name
  ;
  ")"
#  echo functions: $FUNCTIONS
#  for function in $FUNCTIONS; do
#    echo backup $schema.$view ...
#    pg_dump $DB -U $U -s -w -Fc $schema.$function > $DIR/$schema/functions/$function.sql;
#  done;
#
#done;

#TABLES="$(psql -d $DB -U $U -t -c "SELECT table_name FROM
#information_schema.tables WHERE table_type='BASE TABLE' AND table_name
#LIKE '%$P%' ORDER BY table_name")"
#for table in $TABLES; do
#  echo backup $table ...
#  pg_dump $DB -U $U -w -t $table > $DIR/$table.sql;
#done;

echo done