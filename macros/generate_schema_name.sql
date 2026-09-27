{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- set base_schema = target.schema | trim | upper -%}
    {%- set custom_schema = custom_schema_name | trim | upper if custom_schema_name else none -%}
    {%- if target.name == 'dev' and not modules.re.match('^DBT_[A-Z0-9_]+$', base_schema) -%}
        {{ exceptions.raise_compiler_error("Set SNOWFLAKE_SCHEMA_DEV to DBT_<DEVELOPER_ID> (uppercase letters, numbers, underscores).") }}
    {%- elif target.name == 'ci' and not modules.re.match('^PR_[1-9][0-9]*$', base_schema) -%}
        {{ exceptions.raise_compiler_error("Set SNOWFLAKE_SCHEMA_CI to PR_<NUMBER>, for example PR_42.") }}
    {%- endif -%}
    {%- if target.name == 'prod' and custom_schema -%}
        {{ custom_schema }}
    {%- elif custom_schema -%}
        {{ base_schema }}_{{ custom_schema }}
    {%- else -%}
        {{ base_schema }}
    {%- endif -%}
{%- endmacro %}
