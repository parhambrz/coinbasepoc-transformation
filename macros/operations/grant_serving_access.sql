{% macro grant_serving_access(role_name, confirm=false) %}
    {% if not confirm %}
        {{ exceptions.raise_compiler_error("Serving grants require --args '{role_name: ROLE_NAME, confirm: true}'.") }}
    {% endif %}
    {% set role = role_name | trim | upper %}
    {% if not modules.re.match('^[A-Z][A-Z0-9_]*$', role) %}
        {{ exceptions.raise_compiler_error("role_name must be a Snowflake role identifier.") }}
    {% endif %}
    {% if target.name != 'prod' or target.database | upper != 'COINBASEPOC_PROD' %}
        {{ exceptions.raise_compiler_error("Serving grants run only against prod in COINBASEPOC_PROD.") }}
    {% endif %}
    {% if execute %}
        {% for schema_name in ['CORE', 'MARTS', 'SERVE'] %}
            {% do run_query('grant usage on schema COINBASEPOC_PROD.' ~ schema_name ~ ' to role ' ~ role) %}
            {% do run_query('grant select on all tables in schema COINBASEPOC_PROD.' ~ schema_name ~ ' to role ' ~ role) %}
            {% do run_query('grant select on all views in schema COINBASEPOC_PROD.' ~ schema_name ~ ' to role ' ~ role) %}
            {% do run_query('grant select on future tables in schema COINBASEPOC_PROD.' ~ schema_name ~ ' to role ' ~ role) %}
            {% do run_query('grant select on future views in schema COINBASEPOC_PROD.' ~ schema_name ~ ' to role ' ~ role) %}
        {% endfor %}
    {% endif %}
{% endmacro %}
