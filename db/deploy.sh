PGPASSWORD=1234 psql -U postgres -f philede.sql -d phile -h 0.0.0.0
PGPASSWORD=1234 psql -U postgres -f release-functions.sql -d phile -h 0.0.0.0