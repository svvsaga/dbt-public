# saga_dbt_public macros

The `saga_dbt_public` dbt package provides some useful macros.

To use the package, put this in your `packages.yml` file:

```yaml
packages:
  - git: "https://github.com/svvsaga/dbt-public.git"
    revision: <version>
    subdirectory: "dbt"
```

See generated docs (`dbt docs generate`) for more information about each macro.

## Generate source yaml
To generate yaml for sources that already exist, you can use the python script `generate_source_yaml.py`.
This uses information in `target/catalog.json` to print yaml with column names and descriptions that you can copy into you `sources.yml` file.
First, run `dbt docs generate` to generate `catalog.json`, then run `python dbt_packages/saga_dbt_public/python-scripts/generate_source_yaml.py <dbt_project>.<schema>.<name>`.

You can also choose to generate doc tags instead of inlining descriptions, useful if the same column description should be used in several sources/models:
`python dbt_packages/saga_dbt_public/python-scripts/generate_source_yaml.py <dbt_project>.<schema>.<name> docs`