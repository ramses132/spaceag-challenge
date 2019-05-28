#!/bin/sh

set -e

# Perform all actions as $POSTGRES_USER
export PGUSER="$POSTGRES_USER"

# Create the 'template_postgis' template db
"${psql[@]}" <<- 'EOSQL'
CREATE DATABASE template_postgis;
UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template_postgis';
EOSQL

# https://pgtune.leopard.in.ua/
# DB Version: 11
# OS Type: linux
# DB Type: web
# Total Memory (RAM): 4 GB
# CPUs num: 2
# Connections num: 150
# Data Storage: ssd

"${psql[@]}" <<- 'EOSQL'
ALTER SYSTEM SET max_connections = '150';
ALTER SYSTEM SET shared_buffers = '1GB';
ALTER SYSTEM SET effective_cache_size = '3GB';
ALTER SYSTEM SET maintenance_work_mem = '256MB';
ALTER SYSTEM SET checkpoint_completion_target = '0.7';
ALTER SYSTEM SET wal_buffers = '16MB';
ALTER SYSTEM SET default_statistics_target = '100';
ALTER SYSTEM SET random_page_cost = '1.1';
ALTER SYSTEM SET effective_io_concurrency = '200';
ALTER SYSTEM SET work_mem = '6990kB';
ALTER SYSTEM SET min_wal_size = '1GB';
ALTER SYSTEM SET max_wal_size = '2GB';
ALTER SYSTEM SET max_worker_processes = '2';
ALTER SYSTEM SET max_parallel_workers_per_gather = '1';
ALTER SYSTEM SET max_parallel_workers = '2';
EOSQL


# Load PostGIS into both template_database and $POSTGRES_DB
for DB in template_postgis "$POSTGRES_DB"; do
	echo "Loading PostGIS extensions into $DB"
	"${psql[@]}" --dbname="$DB" <<-'EOSQL'
		CREATE EXTENSION IF NOT EXISTS postgis;
		CREATE EXTENSION IF NOT EXISTS postgis_topology;
		CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
		CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;
EOSQL
done