*** Settings ***
Documentation   Robot resources and variables for all tests

Suite Setup       Connect To Database    pymssql    ${DBName}    ${DBUser}    ${DBPass}    ${DBHost}    ${DBPort}
Suite Teardown    Disconnect From Database
Library           DatabaseLibrary
Library           OperatingSystem

Resource  ./resources/variables.robot

*** Test Cases ***
Table Must Exist - Address
    [Tags]              Address    smoke
    [Documentation]     Checking for the presence of the Address table in the database
    Table Must Exist    Address

Verify Query - Check StateProvinceID
    [Tags]    Address    smoke
    [Documentation]
    ...  | The test checks if all StateProvinceID key values from the Address table are in the StateProvince table
    ...  |
    ...  | 1. Load SQL script from file
    ...  | 2. Executing the script
    ...  | 3. If as a result of the script execution we get 0, then the test is passed
    ${sql_query}    Get File    sql/Person/Address/StateProvinceID.sql
    ${output} =     Query   ${sql_query}
    Log    ${output}
    Should Be Equal As Strings    ${output}    [(0,)]

Verify Query - column name
    [Tags]    Address    smoke
    [Documentation]
    ...  | Checking for columns in the Address table
    ...  |
    ...  | 1. Load SQL script from file
    ...  | 2. Executing the script
    ...  | 3. We write the result to the list $ {output} and check it
    ${sql_query}    Get File    sql/Person/Address/Measures.sql
    ${output} =     Query   ${sql_query}    \    True
    Log    ${output}
    Should Be Equal As Strings      ${output[0]}[COLUMN_NAME]     AddressID
    Should Be Equal As Strings      ${output[1]}[COLUMN_NAME]     AddressLine1
    Should Be Equal As Strings      ${output[2]}[COLUMN_NAME]     AddressLine2
    Should Be Equal As Strings      ${output[3]}[COLUMN_NAME]     City
    Should Be Equal As Strings      ${output[4]}[COLUMN_NAME]     ModifiedDate
    Should Be Equal As Strings      ${output[5]}[COLUMN_NAME]     PostalCode
    Should Be Equal As Strings      ${output[6]}[COLUMN_NAME]     rowguid
    Should Be Equal As Strings      ${output[7]}[COLUMN_NAME]     SpatialLocation
    Should Be Equal As Strings      ${output[8]}[COLUMN_NAME]     StateProvinceID

Table Must Exist - Document
    [Tags]              Document    smoke
    [Documentation]     Checking for the presence of the Document table in the database
    Table Must Exist    Document

Verify Query - Folder flag
    [Tags]              Document    smoke
    [Documentation]
    ...  | Testing if the FolderFlag column is well formed.
    ...  |
    ...  | 1. Load SQL script from file
    ...  | 2. Executing the script
    ...  | 3. If as a result of the script execution we get 0, then the test is passed
    ${sql_query}    Get File    sql/Production/Document/FileExtension_FolderFlag.sql
    ${output} =     Query   ${sql_query}    \    True
    Log    ${output}
    Should Be Equal As Strings    ${output[0]}[Fold_res]    0

Verify Query - File extention
    [Tags]              Document    smoke
    [Documentation]
    ...  | Testing if the FileExtension column is well formed.
    ...  |
    ...  | 1. Load SQL script from file
    ...  | 2. Executing the script
    ...  | 3. If as a result of the script execution we get 0, then the test is passed
    ${sql_query}    Get File    sql/Production/Document/FileExtension_FolderFlag.sql
    ${output} =     Query   ${sql_query}    \    True
    Log    ${output}
    Should Be Equal As Strings    ${output[0]}[Ext_res]    0

Table Must Exist - UnitMeasure
    [Tags]              UnitMeasure    smoke
    [Documentation]     Checking for the presence of the UnitMeasure table in the database
    Table Must Exist    UnitMeasure

Verify Query - Check full duplicates in UnitMeasure
    [Tags]              UnitMeasure    smoke
    [Documentation]
    ...  | Checking the table for duplicates
    ...  |
    ...  | 1. Load SQL script from file
    ...  | 2. Executing the script
    ...  | 3. If as a result of the script execution we get 0, then the test is passed
    ${sql_query}    Get File    sql/Production/UnitMeasure/duplicates.sql
    ${output} =     Query   ${sql_query}
    Log    ${output}
    Should Be Equal As Strings    ${output}    [(0,)]

Insert NULL Into UnitMeasureCode in UnitMeasure Table
    [Tags]              UnitMeasure    smoke
    [Documentation]
    ...  | We are trying to insert a NULL value into the UnitMeasure table into the UnitMeasureCode column
    ...  |
    ...  | 1. Load SQL script from file
    ...  | 2. Executing the script
    ...  | 3. If the script is executed with an error, then the test passed and we cannot insert NULL
    ${sql_query}    Get File    sql/Production/UnitMeasure/null_Code.sql
    ${err_msg}=  Run Keyword And Expect Error  *  Execute SQL String    ${sql_query}
    Log    ${err_msg}
    Should Not Be Empty    ${err_msg}

Insert NULL Into Name in UnitMeasure Table
    [Tags]              UnitMeasure    smoke
    [Documentation]
    ...  | We are trying to insert a NULL value into the UnitMeasure table into the Name column
    ...  |
    ...  | 1. Load SQL script from file
    ...  | 2. Executing the script
    ...  | 3. If the script is executed with an error, then the test passed and we cannot insert NULL
    ${sql_query}    Get File    sql/Production/UnitMeasure/null_Name.sql
    ${err_msg}=  Run Keyword And Expect Error  *  Execute SQL String    ${sql_query}
    Log    ${err_msg}
    Should Not Be Empty    ${err_msg}
