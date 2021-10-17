-- DROP PROCEDURE Statistic;

EXEC Statistic @databasename=N'trn', @schemaname=N'hr', @tablename=N'locations';
EXEC Statistic @databasename=N'trn', @schemaname=N'hr', @tablename=N'locations, departments, dependents';
EXEC Statistic @databasename=N'trn', @schemaname=N'hr', @tablename=N'%';
