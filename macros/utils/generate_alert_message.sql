{% macro generate_anomaly_message(column_name, metric, last_value, last_avg) %}

    case when {{ column_name }} != '' then metric || '(' || column_name || ')'
    else metric
    end 
    || ' is ' ||
    {# todo: macro to ensure round() works across all dbs #}
    abs(round( cast ({{ percentage_formula('last_value - last_avg', last_avg) }} as numeric), 2))
    || '% ' ||
    {{ comparison_text(last_value, last_avg) }}
    || ' average.'
{% endmacro %}

{% macro to_2dp(val) %}
    round( cast( {{ val }} as numeric ), 2)
{% endmacro %}

{% macro seconds_to_hours(val) %}
    {{ val }} / 3600
{% endmacro %}

{% macro generate_metric_value_text(metric, value) %}
    case 
        when {{ metric }} = 'freshness' 
            then cast({{ to_2dp(seconds_to_hours(value)) }} as {{ string_type() }}) || ' hours'
        when {{ regex_match_expression(metric, 'percent') }} 
            then cast({{ to_2dp(value) }} as {{ string_type() }}) || '%'
        when {{ regex_match_expression(metric, 'count') }} 
            then cast({{ value }} as {{ string_type() }})
        else cast({{ to_2dp(value) }} as {{ string_type() }})
    end

{% endmacro %}

{% macro generate_schema_change_message(operation, column_name, prev_column_name, prev_data_type, data_type, detected_time) %}
    case 
        when {{ operation }} = 'column_added'
            then 'column ' || {{ column_name }} || ' of type ' || {{ data_type }} || ' was added at ' || {{ format_timestamp('detected_time') }}
        when {{ operation }} = 'column_removed'
            then 'column ' || {{ prev_column_name }} || ' of type ' || {{ prev_data_type }} || ' was removed at ' || {{ format_timestamp('detected_time') }}
        when {{ operation }} = 'type_change'
            then {{ column_name }} || ' column data type was changed from ' || {{ prev_data_type }} || ' to ' || {{ data_type }} || ' at ' || {{ format_timestamp('detected_time') }}
        else ''
    end
{% endmacro %}