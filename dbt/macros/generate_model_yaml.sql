{% macro generate_model_yaml(model_name, docs=False) %}
  {# Inspired by https://stackoverflow.com/questions/67718476/using-one-yaml-definition-for-the-same-column-as-it-moves-through-models #}
  {% set model_yaml=[] %}
  {% set existing_descriptions = saga_dbt_public.fetch_existing_descriptions(model_name) %}
  -- # TO DO: pass model to fetch()
  -- if column not blank on current model, use description in returned dict
  -- otherwise, use global
  -- also extract tests on column anywhere in global scope
  {% do model_yaml.append('') %}
  {% do model_yaml.append('version: 2') %}
  {% do model_yaml.append('') %}
  {% do model_yaml.append('models:') %}
  {% do model_yaml.append('  - name: ' ~ model_name | lower) %}
  {% do model_yaml.append('    description: ""') %}
  {% do model_yaml.append('    columns:') %}
  {% set relation=builtins.ref(model_name) %}
  {%- set columns = adapter.get_columns_in_relation(relation) -%}
  {% for column in columns %}
    {%- set column = column.name | lower -%}
    {%- set col_description = existing_descriptions.get(column, '') %}
    {% do model_yaml.append('      - name: ' ~ column ) %}
    {% if docs %}
      {% do model_yaml.append('        description: "{{ doc(\'' ~ column ~ '\') }}"') %}
    {% else %}
      {% do model_yaml.append('        description: "' ~ col_description ~ '"') %}
    {% endif %}
    {% do model_yaml.append('') %}
  {% endfor %}
  {% if execute %}
    {% set joined = model_yaml | join ('\n') %}
    {{ log(joined, info=True) }}
    {% do return(joined) %}
  {% endif %}
{% endmacro %}
