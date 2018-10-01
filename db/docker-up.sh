docker rm -f $(docker ps -aq)
docker run --name psql -v /Users/buckfactor/pg96data:/var/lib/postgresql/data -e POSTGRES_PASSWORD=1234 -p 5432:5432 -d postgres:9.6-alpine