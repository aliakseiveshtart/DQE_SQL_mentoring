import db_connector
import pytest
import allure
import pandas as pd
import numpy as np
import os

# connect to SQL Server, settings are read from config.ini file
db_con = db_connector.dbwork('SQL Server')


# create a reference dataframe to validate data in the Person.Address table
df_ref = pd.DataFrame({'COLUMN_NAME': ['AddressID', 'AddressLine1', 'AddressLine2', 'City', 'StateProvinceID',
                                       'PostalCode', 'SpatialLocation', 'rowguid', 'ModifiedDate'],
                       'IS_NULLABLE': ['NO', 'NO', 'YES', 'NO', 'NO', 'NO', 'YES', 'NO', 'NO'],
                       'DATA_TYPE':   ['int', 'nvarchar', 'nvarchar', 'nvarchar', 'int', 'nvarchar',
                                       'geography', 'uniqueidentifier', 'datetime'],
                       'CHARACTER_MAXIMUM_LENGTH': [np.NaN, 60.0, 60.0, 30.0, np.NaN, 15.0, -1.0, np.NaN, np.NaN]
                       })


# The function reads the request from the script and gives the result for one of the columns [Ext_res, Fold_res]
def prod(column, rp_logger):
    sql_str = db_con.read_file(os.path.join('sql', 'Production', 'Document', 'FileExtension_FolderFlag.sql'))
    allure.attach(sql_str, 'SQL query', allure.attachment_type.TEXT)
    df = db_con.query(sql_str)
    result = df[column].values[0]
    rp_logger.info("Test attachments", attachment={"data": sql_str})
    allure.attach(str(result), 'Result', allure.attachment_type.TEXT)
    return result


# Production.Document - test FileExtension and FileName
# Testing if the FileExtension column is well formed. If the result is 0, then the test is passed
@allure.feature('Production.Document - test FileExtension and FileName')
def test_prod_doc_ext(rp_logger):
    result = prod('Ext_res', rp_logger)
    rp_logger.info("Test FileExtension and FileName")
    assert result == 0


# Production.Document - test FileExtension and FolderFlag
# Testing if the FolderFlag column is well formed. If the result is 0, then the test is passed
@allure.feature('Production.Document - test FileExtension and FolderFlag')
def test_prod_doc_folder(rp_logger):
    result = prod('Fold_res', rp_logger)
    rp_logger.info("Test FileExtension and FolderFlag")
    assert result == 0


# Production.UnitMeasure - test full duplicates
@allure.feature('Production.UnitMeasure - test duplicates')
def test_prod_um_duplicates(rp_logger):
    sql_str = db_con.read_file(os.path.join('sql', 'Production', 'UnitMeasure', 'duplicates.sql'))
    allure.attach(sql_str, 'SQL query', allure.attachment_type.TEXT)
    df = db_con.query(sql_str)
    result = df['count'].values[0]
    allure.attach(str(result), 'Result', allure.attachment_type.TEXT)
    rp_logger.info("Test attachments", attachment={"data": sql_str})
    assert result == 0


# Production.UnitMeasure - test Insert null in UnitMeasure -> Code
@allure.feature('Production.UnitMeasure - test duplicates')
def test_prod_um_code_null(rp_logger):
    sql_str = db_con.read_file(os.path.join('sql', 'Production', 'UnitMeasure', 'null_Code.sql'))
    allure.attach(sql_str, 'Insert', allure.attachment_type.TEXT)
    rp_logger.info("Test attachments", attachment={"data": sql_str})
    try:
        db_con.query(sql_str)
        assert False
    except:
        assert True


# Production.UnitMeasure - test Insert null in UnitMeasure -> Name
@allure.feature('Production.UnitMeasure - test duplicates')
def test_prod_um_name_null(rp_logger):
    sql_str = db_con.read_file(os.path.join('sql', 'Production', 'UnitMeasure', 'null_Name.sql'))
    allure.attach(sql_str, 'Insert', allure.attachment_type.TEXT)
    rp_logger.info("Test attachments", attachment={"data": sql_str})
    try:
        db_con.query(sql_str)
        assert False
    except:
        assert True


# Person.Address - test StateProvinceID key
# The test checks if all StateProvinceID key values from the Address table are in the StateProvince table
@allure.feature('Person.Address - test StateProvinceID key')
def test_person_address_spid(rp_logger):
    sql_str = db_con.read_file(os.path.join('sql', 'Person', 'Address', 'StateProvinceID.sql'))
    allure.attach(sql_str, 'SQL query', allure.attachment_type.TEXT)
    df = db_con.query(sql_str)
    result = df['count'].values[0]
    allure.attach(str(result), 'Result', allure.attachment_type.TEXT)
    rp_logger.info("Test attachments", attachment={"data": sql_str})
    assert result == 0


# Person.Address - test column name
@allure.feature('Person.Address - test column name')
def test_person_address_col_name(rp_logger):
    sql_str = db_con.read_file(os.path.join('sql', 'Person', 'Address', 'Measures.sql'))
    allure.attach(sql_str, 'SQL query', allure.attachment_type.TEXT)
    df = db_con.query(sql_str)
    result = pd.concat([df['COLUMN_NAME'], df_ref['COLUMN_NAME']]).drop_duplicates(keep=False).count()
    allure.attach(str(result), 'Result', allure.attachment_type.TEXT)
    rp_logger.info("Test attachments", attachment={"data": sql_str})
    assert result == 0


# Person.Address - test column type
@allure.feature('Person.Address - test column type')
def test_person_address_col_type(rp_logger):
    sql_str = db_con.read_file(os.path.join('sql', 'Person', 'Address', 'Measures.sql'))
    allure.attach(sql_str, 'SQL query', allure.attachment_type.TEXT)
    df = db_con.query(sql_str)
    result = pd.concat([df[['COLUMN_NAME', 'DATA_TYPE']],
                        df_ref[['COLUMN_NAME', 'DATA_TYPE']]]).drop_duplicates(keep=False).count()
    allure.attach(str(result.to_string()), 'Result', allure.attachment_type.TEXT)
    rp_logger.info("Test attachments", attachment={"data": sql_str})
    assert (result['COLUMN_NAME'] == 0 and result['DATA_TYPE'] == 0)


# Person.Address - test column lenght
@allure.feature('Person.Address - test column lenght')
def test_person_address_col_lenght(rp_logger):
    sql_str = db_con.read_file(os.path.join('sql', 'Person', 'Address', 'Measures.sql'))
    allure.attach(sql_str, 'SQL query', allure.attachment_type.TEXT)
    df = db_con.query(sql_str)
    result = pd.concat([df[['COLUMN_NAME', 'CHARACTER_MAXIMUM_LENGTH']],
                        df_ref[['COLUMN_NAME', 'CHARACTER_MAXIMUM_LENGTH']]]).drop_duplicates(keep=False).count()
    allure.attach(str(result.to_string()), 'Result', allure.attachment_type.TEXT)
    rp_logger.info("Test attachments", attachment={"data": sql_str})
    assert (result['COLUMN_NAME'] == 0 and result['CHARACTER_MAXIMUM_LENGTH'] == 0)


if __name__ == "__main__":
    pytest.main()
