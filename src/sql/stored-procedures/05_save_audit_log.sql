-- Object: Function {{schema_name}}.save_audit_log
-- Description: Inserts a new execution record into the audit log table.
-- Language: PL/pgSQL

CREATE OR REPLACE FUNCTION {{schema_name}}.save_audit_log(
    p_ingestion_id           INT,
    p_source_file_name       VARCHAR(250),
    p_pipeline_name          VARCHAR(250),
    p_trigger_name           VARCHAR(250),
    p_execution_status       INT,
    p_rows_read              INT,
    p_rows_copied            INT,
    p_execution_time_seconds INT,
    p_error_log              TEXT
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO {{schema_name}}.{{table_log}} (
        ingestion_id,
        source_file_name,
        pipeline_name,
        trigger_name,
        execution_status,
        rows_read,
        rows_copied,
        execution_time_seconds,
        error_log,
        execution_timestamp
    )
    VALUES (
        p_ingestion_id,
        p_source_file_name,
        p_pipeline_name,
        p_trigger_name,
        p_execution_status,
        p_rows_read,
        p_rows_copied,
        p_execution_time_seconds,
        p_error_log,
        CURRENT_TIMESTAMP
    );
END;
$$ LANGUAGE plpgsql;