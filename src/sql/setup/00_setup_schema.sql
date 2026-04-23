-- Object: Schema {{schema_name}}
-- Description: Creates the dedicated namespace for the ingestion framework metadata.
-- Using 'IF NOT EXISTS' to ensure the script is idempotent (can be run multiple times).

-- Create the schema where all framework objects will reside
CREATE SCHEMA IF NOT EXISTS {{schema_name}};

-- Optional: Set a comment to document the schema purpose in PostgreSQL
COMMENT ON SCHEMA {{schema_name}} IS 'Contains all metadata and orchestration objects for the Data Ingestion Framework';