{% macro get_custom_schema_for_env(custom_schema_name, node, custom_targets) -%}
  {%- set default_schema = target.schema -%}
  {%- if custom_schema_name is none -%}
    {{ default_schema }}
  {%- elif (target.name in custom_targets) -%}
    {{ custom_schema_name | trim }}
  {%- else -%}
    {{ default_schema }}_{{ custom_schema_name | trim }}
  {%- endif -%}
{%- endmacro %}
