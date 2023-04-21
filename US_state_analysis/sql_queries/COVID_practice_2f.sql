/*Objective: create a (pivot) table where each row represents a different date between '2020-01-22' and '2022-10-18', each column represents a different US state category -- Dem Trifecta, Rep Trifecta, or none -- and the cells contain a rolling 7-day average of COVID cases per 100K residents.*/
/*Given 2 tables in a relational database: United_States_COVID_19_Cases_and_Deaths_by_State_over_Time_ARCHIVED.csv (CDC) and State_2020_2022_Pop.csv (US Census Bureau)*/
SELECT * FROM
(
SELECT
z.States,
z.Dates,
CAST(CAST(z.Rolling_7_day_new_cases AS float)/CAST(z.Region_Pop AS float)*100000 AS decimal(7,2)) AS Rolling_7_day_new_cases_per_100K
FROM
(
SELECT
A2.States_Leg States,
A2.sub_date_ Dates,
AVG(A2.Regional_Cases) OVER(PARTITION BY A2.States_Leg ORDER BY A2.sub_date_ rows BETWEEN 6 preceding and current row) AS Rolling_7_day_new_cases,
B3.Region_Pop
FROM
(
SELECT A1.States1 States_Leg,
A1.sub_date sub_date_,
SUM(A1.new_case_) AS Regional_Cases
FROM
(
SELECT
A.state1 state__,
A.submission_date sub_date,
CASE WHEN A.state1 IN ('CA', 'CO', 'CT', 'DE', 'HI', 'IL', 'ME', 'NJ', 'NM', 'NV', 'NY', 'OR', 'RI', 'WA') THEN 'Dem_Trifecta'
WHEN A.state1 IN ('AL', 'AR', 'AZ', 'FL', 'GA', 'IA', 'ID', 'IN', 'MO', 'MS', 'ND', 'NE', 'NH', 'OH', 'OK', 'SC', 'SD', 'TN', 'TX', 'UT', 'WV', 'WY') THEN 'Rep_Trifecta'
WHEN A.state1 IN ('AK', 'KS', 'KY', 'LA', 'MA', 'MD', 'MI', 'MN', 'MT', 'NC', 'PA', 'VA', 'VT', 'WI') THEN 'None'
END AS States1,
ISNULL(A.new_case,0) AS new_case_
FROM COVID_practice_2.dbo.United_States_COVID_19_Cases_and_Deaths_by_State_over_Time_ARCHIVED A
) A1
GROUP BY A1.States1, A1.sub_date
) A2
INNER JOIN
(SELECT B2.States2,
SUM(B2._2022_Jul_Pop) AS Region_Pop
FROM
(
SELECT B.state2,
CASE WHEN B.state2 IN ('CA', 'CO', 'CT', 'DE', 'HI', 'IL', 'ME', 'NJ', 'NM', 'NV', 'NY', 'OR', 'RI', 'WA') THEN 'Dem_Trifecta'
WHEN B.state2 IN ('AL', 'AR', 'AZ', 'FL', 'GA', 'IA', 'ID', 'IN', 'MO', 'MS', 'ND', 'NE', 'NH', 'OH', 'OK', 'SC', 'SD', 'TN', 'TX', 'UT', 'WV', 'WY') THEN 'Rep_Trifecta'
WHEN B.state2 IN ('AK', 'KS', 'KY', 'LA', 'MA', 'MD', 'MI', 'MN', 'MT', 'NC', 'PA', 'VA', 'VT', 'WI') THEN 'None'
END AS States2,
B._2022_Jul_1 _2022_Jul_Pop
FROM COVID_practice_2.dbo.State_2020_2022_Pop B
) B2
GROUP BY B2.States2
) B3
ON B3.States2 = A2.States_Leg
) z


) tbl
PIVOT(
SUM(Rolling_7_day_new_cases_per_100K)
FOR States IN (
[Dem_trifecta],
[Rep_Trifecta],
[None])
) AS pivot_table
ORDER BY 1;