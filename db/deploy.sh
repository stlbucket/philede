#!/usr/bin/env bash

./execute.sh ./0100-philede.sql
./execute.sh ./0200-release-functions.sql
./execute.sh ./0300-release-ddl.sql
./execute.sh ./0400-seed-data.sql


# ./execute.sh ./9900-dummy-data.sql
