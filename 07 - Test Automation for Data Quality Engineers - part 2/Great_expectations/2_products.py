import datetime

import pandas as pd

import great_expectations as ge
import great_expectations.jupyter_ux
from great_expectations.core.batch import BatchRequest
from great_expectations.profile.user_configurable_profiler import UserConfigurableProfiler
from great_expectations.checkpoint import SimpleCheckpoint
from great_expectations.exceptions import DataContextError

# Initialize a new Expectation Suite by profiling a batch of your data.
context = ge.data_context.DataContext()

batch_request = {'datasource_name': 'mssql', 'data_connector_name': 'default_inferred_data_connector_name', 'data_asset_name': 'Product', 'limit': 1000}

expectation_suite_name = "products"

validator = context.get_validator(
    batch_request=BatchRequest(**batch_request),
    expectation_suite_name=expectation_suite_name
)
column_names = [f'"{column_name}"' for column_name in validator.columns()]
print(f"Columns: {', '.join(column_names)}.")
print(validator.head(n_rows=5, fetch_all=False))

# Select the columns on which you would like to set expectations and those which you would like to ignore.
ignored_columns = [
    "ProductID",
    "Name",
    "ProductNumber",
    "MakeFlag",
    "FinishedGoodsFlag",
    "Color",
    "SafetyStockLevel",
    "ReorderPoint",
    "StandardCost",
    "ListPrice",
    "Size",
    "SizeUnitMeasureCode",
    "WeightUnitMeasureCode",
    "Weight",
    "DaysToManufacture",
    "ProductLine",
    "Class",
    "Style",
    "ProductSubcategoryID",
    "ProductModelID",
    "SellStartDate",
    "SellEndDate",
    "DiscontinuedDate",
    "rowguid",
    "ModifiedDate",
]

# Run the data profiler

profiler = UserConfigurableProfiler(
    profile_dataset=validator,
    excluded_expectations=None,
    ignored_columns=ignored_columns,
    not_null_only=False,
    primary_or_compound_key=False,
    semantic_types_dict=None,
    table_expectations_only=False,
    value_set_threshold="MANY",
)
suite = profiler.build_suite()

# Save & review your new Expectation Suite

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
