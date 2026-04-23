-- Object: Table {{schema_name}}.{{table_control}}
-- Description: Central metadata repository to manage data ingestion configurations.
-- This table replaces the original [conf].[ControlCargas_Monica]

CREATE TABLE IF NOT EXISTS {{schema_name}}.{{table_control}} (
    -- Primary Key with auto-increment functionality
    ingestion_id            SERIAL PRIMARY KEY,
    
    -- Process and System identification
    process_name            VARCHAR(250), 
    source_system           VARCHAR(250), 
    source_owner            VARCHAR(250), 
    
    -- Source connection and file metadata
    source_path             VARCHAR(250), 
    source_file_name        VARCHAR(250), -- Supports dynamic placeholders like {YearMonthDay}
    source_delimiter        VARCHAR(5),   
    source_columns          TEXT,         -- Using TEXT for large column lists
    source_filters          VARCHAR(250), -- WHERE clause for filtering source data
    
    -- Target storage configuration
    target_path             VARCHAR(250), 
    target_file_name        VARCHAR(250), 
    target_extension        VARCHAR(10),  
    target_delimiter        VARCHAR(5),   
    
    -- Operational control flags
    is_fact                 INT NOT NULL DEFAULT 0, -- 0 for Master/Full, 1 for Fact/Incremental
    is_active               INT DEFAULT 1,          -- Status of the ingestion (1: Active, 0: Disabled)
    last_update             TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    
);