{% docs get_custom_schema_for_env %}
Macro that lets you use the custom schema name for a model as dataset name when materializing.
To use it, define this macro in your project:

{% raw %}
```
    {% macro generate_schema_name(custom_schema_name, node) -%}
    {{ saga_dbt_public.get_custom_schema_for_env(custom_schema_name, node, ['STM', 'ATM', 'PROD']) }}
    {%- endmacro %}
```
{% endraw %}
This will use the custom schema if the target is named STM, ATM or PROD.
{% enddocs %}


{% docs grant_access_for_all_authorized_views %}
Macro to let you create authorized views in an easier way.

Add this hook in your dbt_project.yml:
{% raw %}
```
    on-run-end: 
      - {{ saga_dbt_public.grant_access_for_all_authorized_views(results) }}
```
{% endraw %}

To create an authorized view, add
{% raw %}
```
{{ config(authorized_view=true) }}
```
{% endraw %}
to your model definition.
{% enddocs %}


{% docs generate_model_yaml %}
When developing models, you can use `generate_model_yaml` to generate a model schema, including the descriptions of columns with identical names in models you depend on.

This will generate model schema for a model called `buffered_hendelser`:

`dbt run-operation saga_dbt_public.generate_model_yaml --args '{"model_name": "buffered_hendelser"}'`
{% enddocs %}