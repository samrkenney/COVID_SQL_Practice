/*Objective: create a (pivot) table where each row represents a different date between '2020-01-22' and '2022-10-18', each column represents a different US state, and the cells contain a rolling 7-day average of COVID cases per 100K residents.*/
/*Given 2 tables in a relational database: United_States_COVID_19_Cases_and_Deaths_by_State_over_Time_ARCHIVED.csv (CDC) and State_2020_2022_Pop.csv (US Census Bureau)*/
SELECT * FROM
(
SELECT
z.States,
z.Dates,
CAST(CAST(z.Rolling_7_day_new_cases AS float)/CAST(z.pop_avg AS float)*100000 AS decimal(7,2)) AS Rolling_7_day_new_cases_per_100K
FROM
(
SELECT
x.state__ States,
x.sub_date Dates,
AVG(x.new_case_) OVER(PARTITION BY x.state__ ORDER BY x.sub_date rows BETWEEN 6 preceding and current row) AS Rolling_7_day_new_cases,
x.population_avg pop_avg
FROM
(
SELECT
A.state1 state__,
A.submission_date sub_date,
ISNULL(A.new_case,0) AS new_case_,
(B._2022_Jul_1 + B._2021_Jul_1 + B._2020_Jul_1 + B._2020_Apr_1)/4 AS population_avg 
FROM COVID_practice_2.dbo.United_States_COVID_19_Cases_and_Deaths_by_State_over_Time_ARCHIVED A
INNER JOIN COVID_practice_2.dbo.State_2020_2022_Pop B ON A.state1 = B.state2
) x
) z
) tbl
PIVOT(
SUM(Rolling_7_day_new_cases_per_100K)
FOR States IN (
[AL],
[AK],
[AZ],
[AR],
[CA],
[CO],
[CT],
[DE],
[DC],
[FL],
[GA],
[HI],
[ID],
[IL],
[IN],
[IA],
[KS],
[KY],
[LA],
[ME],
[MD],
[MA],
[MI],
[MN],
[MS],
[MO],
[MT],
[NE],
[NV],
[NH],
[NJ],
[NM],
[NY],
[NC],
[ND],
[OH],
[OK],
[OR],
[PA],
[RI],
[SC],
[SD],
[TN],
[TX],
[UT],
[VT],
[VA],
[WA],
[WV],
[WI],
[WY])
) AS pivot_table
ORDER BY 1;