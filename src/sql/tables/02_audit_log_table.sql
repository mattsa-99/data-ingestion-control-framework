-- Object: Table {{schema_name}}.{{table_log}}
-- Description: Stores execution logs and metrics for the ingestion process.
-- This table allows NULL values to capture partial metadata in case of early failures.

CREATE TABLE IF NOT EXISTS {{schema_name}}.{{table_log}} (
    -- Primary Key with auto-increment
    audit_id                SERIAL PRIMARY KEY,
    
    -- Foreign Key reference to the control table
    ingestion_id            INT NULL, 
    
    -- Execution Metadata
    source_file_name        VARCHAR(250) NULL, 
    pipeline_name           VARCHAR(250) NULL, 
    trigger_name            VARCHAR(250) NULL, 
    
    -- Status and Metrics (Allowing NULLs as per original design)
    execution_status        INT NULL,          -- e.g., 1 for Success, 0 for Failure
    rows_read               INT NULL,
    rows_copied              INT NULL,
    execution_time_seconds  INT NULL,          -- Time taken for the copy process
    
    -- Large object for detailed logs (PostgreSQL TEXT handles nvarchar(max) logic)
    error_log               TEXT NULL,         
    
    -- Audit Timestamp
    execution_timestamp     TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP
);