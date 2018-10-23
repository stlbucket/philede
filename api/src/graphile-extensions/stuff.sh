#!/usr/bin/env bash
echo dropdb
dropdb -h 0.0.0.0 -p 5432 -U postgres test_db
echo createdb
createdb -h 0.0.0.0 -p 5432 -U postgres test_db


