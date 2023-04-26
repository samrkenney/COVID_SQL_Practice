/*Objective: create a (pivot) table where each row represents a different date between '2020-01-22' and '2022-10-18', each column represents a different US Census Bureau-defined region, and the cells contain a rolling 7-day average of COVID cases per 100K residents.*/
/*Given 2 tables in a relational database: United_States_COVID_19_Cases_and_Deaths_by_State_over_Time_ARCHIVED.csv (CDC) and State_2020_2022_Pop.csv (US Census Bureau)*/
SELECT *
  FROM
       (
        SELECT z.Regions,
               z.Dates,
               CAST(CAST(z.Rolling_7_day_new_cases AS float)/CAST(z.Region_Pop AS float)*100000 AS decimal(7,2)) AS Rolling_7_day_new_cases_per_100K
          FROM
               (
                SELECT A2.Region_Name Regions,
                       A2.sub_date_ Dates,
                       AVG(A2.Regional_Cases) OVER(PARTITION BY A2.Region_Name ORDER BY A2.sub_date_ rows BETWEEN 6 preceding and current row) AS Rolling_7_day_new_cases,
                       B3.Region_Pop
                  FROM
                       (
                        SELECT A1.Region1 Region_Name,
                               A1.sub_date sub_date_,
                               SUM(A1.new_case_) AS Regional_Cases
                          FROM
                               (
                                SELECT A.state1 state__,
                                       A.submission_date sub_date,
                                       CASE WHEN A.state1 IN ('ME', 'NH', 'VT', 'CT', 'MA', 'RI', 'NY', 'PA', 'NJ') THEN 'Northeast'
                                            WHEN A.state1 IN ('IL', 'IN', 'MI', 'OH', 'WI', 'IA', 'KS', 'MN', 'MO', 'NE', 'ND', 'SD') THEN 'Midwest'
                                            WHEN A.state1 IN ('DE', 'DC', 'MD', 'FL', 'GA', 'NC', 'SC', 'VA', 'WV', 'KY', 'AL', 'MS', 'TN', 'AR', 'LA', 'OK', 'TX') THEN 'South'
                                            WHEN A.state1 IN ('AZ', 'CO', 'ID', 'MT', 'NV', 'NM', 'UT', 'WY', 'AK', 'CA', 'HI', 'OR', 'WA') THEN 'West'
                                          END AS Region1,
                                       ISNULL(A.new_case,0) AS new_case_
                                  FROM COVID_practice_2.dbo.United_States_COVID_19_Cases_and_Deaths_by_State_over_Time_ARCHIVED A
                               ) A1
                        GROUP BY A1.Region1, A1.sub_date
                       ) A2
            INNER JOIN (
                        SELECT B2.Region2,
                               SUM(B2._2022_Jul_Pop) AS Region_Pop
                          FROM
                               (
                                SELECT B.state2, 
                                       CASE WHEN B.state2 IN ('ME', 'NH', 'VT', 'CT', 'MA', 'RI', 'NY', 'PA', 'NJ') THEN 'Northeast'
                                            WHEN B.state2 IN ('IL', 'IN', 'MI', 'OH', 'WI', 'IA', 'KS', 'MN', 'MO', 'NE', 'ND', 'SD') THEN 'Midwest'
                                            WHEN B.state2 IN ('DE', 'DC', 'MD', 'FL', 'GA', 'NC', 'SC', 'VA', 'WV', 'KY', 'AL', 'MS', 'TN', 'AR', 'LA', 'OK', 'TX') THEN 'South'
                                            WHEN B.state2 IN ('AZ', 'CO', 'ID', 'MT', 'NV', 'NM', 'UT', 'WY', 'AK', 'CA', 'HI', 'OR', 'WA') THEN 'West'
                                          END AS Region2,
                                       B._2022_Jul_1 _2022_Jul_Pop
                                  FROM COVID_practice_2.dbo.State_2020_2022_Pop B
                               ) B2
                        GROUP BY B2.Region2
                       ) B3
                      ON B3.Region2 = A2.Region_Name
               ) z
       ) tbl
PIVOT (
       SUM(Rolling_7_day_new_cases_per_100K)
       FOR Regions IN
       (
       [Northeast],
       [South],
       [West],
       [Midwest]
       )
      ) AS pivot_table
  ORDER BY 1;