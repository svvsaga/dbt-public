import json
import sys

def main(source_id, doc_tag):
  with open("target/catalog.json") as f:
    s = json.load(f)
  source = s['sources']["source." + source_id]

  metadata = source['metadata']
  print(f"""
sources:
  - name: {metadata['schema']}
    project: {metadata['database']}
    dataset: {metadata['schema']}
    tables:
      - name: {metadata['name']}
        columns:""")
  if doc_tag:
    docs = ""
    for column in source['columns'].values():
      print(f"""
            - name: {column['name']}
              description: \"{{{{ doc('{column['name']}') }}}}\"""")
      docs += f"""{{% docs {column['name']} -%}}
{column['comment'] or ''}
{{%- enddocs %}}
"""
    print(docs)
  else:
    for column in source['columns'].values():
      print(f"""
            - name: {column['name']}
              description: \"{column['comment'] or ''}\"""")

if __name__ == "__main__":
  if len(sys.argv) < 2:
    print('Usage: python generate_source_yaml.py <dbt_project>.<schema>.<name> [docs]')
    print('Specify docs to generate doc tags for descriptions instead of inlining descriptions')
  else:
    main(sys.argv[1], sys.argv[2] == 'docs')