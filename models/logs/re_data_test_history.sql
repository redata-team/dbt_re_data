{{
    config(
        materialized='incremental',
        on_schema_change='sync_all_columns',
    )
}}

{{
    re_data.empty_table_generic([
        ('table_name', 'string'),
        ('column_name', 'string'),
        ('test_name', 'string'),
        ('status', 'string'),
        ('execution_time', 'numeric'),
        ('message', 'string'),
        ('failures_count', 'numeric'),
        ('failures_json', 'string'),
        ('failures_table', 'string'),
        ('severity', 'string'),
        ('compiled_sql', 'string'),
        ('run_at', 'timestamp')
    ])
}}