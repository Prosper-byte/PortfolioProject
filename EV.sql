---EDA 

---Data: Electric vehicles
 
-----------------------------------------------------------------------------------------------------------------------------
---Our data
Select * 
From [dbo].['Electric Vehicle Population Dat$']

Select count(*)
From [dbo].['Electric Vehicle Population Dat$']

 
Select min([Model Year]) as first_year, max([Model Year]) as last_year
From [dbo].['Electric Vehicle Population Dat$']

-- Checking duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY [DOL Vehicle ID],
					 [Model Year], 
					 [Make],
					 [Model],[Model Year],
					 [Electric Vehicle Type],
					 [Electric Utility],
					 [Base MSRP]
				 ORDER BY
					[Model Year]
					) row_num
From [dbo].['Electric Vehicle Population Dat$']
)
Select *
From RowNumCTE
Where row_num > 1


---This shows that there are no duplicates. 

---Let's check missing values.


Select count([VIN (1-10)]) vin, count([County]) county, count([City]) city, count([State]) state, 
	   count([ZIP Code])zip_code, count([Model Year]) model_year,count([Make]) make, count([Model]) model, 
	   count([Electric Vehicle Type]) electric_vehicle_type, count([Clean Alternative Fuel Vehicle (CAFV) Eligibility]) cafv_eligibility,
	   count([Electric Range]) electric_range, count([Base MSRP]) base_msrp, count([Legislative District]) legislative_district,
	   count([DOL Vehicle ID]) dol_vehicle_id, count([Vehicle Location]) vehicle_location, count([Electric Utility]) electric_utility
From [dbo].['Electric Vehicle Population Dat$']
UNION ALL
Select vin/96961 *100, Round(cast(county as float)/96961 *100,2), city/96961 *100, state/96961 *100, zip_code/96961 *100,
	   model_year/96961 *100, make/96961 *100, model/96961 *100, electric_vehicle_type/96961 *100, cafv_eligibility/96961 *100,
	   electric_range/96961 *100, base_msrp/96961 *100, Round(cast(legislative_district as float)/96961 *100,2), dol_vehicle_id/96961 *100, 
	   Round(cast(vehicle_location as float)/96961 *100,2),
	   Round(cast(electric_utility as float)/96961 *100,2)
From
(Select count([VIN (1-10)]) vin, count([County]) county, count([City]) city, count([State]) state, 
	   count([ZIP Code])zip_code, count([Model Year])model_year,count([Make]) make, count([Model]) model, 
	   count([Electric Vehicle Type]) electric_vehicle_type, count([Clean Alternative Fuel Vehicle (CAFV) Eligibility]) cafv_eligibility,
	   count([Electric Range]) electric_range, count([Base MSRP]) base_msrp, count([Legislative District]) legislative_district,
	   count([DOL Vehicle ID]) dol_vehicle_id, count([Vehicle Location]) vehicle_location, count([Electric Utility]) electric_utility
From [dbo].['Electric Vehicle Population Dat$'])a

--The column that has the most missing values is electric_utility. But we will not dismiss this as missing values only amount to less than 2% of the data


-------------------------------------------------------------------------------------------------------------------------

---What are the top 3 most produced cars?

SELECT TOP 3
Make, count(*) num_EV, 
Round(cast(count(Make) as float)*100/(SELECT count([DOL Vehicle ID]) FROM [dbo].['Electric Vehicle Population Dat$']), 2) percent_of_total
FROM [dbo].['Electric Vehicle Population Dat$']
GROUP BY Make
Order by 2 desc

---Top 3 are TESLA, NISSAN, CHEVROLET with Tesla accounting for over 40% of the market
---What are their corresponding models?
SELECT Make,Model, count(*) num_EV
FROM [dbo].['Electric Vehicle Population Dat$']
WHERE Make IN ('TESLA', 'Nissan', 'CHEVROLET')
GROUP BY Make,Model
Order by 1 desc, 3 desc



DROP TABLE if exists Percent_Per_Make
CREATE TABLE Percent_Per_Make
(Make nvarchar (255),
Model nvarchar(255),
Num_EV numeric)
INSERT INTO Percent_Per_Make 
SELECT Make,Model, count(*) num_EV
FROM [dbo].['Electric Vehicle Population Dat$']
WHERE Make IN ('TESLA', 'Nissan', 'CHEVROLET')
GROUP BY Make,Model
Order by 1 desc, 3 desc

SELECT *,Num_EV/(SELECT SUM(Num_EV) FROM Percent_Per_Make)*100 Percent_Of_TopEV
FROM Percent_Per_Make
GROUP BY Make, Model, Num_EV
ORDER BY 4 desc


---This shows that production of TESLA Model 3 is way ahead with just over 30%.


---Let's look at the production of Model 3 throughout the year

SELECT  Model, Make,[Model Year], count(*) num_EV
FROM [dbo].['Electric Vehicle Population Dat$']
WHERE Make = 'TESLA' AND Model = 'Model 3'
GROUP BY Model, Make, [Model Year]
Order by 3 
---There was a huge jump from 2017 to 2018 when it recorded its highest ever score. Since then the production has been steady but high.


---What year has seen the highest production?

SELECT TOP 1
[Model Year], count(make) num_EV
FROM [dbo].['Electric Vehicle Population Dat$']
GROUP BY [Model Year]
Order by  2 desc


---2021 was the year that produced most cars


---Which car was produced the most in 2021?
                
