{# Macros here are inspired by https://github.com/dbt-labs/dbt-bigquery/issues/87 #}
{# Gives a more user friendly way of creating authorized views #}

{% macro grant_access_to(entities, entity_type, role, grant_target_dict) -%}
  {# This macro takes a list of "entities" (authorized views) and grants them access to a dataset (specified by grant_target_dict) #}
  {# Currently, the dbt-biquery (Python) method `grant_access_to` appends entities one-by-one #}
  {# It sounds like we could speed this up by making it possible to append many entities at once #}

  {% for entity in entities %}
    {% set entity_name = entity.database + "." + entity.schema + "." + entity.alias %}
    {% do log("... to " + entity_name, info = true) %}
    {% do adapter.grant_access_to(entity, entity_type, role, grant_target_dict) %}
    {% endfor %}

{% endmacro %}

{% macro parse_auth_view_upstream_datasets_from_results(results) %}
    {# This macro takes the `Results` object, available in the `on-run-end` context, identifies models #}
    {# configured with `authorized_view: true`, and parses the database location of their upstream model dependencies #}
    {# via the `graph.nodes` context variable #}
    {# It returns a dictionary containing one entry per dataset to grant access on, and each of those entries #}
    {# contains a list of authorized views that need access to it #}

    {% set datasets_to_grant_access_on = {} %}

    {% if execute %}

    {% for result in results %}

    {% set node = result.node %}
    {% if node.config.get('_extra').get('authorized_view') %}
    {# We use the unique filter since nodes sometimes contains duplicates #}
    {% for upstream_id in node.depends_on.nodes|unique %}
    {% for upstream_node in dict(graph.nodes, **graph.sources).values() %}
        {% if upstream_node['unique_id'] == upstream_id %}
            {% set dataset_fqn = upstream_node.database + '.' + upstream_node.schema %}
            {% if dataset_fqn in datasets_to_grant_access_on.keys() %}
               {% do datasets_to_grant_access_on[dataset_fqn]['needs_access'].append(node) %}
            {% else %}
              {% do datasets_to_grant_access_on.update({dataset_fqn: {
                'project': upstream_node.database,
                'dataset': upstream_node.schema,
                'needs_access': [node]
              }}) %}
            {% endif %}
          {% endif %}
        {% endfor %}
      {% endfor %}

    {% endif %}

  {% endfor %}

  {% endif %}

  {{ return(datasets_to_grant_access_on) }}

{% endmacro %}

{% macro grant_access_for_all_authorized_views(results) %}
  {# This macro is the entrypoint to the operation. It receives results, #}
  {# parses them via the macro defined above, and finally loops over each dataset entry #}
  {# to grant access #}

  {% set datasets_to_grant_access_on = saga_dbt_public.parse_auth_view_upstream_datasets_from_results(results) %}
  {% for dataset_grant in datasets_to_grant_access_on %}

    {% set grant_target_dict = {
    'project': datasets_to_grant_access_on[dataset_grant]['project'],
    'dataset': datasets_to_grant_access_on[dataset_grant]['dataset']
    } %}

    {% do log("Granting access on dataset " + dataset_grant, info = true) %}

    {% do saga_dbt_public.grant_access_to(
    entities = datasets_to_grant_access_on[dataset_grant]['needs_access'],
    entity_type = 'view',
    role = None,
    grant_target_dict = grant_target_dict
    ) %}

  {% endfor %}

{% endmacro %}