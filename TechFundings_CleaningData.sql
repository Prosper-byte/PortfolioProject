/*
Cleaning Data in SQL queries

*/

SELECT *
FROM [dbo].[tech_fundings$]

-- Standardise date format

SELECT [Funding Date], convert(Date,[Funding Date] )
FROM [dbo].[tech_fundings$]

UPDATE [dbo].[tech_fundings$]
SET [Funding Date] = convert(Date,[Funding Date] )

ALTER TABLE [dbo].[tech_fundings$]
ADD Funding_Date Date;

UPDATE [dbo].[tech_fundings$]
SET Funding_Date = [Funding Date]



---------------------------------------------------------------------------------------------------------------

--Replace Null with Unknown


---------------------------------------------------------------------------------------------------------------

--Breaking out Region/Vertical  into individual columns (Region, Vertical)

SELECT [Region/Vertical]
FROM [dbo].[tech_fundings$]

SELECT [Region/Vertical],
SUBSTRING([Region/Vertical], 1, CHARINDEX('-' , [Region/Vertical])-1) as Region,
SUBSTRING([Region/Vertical], CHARINDEX('-' , [Region/Vertical])+1,LEN([Region/Vertical])) as Vertical
FROM [dbo].[tech_fundings$] 


ALTER TABLE [dbo].[tech_fundings$]
ADD Region Nvarchar(255);

UPDATE [dbo].[tech_fundings$]
SET Region = SUBSTRING([Region/Vertical], 1, CHARINDEX('-' , [Region/Vertical])-1) 

ALTER TABLE [dbo].[tech_fundings$]
ADD Vertical Nvarchar(255);

UPDATE [dbo].[tech_fundings$]
SET Vertical =SUBSTRING([Region/Vertical], CHARINDEX('-' , [Region/Vertical])+1,LEN([Region/Vertical])) 


-------------------------------------------------------------------------------------------------------------

--Change Y and N into Yes and No in "funding greater than 50M" field

SELECT DISTINCT [funding greater than 50M], count([funding greater than 50M])
FROM [dbo].[tech_fundings$]
GROUP BY [funding greater than 50M]


SELECT [funding greater than 50M],
	CASE WHEN [funding greater than 50M] = 'N' THEN 'No' 
		 WHEN [funding greater than 50M] = 'Y' THEN 'Yes' 
	ELSE [funding greater than 50M]
	END
FROM [dbo].[tech_fundings$]

UPDATE [dbo].[tech_fundings$]
SET [funding greater than 50M] = CASE WHEN [funding greater than 50M] = 'N' THEN 'No' 
		 WHEN [funding greater than 50M] = 'Y' THEN 'Yes' 
	ELSE [funding greater than 50M]
	END

------------------------------------------------------------------------------------------------------------------------

--Remove duplicates

SELECT *
FROM [dbo].[tech_fundings$]

WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
						PARTITION BY Company,
									 [Funding Amount (USD)],
									 [Funding Stage],
									 [Funding Date],
									 Region
					    ORDER BY [index]
						) row_num
FROM [dbo].[tech_fundings$]
)
SELECT *
FROM RowNumCTE
WHERE row_num>1

--let's delete that duplicate

WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
						PARTITION BY Company,
									 [Funding Amount (USD)],
									 [Funding Stage],
									 [Funding Date],
									 Region
					    ORDER BY [index]
						) row_num
FROM [dbo].[tech_fundings$]
)
DELETE
FROM RowNumCTE
WHERE row_num>1


-----------------------------------------------------------------------------------------------------------------

--Delete columns (usually I do this for Views as opposed to imported raw data)

ALTER TABLE [dbo].[tech_fundings$]
DROP COLUMN F10, RegionSplitVertical, [Idea solves a problem]

ALTER TABLE [dbo].[tech_fundings$]
DROP COLUMN [Funding Date]

SELECT *
FROM [dbo].[tech_fundings$]

------------------------------------------------------------------------------------------------------------------------

--Capitalise the first letter only in the "Vertical" field

SELECT UPPER(LEFT(Vertical,1))+LOWER(SUBSTRING(Vertical,2,LEN(Vertical)))
FROM [dbo].[tech_fundings$]

UPDATE [dbo].[tech_fundings$]
SET Vertical = UPPER(LEFT(Vertical,1))+LOWER(SUBSTRING(Vertical,2,LEN(Vertical)))




-------------------------------------------------------------------------------------------------------------------------

--Replace Null with unknown in  [Funding Stage] field


SELECT
     SUM(CASE WHEN [Funding Stage] IS NULL THEN 1 ELSE 0 END) AS null_value_count      
    ,COUNT([Funding Stage]) AS non_null_value_count
FROM [dbo].[tech_fundings$]

SELECT [Funding Stage], ISNULL([Funding Stage],'Unknown') No_null
FROM [dbo].[tech_fundings$]
ORDER BY No_null desc


UPDATE [dbo].[tech_fundings$]
SET [Funding Stage] = ISNULL([Funding Stage],'Unknown')





