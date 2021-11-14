SELECT count(*) AS count
FROM (
	SELECT DISTINCT StateProvinceID
	FROM Person.Address
	EXCEPT
	SELECT DISTINCT StateProvinceID
	FROM Person.StateProvince
	) t;
