{% macro fetch_existing_descriptions(current_model) %}
  {% set description_dict = {} %}
  {% set current_model_dict = {} %}
  {% for node in dict(graph.nodes, **graph.sources).values() %}
    {% for col_dict in node.columns.values() %}
      {% if node.name == current_model %}
        -- Add current model description to separate dict to overwrite with later
        {% set col_description = { (col_dict.name | lower): col_dict.description} %}
        {% do current_model_dict.update(col_description) %}
      {% elif description_dict.get((col_dict.name | lower), '') == '' %}
        {% set col_description = {(col_dict.name | lower): col_dict.description} %}
        {% do description_dict.update(col_description) %}
      {% endif %}
    {% endfor %}
  {% endfor %}
  -- Overwrite description_dict with current descriptions
  {% do description_dict.update(current_model_dict) %}
  {% if var('DEBUG', False) %}
    {{ log(tojson(description_dict), info=True) }}
  {% else %}
    {{ return(description_dict) }}
  {% endif %}
{% endmacro %}
