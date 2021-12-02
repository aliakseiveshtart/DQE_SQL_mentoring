import great_expectations as ge
from great_expectations.cli.datasource import sanitize_yaml_and_save_datasource, check_if_datasource_name_exists

context = ge.get_context()

# Give your datasource a unique name:
datasource_name = "mssql"

connection_string = "mssql+pyodbc://***:***@127.0.0.1:1433/AdventureWorks2019?driver=ODBC Driver 17 for SQL Server&charset=utf&autocommit=true"

example_yaml = f"""
name: {datasource_name}
class_name: Datasource
execution_engine:
  class_name: SqlAlchemyExecutionEngine
  connection_string: {connection_string}
data_connectors:
  default_runtime_data_connector_name:
    class_name: RuntimeDataConnector
    batch_identifiers:
      - default_identifier_name
  default_inferred_data_connector_name:
    class_name: InferredAssetSqlDataConnector
    name: whole_table"""
print(example_yaml)

# Test Your Datasource Configuration
context.test_yaml_config(yaml_config=example_yaml)

# Save Your Datasource Configuration

sanitize_yaml_and_save_datasource(context, example_yaml, overwrite_existing=False)
context.list_datasources()
