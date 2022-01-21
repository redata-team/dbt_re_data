{% macro drop_all_schemas(schema_name) %}
    {% set schemas_to_drop = [
        schema_name,
        schema_name + '_re',
        schema_name + '_re_internal',
        schema_name + '_raw',
        schema_name + '_expected',
        schema_name + '_dbt_test__audit'
    ] %}
    {{ adapter.dispatch('drop_all_schemas')(schemas_to_drop) }}
{% endmacro %}

{% macro default__drop_all_schemas(schemas_to_drop) %}
    {% for schema in schemas_to_drop %}
        {% set relation = api.Relation.create(database=target.database, schema=schema) %}
        {% do adapter.drop_schema(relation) %}
    {% endfor %}
{% endmacro %}

{% macro redshift__drop_all_schemas(schemas_to_drop) %}
    {# 
        dropping schemas with adapter.drop_schema doesn't seem to work with redshift
        so we default to issuing DDL commands to redshift
    #}
    {% set drop_query %}
        {% for schema in schemas_to_drop %}
            drop schema if exists {{schema}} cascade;
        {% endfor %}
    {% endset %}
    {% do run_query(drop_query) %}
{% endmacro %}