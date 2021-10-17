/*

All requirements are implemented in the procedure
Work logic:
1. a temporary variable (@tb) is created, into which a list of columns and their types are read from the system table
    (INFORMATION_SCHEMA.COLUMNS) and creates a TYPE_FLAG column to determine the type of the column ('TEXT' or 'DIGITS').
2. A cursor is created that reads the column values from @tb one by one into variables.
   Then a query is created that calculates all the required values for each column
   and adds them to the @tb_agg temporary variable.
3. After the loop on @tb has completed, the final table is displayed, which is formed using INNER JOIN from two variables @tb and @tb_agg

*/
CREATE PROCEDURE Statistic
     @databasename NVARCHAR(255)
    ,@schemaname NVARCHAR(255)
    ,@tablename NVARCHAR(255)
AS
DECLARE @tb TABLE (DATABASE_NAME NVARCHAR(255)
                  ,TABLE_SCHEMA NVARCHAR(255)
                  ,TABLE_NAME NVARCHAR(255)
                  ,COLUMN_NAME NVARCHAR(255)
                  ,DATA_TYPE NVARCHAR(255)
                  ,TYPE_FLAG NVARCHAR(10))
DECLARE @tb_agg TABLE (DATABASE_NAME NVARCHAR(255)
                      ,TABLE_SCHEMA NVARCHAR(255)
                      ,TABLE_NAME NVARCHAR(255)
                      ,COLUMN_NAME NVARCHAR(255)
                      ,MOST_USED_VALUE NVARCHAR(max)
                      ,COUNT_DISTINCT_VALUES BIGINT
                      ,TOTAL_ROW_COUNT BIGINT
                      ,COUNT_NULL_VALUES BIGINT
                      ,SUM_UPPER BIGINT
                      ,SUM_LOWER BIGINT
                      ,[ROW_WITH_MOST_USED_VALUE_%] NUMERIC (38,2)
                      ,MIN_VALUE NVARCHAR(max)
                      ,MAX_VALUE NVARCHAR(max)
                      ,ROWS_WITH_NON_PRINTABLE_CHAR BIGINT
                      ,COUNT_OF_EMPTY_VALUES BIGINT)
DECLARE @SQLString NVARCHAR(MAX) = ''
DECLARE @db_work NVARCHAR(255)
DECLARE @schema_work NVARCHAR(255)
DECLARE @table_work NVARCHAR(255)
DECLARE @column_name NVARCHAR(MAX)
DECLARE @type_flag NVARCHAR(10)
BEGIN

