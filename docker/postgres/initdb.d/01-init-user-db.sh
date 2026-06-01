#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Ensure the affine user exists with the correct password
    DO $$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'affine') THEN
        CREATE USER affine WITH PASSWORD 'pelvity';
    ELSE
        ALTER USER affine WITH PASSWORD 'pelvity';
        END IF;
    END
    $$;
    
    -- Ensure the database exists (idempotent on fresh init)
    DO $$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_database WHERE datname = 'affine') THEN
            PERFORM dblink_exec('dbname=' || current_database(), 'CREATE DATABASE affine');
        END IF;
    END
    $$;

    -- On the current database (initially $POSTGRES_DB), adjust public schema privileges just in case
    ALTER SCHEMA public OWNER TO affine;
    GRANT USAGE, CREATE ON SCHEMA public TO affine;

    -- Grant all privileges on the database to the affine user
    GRANT ALL PRIVILEGES ON DATABASE affine TO affine;
    
    -- Grant all privileges on all tables in the public schema
    GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO affine;
    GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO affine;
    GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO affine;
    
    -- Ensure the affine user can create databases (needed for tests)
    ALTER USER affine CREATEDB;
EOSQL

echo "PostgreSQL user and database initialization completed successfully"