SELECT TOP 1
Make,[Model], count(make) num_EV 
FROM [dbo].['Electric Vehicle Population Dat$']
WHERE [Model Year] = '2021'
GROUP BY [Model Year], Make,[Model] 
Order by  3 desc



---Let's categorise car production in 2021 by low, avergage and high

DROP TABLE if exists Average_Best_Year
CREATE TABLE Average_Best_Year
(Average_count numeric)
INSERT INTO Average_Best_Year
SELECT 
Avg(num_EV) Average_count
FROM (SELECT
Make,[Model], count(make) num_EV 
FROM [dbo].['Electric Vehicle Population Dat$']
WHERE [Model Year] = '2021'
GROUP BY [Model Year], Make,[Model] 
)a


SELECT *, 
Case WHEN Num_EV >= (SELECT Average_count FROM Average_Best_Year)*1.75 THEN 'HIGH'
	 WHEN Num_EV > (SELECT Average_count FROM Average_Best_Year) THEN 'AVERAGE'
	 ELSE 'LOW'
	 END ProductionCategory
FROM(SELECT Make,[Model], count(make) Num_EV 
FROM [dbo].['Electric Vehicle Population Dat$']
WHERE [Model Year] = '2021'
GROUP BY [Model Year], Make,[Model] )a
GROUP BY  Make,[Model], Num_EV
ORDER BY Make,Num_EV desc


---TESLA Model Y and Model 3 are the most produced EV. Which one has a higher production on average?

SELECT Make, model, Avg(num_EV) Average_Production
FROM(
SELECT 
Make, model, [Model Year], COUNT(*) num_EV
FROM [dbo].['Electric Vehicle Population Dat$']
WHERE Make = 'TESLA' AND Model IN ('Model Y','Model 3')
GROUP BY Make, model, [Model Year]
)b 
GROUP BY  Make, model
ORDER BY 3 desc


---Model Y has a higher production on average

---Let's look at the difference in features between model Y and 3

SELECT Model,[Electric Vehicle Type], [Model Year],[Electric Vehicle Type], [Clean Alternative Fuel Vehicle (CAFV) Eligibility],
[Electric Range], [Base MSRP]
FROM [dbo].['Electric Vehicle Population Dat$']
WHERE Make = 'TESLA' AND Model = 'Model 3'
EXCEPT
SELECT Model,[Electric Vehicle Type], [Model Year],[Electric Vehicle Type], [Clean Alternative Fuel Vehicle (CAFV) Eligibility],
[Electric Range], [Base MSRP]
FROM [dbo].['Electric Vehicle Population Dat$']
WHERE Make = 'TESLA' AND Model = 'Model Y'


---Number of top most produced vehicles per electric type


SELECT Make, [Electric Vehicle Type],COUNT ([Electric Vehicle Type]) Num_EV
FROM [dbo].['Electric Vehicle Population Dat$']
WHERE Make IN ('TESLA', 'CHEVROLET','NISSAN')
GROUP BY  [Electric Vehicle Type],Make

---All TESLA and NISSAN cars are BEV. Just under 50% of Chevrolet cars are BEV.


---Top Production per make FROM Top 3 bracket per make

SELECT Make, Model,[Electric Vehicle Type],num_EV,SUM(num_EV) OVER (PARTITION BY Make order by Model) AS RollingTotal
FROM (
SELECT Make,[Model],[Electric Vehicle Type],[Electric Utility], COUNT(Make) num_EV,
NTILE(3) OVER (PARTITION BY Make ORDER BY COUNT(*) DESC) production_bracket
FROM [dbo].['Electric Vehicle Population Dat$']
WHERE [Electric Utility] IS NOT NULL
GROUP BY Make, [Model],[Electric Vehicle Type], [Electric Utility]
HAVING COUNT(*)>= 100
)a  
WHERE production_bracket = 1

CREATE TABLE #HighestProducedModel
(Make nvarchar (255),
Model nvarchar (255),
[Electric Vehicle Type] nvarchar (255),
num_EV numeric,
RollingTotal numeric
)
INSERT INTO #HighestProducedModel
SELECT Make, Model,[Electric Vehicle Type], num_EV, SUM(num_EV) OVER (PARTITION BY Make order by Model) AS RollingTotal
FROM (
SELECT Make,[Model], COUNT(Make) num_EV,[Electric Vehicle Type],
NTILE(3) OVER (PARTITION BY Make ORDER BY COUNT(*) DESC) production_bracket
FROM [dbo].['Electric Vehicle Population Dat$']
WHERE [Electric Utility] IS NOT NULL
GROUP BY Make, [Model],  [Electric Vehicle Type]
)a  
WHERE production_bracket = 1

SELECT Make, Model,RollingTotal, First_value(RollingTotal) OVER (PARTITION BY Make ORDER BY Model) Highest_Count
FROM #HighestProducedModel
GROUP BY Make, Model, RollingTotal 
ORDER BY Make, RollingTotal desc 


---Creating View to store data for later visualisation
 
Create View HighestProducedModel AS
SELECT Make, Model,[Electric Vehicle Type],City, num_EV, SUM(num_EV) OVER (PARTITION BY Make order by Model) AS RollingTotal
FROM (
SELECT Make,[Model], COUNT(Make) num_EV,[Electric Vehicle Type],City,
NTILE(5) OVER (PARTITION BY Make ORDER BY COUNT(*) DESC) production_bracket
FROM [dbo].['Electric Vehicle Population Dat$']
WHERE [Electric Utility] IS NOT NULL
GROUP BY Make, [Model],  [Electric Vehicle Type], City
)a  
WHERE production_bracket = 1
