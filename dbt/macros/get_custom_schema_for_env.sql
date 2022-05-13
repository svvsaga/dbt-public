{% macro get_custom_schema_for_env(custom_schema_name, node, custom_targets) -%}

    {%- set default_schema = target.schema -%}
    {%- if (target.name in custom_targets) and custom_schema_name is not none -%}

        {{ custom_schema_name | trim }}

    {%- else -%}

        {{ default_schema }}

    {%- endif -%}

{%- endmacro %}