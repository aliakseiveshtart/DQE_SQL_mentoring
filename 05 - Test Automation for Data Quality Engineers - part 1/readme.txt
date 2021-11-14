The project contains two variants of tests on two different frameworks Pytest and Robot framework

General description:
   1. Basic SQL scripts are contained in the sql folder and subfolders with the schema name and table name.
      They are used in both frameworks:

  sql
   |- Person                                - Schema name
      -> Address                            - Table name
         -> Measures.sql
         -> StateProvinceID.sql
   |- Production                            - Schema name
      -> Document                           - Table name
         -> FileExtension_FolderFlag.sql
      -> UnitMeasure                        - Table name
         -> duplicates.sql
         -> null_Code.sql
         -> null_Name.sql

  2. Frameworks run tests and generate reports.
    2.1 Pytest generate reports in allure and in the report portal
    2.2 Robot framework we form our reports and reports in the report portal

  3. Project structure and file description:

allure-report         - prepared allure report
reports               - in this folder pytest saves the files necessary for the formation allure report
resources
  -> variables.robot  - settings file for Robot framework
sql                   - A set of test SQL scripts
config.ini            - settings file for Pytest
conftest.py           - settings file for generating a report in Report portal
db_connector.py       - class for connecting to the database and working with it
log.html              - Robot framework report file
output.xml            - Robot framework report file
pytest.ini            - settings file for Pytest (needed to connect to Report portal)
pytests.py            - test suite for Pytest
report.html           - Robot framework report file
requirements.txt      - list of libraries required for the tests to work
robottests.robot      - test suite for Robot framework

  4. Configuring PyCharm
     4.1 Importing the project into PyCharm
     4.2 Install all the necessary libraries (requirements.txt file)
     4.3 For Pytest to work correctly with Allure report, add the line --alluredir=./reports/json to Run -> Configurations -> Additional Arguments
     4.4 For correct display of .robot files, install the Robot Framework support plugin


Robot framework:

  1. It is necessary to configure the connection to the database (file resources/variables.robot)
  2. To run tests, you can open a terminal in PyCharm and enter the following command:

  robot --listener robotframework_reportportal.listener  `
  --variable RP_UUID:66e0afc8-b497-4b39-a5e2-d52c6ed93a3e `
  --variable RP_ENDPOINT:https://reportportal.epam.com `
  --variable RP_LAUNCH:aliaksei_veshtart_TEST_EXAMPLE `
  --variable RP_PROJECT:aliaksei_veshtart_personal `
  --variable RP_ATTACH_REPORT:True ./robottests.robot

  3. The tests will run and the result will be saved in the Robot Framework report and on the Report portal


Pytest:

  1. It is necessary to configure the connection to the database (file config.ini)
  2. To run tests, you can open a terminal in PyCharm and enter the following command:

py.test.exe .\pytests.py -s -q --alluredir .\reports\json --reportportal

  3. After running the tests, a report will be generated on the Report portal and the necessary files to generate a report in the Allure report
  4. Optional: if you want to generate a report in the Allure report:
       4.1 Download the utility for generating a report from the link

    https://docs.qameta.io/allure/

    4.2 unpack it, open the terminal and go to the allure\bin\ subfolder
    4.3 run the command:

    .\allure.bat generate .\reports\json\ --clean

    4.3 where .\reports\json\ path to allure files that pytest generated
    4.4 the result will be a report that can be opened with a browser
    4.5 in the repository there is such a report in the allure-report folder
