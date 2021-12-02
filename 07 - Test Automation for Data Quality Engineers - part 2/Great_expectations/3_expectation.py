import datetime

import pandas as pd

import great_expectations as ge
import great_expectations.jupyter_ux
from great_expectations.core.batch import BatchRequest
from great_expectations.checkpoint import SimpleCheckpoint
from great_expectations.exceptions import DataContextError

context = ge.data_context.DataContext()

# Note that if you modify this batch request, you may save the new version as a .json file
#  to pass in later via the --batch-request option
batch_request = {'datasource_name': 'mssql', 'data_connector_name': 'default_inferred_data_connector_name', 'data_asset_name': 'Product', 'limit': 1000}


# Feel free to change the name of your suite here. Renaming this will not remove the other one.
expectation_suite_name = "products"
try:
    suite = context.get_expectation_suite(expectation_suite_name=expectation_suite_name)
    print(f'Loaded ExpectationSuite "{suite.expectation_suite_name}" containing {len(suite.expectations)} expectations.')
except DataContextError:
    suite = context.create_expectation_suite(expectation_suite_name=expectation_suite_name)
    print(f'Created ExpectationSuite "{suite.expectation_suite_name}".')


validator = context.get_validator(
    batch_request=BatchRequest(**batch_request),
    expectation_suite_name=expectation_suite_name
)
column_names = [f'"{column_name}"' for column_name in validator.columns()]
print(f"Columns: {', '.join(column_names)}.")
print(validator.head(n_rows=5, fetch_all=False))


# expectation
# https://legacy.docs.greatexpectations.io/en/latest/autoapi/great_expectations/dataset/dataset/index.html#great_expectations.dataset.dataset.Dataset.expect_column_values_to_be_unique
validator.expect_table_columns_to_match_ordered_list(column_list=['ProductID', 'Name', 'ProductNumber', 'MakeFlag', 'FinishedGoodsFlag', 'Color', 'SafetyStockLevel', 'ReorderPoint', 'StandardCost', 'ListPrice', 'Size', 'SizeUnitMeasureCode', 'WeightUnitMeasureCode', 'Weight', 'DaysToManufacture', 'ProductLine', 'Class', 'Style', 'ProductSubcategoryID', 'ProductModelID', 'SellStartDate', 'SellEndDate', 'DiscontinuedDate', 'rowguid', 'ModifiedDate'])
validator.expect_table_row_count_to_be_between(max_value=504, min_value=504)
validator.expect_column_values_to_be_null('Color', mostly=0.4) # error if mostly=0.6
validator.expect_column_values_to_be_unique('Name')
validator.expect_column_values_to_not_be_null('MakeFlag') # Size

print(validator.get_expectation_suite(discard_failed_expectations=False))
validator.save_expectation_suite(discard_failed_expectations=False)

checkpoint_config = {
    "class_name": "SimpleCheckpoint",
    "validations": [
        {
            "batch_request": batch_request,
            "expectation_suite_name": expectation_suite_name
        }
    ]
}
checkpoint = SimpleCheckpoint(
    f"_tmp_checkpoint_{expectation_suite_name}",
    context,
    **checkpoint_config
)
checkpoint_result = checkpoint.run()

context.build_data_docs()

validation_result_identifier = checkpoint_result.list_validation_result_identifiers()[0]
context.open_data_docs(resource_identifier=validation_result_identifier)
