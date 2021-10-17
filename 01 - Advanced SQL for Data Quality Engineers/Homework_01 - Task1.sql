/*
 The basic idea is this:
1. parse JSON into a two-column table. The first column is the key, the second is the value.
2. Then we transcribe this table into another, where the key from the first column becomes the name of the column,
   and the column itself contains the values for this key 

split_string - splitting JSON into blocks
trim_strings - here in the column the result will be key:value pairs
               n - number of iteration in recursive query
               condition for exiting recursion if the length of the string to be parsed is 0 (the values have run out)
               WHERE len (trim (trim_str)) <> 0
               The principle of parsing in recursion: find a position with the first delimiter (,),
               then trim the string, starting with this delimiter, and pass the prepared string further into recursion.
               And so on until the end of the line
               
trim_table - here we get two columns with values key_str - key, value_str - value.
             The strings themselves are parsed - the framing characters are removed
             
transformation_table - using the PIVOT function, transform the table into the specified format.
                       The type conversion is also performed.
*/


WITH json_string
AS (
	SELECT '[{"employee_id": "5181816516151", "department_id": "1", "class": "src\bin\comp\json"}, {"employee_id": "925155", "department_id": "1", "class": "src\bin\comp\json"}, {"employee_id": "815153", "department_id": "2", "class": "src\bin\comp\json"}, {"employee_id": "967", "department_id": "", "class": "src\bin\comp\json"}]' [str]
--  SELECT '[{"employee_id": "5181816516151", "department_id": "1", "class": "src\bin\comp\json", "test": "1"}, {"employee_id": "925155", "department_id": "1", "class": "src\bin\comp\json", "test": "2"}, {"employee_id": "815153", "department_id": "2", "class": "src\bin\comp\json", "test": "3"}, {"employee_id": "967", "department_id": "", "class": "src\bin\comp\json", "test": "4"}]' [str]
    )
	,split_string
AS (
    SELECT trim('[, {}]' FROM value) AS trim_str
    FROM STRING_SPLIT((SELECT [str] FROM json_string), '}')
    WHERE trim('[, {}]' FROM value) <> ''
	)
-- uncomment for debugging
-- SELECT * FROM split_string;
	,trim_strings
AS (
   SELECT SUBSTRING(trim_str, 0, CASE 
			WHEN len(trim_str) <> 0 AND charindex(',', trim_str) = 0 THEN len(trim_str)
			ELSE charindex(',', trim_str) END) AS result
	,CASE 
		WHEN charindex(',', trim_str) <> 0
			THEN trim(SUBSTRING(trim_str, charindex(',', trim_str) + 1, LEN(trim_str) - charindex(',', trim_str) + 1))
		ELSE '' END AS trim_str
	,0 AS n
    FROM split_string
    UNION ALL
    SELECT SUBSTRING(trim_str, 0, CASE 
			WHEN len(trim_str) <> 0 AND charindex(',', trim_str) = 0 THEN len(trim_str)
			ELSE charindex(',', trim_str) END) AS result
	,CASE 
		WHEN charindex(',', trim_str) <> 0
			THEN trim(SUBSTRING(trim_str, charindex(',', trim_str) + 1, LEN(trim_str) - charindex(',', trim_str) + 1))
		ELSE '' END AS trim_str
	,n + 1 AS n
    FROM trim_strings
    WHERE len(trim(trim_str)) <> 0
    )
-- uncomment for debugging
-- SELECT * FROM trim_strings order by n;    
    ,trim_table
AS (
    SELECT trim('""' FROM substring(result, 0, charindex(':', result))) AS key_str
    	,trim(' "" ' FROM substring(result, charindex(':', result) + 1, len(result))) AS value_str
    	,ROW_NUMBER() OVER (
    		PARTITION BY trim('""' FROM substring(result, 0, charindex(':', result))) ORDER BY trim('""' FROM substring(result, 0, charindex(':', result)))
    		) AS rn
    FROM trim_strings
    )
-- uncomment for debugging    
-- SELECT * FROM trim_table; 
,transformation_table
AS (
    SELECT class
    	,CAST(department_id AS INT) AS department_id
    	,CAST(employee_id AS BIGINT) AS employee_id
    	,test
    FROM trim_table
    pivot(min(value_str) FOR key_str IN (
    			class
    			,department_id
    			,employee_id
    			,test
    			)) piv
	)
SELECT employee_id
	,department_id
	,class
FROM transformation_table;