-- create temporary table in @tb variable
    SET @SQLString = 'SELECT TABLE_CATALOG AS DATABASE_NAME
        ,TABLE_SCHEMA
        ,TABLE_NAME
        ,COLUMN_NAME
        ,DATA_TYPE + CASE
            WHEN CHARACTER_MAXIMUM_LENGTH IS NULL
                THEN ''''
            ELSE ''('' + trim(str(CHARACTER_MAXIMUM_LENGTH)) + '')''
            END AS DATA_TYPE
        ,CASE
            WHEN CHARACTER_MAXIMUM_LENGTH IS NOT NULL
                THEN ''TEXT''
            ELSE ''DIGITS''
            END AS TYPE_FLAG
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_CATALOG = ''' + @databasename + '''
        AND TABLE_SCHEMA = ''' + @schemaname + ''''

-- check if the% parameter did not come in the request, then add filtering by the table name to the request
    IF @tablename <> '%'
    BEGIN
       SET @SQLString =  @SQLString  + '
            AND TABLE_NAME IN (
            SELECT trim(value)
            FROM STRING_SPLIT(''' + @tablename + ''', '','')
            );
            '
    END


    INSERT INTO @tb EXEC (@SQLString)

    -- create a cursor and form a query that will return a string with aggregations
    DECLARE db_cursor CURSOR FOR
    SELECT DATABASE_NAME, TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, TYPE_FLAG FROM @tb
    OPEN db_cursor
    FETCH NEXT FROM db_cursor INTO @db_work, @schema_work, @table_work, @column_name, @type_flag

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @SQLString = '
            SELECT ''' + @db_work + ''' AS DATABASE_NAME, '''
                +  @schema_work + ''' AS TABLE_SCHEMA, ''' + @table_work + ''' AS TABLE_NAME, ''' + @column_name + ''' AS COLUMN_NAME
                ,min(' + @column_name + ') AS MOST_USED_VALUE
                ,COUNT_DISTINCT_VALUES
                ,TOTAL_ROW_COUNT
                ,name_null_count AS COUNT_NULL_VALUES
                ,SUM_UPPER
                ,SUM_LOWER
                ,cast(round(Most_used_value * 100 / Total_row_count, 2) as NUMERIC (38,2)) AS [ROW_WITH_MOST_USED_VALUE_%]
                ,MIN_VALUE
                ,MAX_VALUE
                ,ROWS_WITH_NON_PRINTABLE_CHAR
                ,COUNT_OF_EMPTY_VALUES
            FROM (
                SELECT ' + @column_name + '
                    ,count(*) OVER () AS Count_DISTINCT_values
                    ,sum(count(*)) OVER () AS Total_row_count
                    ,SUM(SUM(CASE
                                WHEN ' + @column_name + ' IS NULL
                                    THEN 1
                                ELSE 0
                                END)) OVER () AS name_null_count
                    ,sum(CASE
                            WHEN ' + @column_name + ' = upper(' + @column_name + ') collate SQL_Latin1_General_CP1_CS_AS
                                THEN 1
                            ELSE 0
                            END) OVER () AS sum_upper
                    ,sum(CASE
                            WHEN ' + @column_name + ' = LOWER(' + @column_name + ') collate SQL_Latin1_General_CP1_CS_AS
                                THEN 1
                            ELSE 0
                            END) OVER () AS sum_lower
                    ,COUNT(*) AS Most_used_value
                    ,SUM(
                        sum (
                            CASE WHEN ''' + @type_flag + ''' = ''TEXT'' THEN
                                    CASE WHEN ' + @column_name + ' = '''' or ' + @column_name + ' IS NULL THEN 1 ELSE 0 END
                                 WHEN ''' + @type_flag + ''' = ''DIGITS'' THEN
                                    CASE WHEN ' + @column_name + ' IS NULL THEN 1 ELSE 0 END
                            ELSE 0 END
                            )
                            ) OVER () AS Count_of_empty_values
                    ,max(COUNT(*)) OVER () AS MAX_Most_used_value
                    ,MIN(' + @column_name + ') OVER () AS MIN_value
                    ,MAX(' + @column_name + ') OVER () AS MAX_value
                    ,sum(sum(CASE
                                WHEN ' + @column_name + ' LIKE ''%[^ !-~]%'' COLLATE Latin1_General_BIN
                                    THEN 1
                                ELSE 0
                                END)) OVER () AS Rows_with_non_printable_char
                FROM ' + @db_work + '.' +  @schema_work + '.' + @table_work + '
                GROUP BY ' + @column_name + '
                ) t
            WHERE MAX_MOST_USED_VALUE = MOST_USED_VALUE
            GROUP BY COUNT_DISTINCT_VALUES
                ,TOTAL_ROW_COUNT
                ,NAME_NULL_COUNT
                ,SUM_UPPER
                ,SUM_LOWER
                ,MOST_USED_VALUE
                ,MIN_VALUE
                ,MAX_VALUE
                ,ROWS_WITH_NON_PRINTABLE_CHAR
                ,COUNT_OF_EMPTY_VALUES;
            '
        INSERT INTO @tb_agg EXEC (@SQLString)
        FETCH NEXT FROM db_cursor INTO @db_work, @schema_work, @table_work, @column_name, @type_flag
    END;
    CLOSE db_cursor;
    DEALLOCATE db_cursor;
    -- we form the final table
    SELECT t2.DATABASE_NAME
    	,t2.TABLE_SCHEMA
    	,t2.TABLE_NAME
    	,t2.COLUMN_NAME
    	,t2.DATA_TYPE
    	,t1.MOST_USED_VALUE
    	,t1.COUNT_DISTINCT_VALUES
    	,t1.TOTAL_ROW_COUNT
    	,t1.COUNT_NULL_VALUES
    	,t1.SUM_UPPER
    	,t1.SUM_LOWER
    	,t1.[ROW_WITH_MOST_USED_VALUE_%]
    	,t1.MIN_VALUE
    	,t1.MAX_VALUE
    	,t1.ROWS_WITH_NON_PRINTABLE_CHAR
    	,t1.COUNT_OF_EMPTY_VALUES
    FROM @tb_agg t1
    INNER JOIN @tb t2 ON t1.DATABASE_NAME = t2.DATABASE_NAME
    	AND t1.TABLE_SCHEMA = t2.TABLE_SCHEMA
    	AND t1.TABLE_NAME = t2.TABLE_NAME
    	AND t1.COLUMN_NAME = t2.COLUMN_NAME;

END;
