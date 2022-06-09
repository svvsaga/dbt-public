{%- macro table_or_view(table_targets) -%}
    {%- if target.name in table_targets -%}
        table
    {%- else -%}
        view
    {%- endif -%}
{%- endmacro -%}