-- Object: Function {{schema_name}}.fn_get_dynamic_path
-- Description: Replaces date placeholders in strings with formatted values.
-- Language: PL/pgSQL (PostgreSQL)

CREATE OR REPLACE FUNCTION {{schema_name}}.fn_get_dynamic_path(
    p_target_string TEXT,
    p_reference_date DATE
)
RETURNS TEXT AS $$
DECLARE
    v_result TEXT := p_target_string;
    v_day    TEXT := TO_CHAR(p_reference_date, 'DD');
    v_year   TEXT := TO_CHAR(p_reference_date, 'YYYY');
    v_month3 TEXT := UPPER(TO_CHAR(p_reference_date, 'MON')); -- e.g., JAN, FEB...
BEGIN
    IF v_result IS NULL THEN
        RETURN NULL;
    END IF;

    -- Replace English placeholders
    v_result := REPLACE(v_result, '{DayMonthYear}',    TO_CHAR(p_reference_date, 'DDMMYYYY'));
    v_result := REPLACE(v_result, '{Year_Month_Day}',  TO_CHAR(p_reference_date, 'YYYY_MM_DD'));
    v_result := REPLACE(v_result, '{YearMonthDay}',    TO_CHAR(p_reference_date, 'YYYYMMDD'));
    v_result := REPLACE(v_result, '{Day_MonthName_Year}', v_day || '_' || v_month3 || '_' || v_year);
    v_result := REPLACE(v_result, '{Year-Month-Day}',  TO_CHAR(p_reference_date, 'YYYY-MM-DD'));
    v_result := REPLACE(v_result, '{Day_MonthName}',   v_day || '_' || v_month3);
    v_result := REPLACE(v_result, '{YearMonth}',       TO_CHAR(p_reference_date, 'YYYYMM'));

    RETURN v_result;
END;
$$ LANGUAGE plpgsql;