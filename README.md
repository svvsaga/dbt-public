# dbt-public

For å komme i gang med dbt, installer `dbt` med
```
brew tap dbt-labs/dbt
brew install dbt-bigquery
```
Hvis dette ikke virker, kan du prøve `pip install dbt-bigquery`.

For å sette opp et skall til et `dbt`-prosjekt, kjør `dbt init` i din prosjektmappe.


Dette repoet inneholder nyttig kode for å jobbe med dbt.
Vi kan dele koden i to typer:

## dbt-makroer
`dbt`-mappen inneholder makroer for dbt for å gjøre enkelte operasjoner enklere.

Se [dbt-readme](dbt/README.md) for dokumentasjon om disse.

## Workflows for Github actions
Disse workflowene kan brukes til å teste og deploye dbt-kode.

### dbt-deploy: Deploy dbt til GCP-prosjekt
`dbt-deploy` gjør følgende:
1. Kjører enhetstester (tester taget med `unit-test`)
2. Kjører `dbt seed`
3. Kjører `dbt run`
4. Kjører `dbt test`
5. Genererer og laster opp dbt-dokumentasjon til en GCS-bøtte

Brukes slik:
```yaml
jobs:
  deploy_stm:
    name: Deploy dbt to STM
    uses: svvsaga/dbt-public/.github/workflows/dbt-deploy.yml@v2.1.2
    with:
      dbt_path: <folder with your dbt project>
      dbt_args: --profile <profile name> --target <target>
      dbt_project_name: <your dbt project name>
      credentials_file: <file to write credentials to>
      docs_bucket: <name of GCS bucket>
    secrets:
      service_account_key: <base64-encoded service account key>
```

Antar at du har en `profiles.yml`-fil i dbt-prosjektmappen som inneholder profiler på denne formen:
````yaml
<profile name>:
  outputs:
    <target>:
      type: bigquery
      method: service-account
      keyfile: <file to write credentials to>
      project: <GCP project ID>
      ...
````
der `<target>` typisk er `STM`, `ATM` eller `PROD`.

### dbt-pr: Tester dbt-kode og poster dokumentasjon på PR
`dbt-pr` gjør følgende:
1. Kjører enhetstester (tester taget med `unit-test`)
2. Oppretter midlertidige datasett i STM-prosjektet
3. Kjører `dbt seed` og `dbt run` i midlertidige datasett
4. Genererer og laster opp docs til GCS-bøtte
5. Sammenligner skjema med skjema i ATM og poster som kommentar på PR

Siden denne kjører `dbt run`, bør man være oppmerksom på kostnad dersom det lages veldig mange tabeller med mange bytes.
Man kan unngå at disse lages som tabeller dersom man lager en makro som lager tabell


Brukes slik:
```yaml
jobs:
  dbt-run-test:
    uses: svvsaga/dbt-public/.github/workflows/dbt-pr.yml@v2.1.2
    with:
      dbt_path: <folder with your dbt project>
      dbt_args: --profile <profile name> --target <pr target name>
      dbt_project_name: <dbt project name>
      stm_credentials_file: <file to write credentials to>
      stm_project_id: <stm project ID>
      stm_docs_bucket: <stm docs bucket>
      atm_docs_bucket: <atm docs bucket>
    secrets:
      stm_key: <base64-encoded service account key for STM>
      atm_key: <base64-encoded service account key for ATM>
```

Antar at du har en `profiles.yml`-fil i dbt-prosjektmappen som inneholder profiler på denne formen:
```yaml
veidatahuset-github:
  outputs:
    <pr target name>:
      type: bigquery
      method: service-account
      keyfile: <file to write credentials to>
      project: <stm project ID>
      dataset: "{{ env_var('DBT_DATASET') }}"
```


### dbt-sqlfluff-lint
Denne workflowen brukes i PR-er for å sjekke formattering av SQL-filer med sqlfluff.
Den gjør følgende:
1. Bestemmer hvilke filer som er endret i PR-en
2. Kjører `sqlfluff lint` på endrede SQL-filer i dbt-mappen
3. Poster kommentarer på PR dersom formattering ikke følger sqlfluffs regler

Denne antar at man har en `.sqlfluff`-konfigurasjon i dbt-mappen.

Brukes slik:
```yaml
jobs:
  check-sql-formatting:
    uses: svvsaga/dbt-public/.github/workflows/dbt-sqlfluff-lint.yml@v2.1.2
    with:
      dbt_path: <folder with dbt project>
```

## Utvikling av dbt-public
For å lage nye versjoner, skriv #patch, #minor eller #major i commit-meldingen.
