{% macro drop_ci_schemas(confirm=false) %}
    {% if not confirm %}
        {{ exceptions.raise_compiler_error("CI schema cleanup requires --args '{confirm: true}'.") }}
    {% endif %}
    {% if target.name != 'ci' or target.database | upper != 'COINBASEPOC_CI' %}
        {{ exceptions.raise_compiler_error("Cleanup can run only with target ci in COINBASEPOC_CI.") }}
    {% endif %}
    {% set base_schema = target.schema | upper %}
    {% if not modules.re.match('^PR_[1-9][0-9]*$', base_schema) %}
        {{ exceptions.raise_compiler_error("Refusing to clean non-PR schema " ~ base_schema) }}
    {% endif %}
    {% if execute %}
        {% for layer in ['STAGING', 'INTERMEDIATE', 'CORE', 'MARTS', 'SERVE'] %}
            {% set schema_name = base_schema ~ '_' ~ layer %}
            {% do log('drop schema if exists COINBASEPOC_CI.' ~ schema_name ~ ' cascade', info=true) %}
            {% do run_query('drop schema if exists COINBASEPOC_CI.' ~ schema_name ~ ' cascade') %}
        {% endfor %}
    {% endif %}
{% endmacro %}
