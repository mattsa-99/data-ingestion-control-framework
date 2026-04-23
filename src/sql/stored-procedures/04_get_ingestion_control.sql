-- Object: Function (Procedure) {{schema_name}}.get_ingestion_control
-- Description: Retrieves the list of files to process based on process name and date range.
-- This version replaces the use of DimTiempo with PostgreSQL's native generate_series.

CREATE OR REPLACE FUNCTION {{schema_name}}.get_ingestion_control(
    p_process_name     VARCHAR(250),
    p_source_system    VARCHAR(250) DEFAULT NULL,
    p_start_date       DATE DEFAULT CURRENT_DATE,
    p_end_date         DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE (
    ingestion_id        INT,
    process_name        VARCHAR(250),
    source_system       VARCHAR(250),
    source_owner        VARCHAR(250),
    source_path         TEXT,
    source_file_name    TEXT,
    source_delimiter    VARCHAR(5),
    source_columns      TEXT,
    source_filters      TEXT,
    target_path         TEXT,
    target_file_name    TEXT,
    target_extension    VARCHAR(10),
    target_delimiter    VARCHAR(5),
    is_fact             INT,
    staging_table_name  VARCHAR(250),
    staging_schema_name VARCHAR(250),
    reference_date      DATE
) AS $$
BEGIN
    RETURN QUERY
    WITH date_range AS (
        -- Generates the sequence of dates for historical backfilling
        SELECT generate_series(p_start_date, p_end_date, '1 day'::interval)::date AS ref_date
    )
    SELECT 
        c.ingestion_id,
        c.process_name,
        c.source_system,
        c.source_owner,
        c.source_path,
        -- Apply dynamic path resolution for filenames and filters
        {{schema_name}}.fn_get_dynamic_path(c.source_file_name, d.ref_date) AS source_file_name,
        c.source_delimiter,
        c.source_columns,
        {{schema_name}}.fn_get_dynamic_path(c.source_filters, d.ref_date) AS source_filters,
        c.target_path,
        {{schema_name}}.fn_get_dynamic_path(c.target_file_name, d.ref_date) AS target_file_name,
        c.target_extension,
        c.target_delimiter,
        c.is_fact,
        c.staging_table_name,
        c.staging_schema_name,
        d.ref_date
    FROM {{schema_name}}.{{table_control}} c
    CROSS JOIN date_range d
    WHERE c.is_active = 1
      AND c.process_name = p_process_name
      AND (c.source_system = p_source_system OR p_source_system IS NULL)
      -- Logic: Master tables (is_fact=0) only run once (on start_date). 
      -- Fact tables run for every date in range.
      AND (c.is_fact = 1 OR (c.is_fact = 0 AND d.ref_date = p_start_date));
END;
$$ LANGUAGE plpgsql;