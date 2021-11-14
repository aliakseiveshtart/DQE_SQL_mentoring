SELECT count(*) AS count
FROM (
	SELECT UnitMeasureCode
		,Name
		,count(*) AS count
	FROM Production.UnitMeasure
	GROUP BY UnitMeasureCode
		,Name
	HAVING count(*) > 1
	) t;
