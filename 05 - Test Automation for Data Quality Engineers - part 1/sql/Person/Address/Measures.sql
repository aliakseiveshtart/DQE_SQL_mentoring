SELECT COLUMN_NAME
	,IS_NULLABLE
	,DATA_TYPE
	,CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'Person'
	AND TABLE_NAME = 'Address'
ORDER BY COLUMN_NAME;