SELECT sum(Extention_result) AS Ext_res
	,sum(FolderFlag_result) AS Fold_res
FROM (
	SELECT FolderFlag
		,FileName
		,FileExtension
		,Extension
		,CASE
			WHEN FileExtension LIKE Extension
				THEN 0
			ELSE 1
			END AS Extention_result
		,CASE
			WHEN FolderFlag = FolderTestFlag
				THEN 0
			ELSE 1
			END AS FolderFlag_result
	FROM (
		SELECT FolderFlag
			,FileName
			,FileExtension
			,CASE
				WHEN FileName LIKE '%.%'
					THEN reverse(left(reverse(FileName), charindex('.', reverse(FileName))))
				ELSE ''
				END AS Extension
			,CASE
				WHEN FileExtension = ''
					THEN 1
				ELSE 0
				END AS FolderTestFlag
		FROM Production.Document
		) t
	) t1;
