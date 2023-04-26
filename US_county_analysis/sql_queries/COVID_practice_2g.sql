/*Objective: depict relationship (appearance, not statistical) between US county rurality and per capita deaths involving COVID-19*/
/*Given 3 tables in a relational database: Provisional_COVID_19_Death_Counts_in_the_United_States_by_County, co_est2022_pop, NCHSURCodes2013*/
SELECT x.County_ County,
	   CAST(x.Total_COVID_Deaths/x.County_pop*10000 AS decimal(7,2)) AS COVID_Deaths_Per_10K,
	   x.NCHS_Code Rurality_Score
  FROM 
	   (
		SELECT A.County_name + '_' + A.State County_,
		       CAST(ISNULL(A.Deaths_involving_COVID_19,0) AS float) AS Total_COVID_Deaths,
			   (CAST(B._2020_Apr_1 AS float) + CAST(B._2020_Jul_1 AS float) + CAST(B._2021_Jul_1 AS float) + CAST(B._2022_Jul_1 AS float))/4 AS County_pop,
			   C._2013_code NCHS_Code
		  FROM COVID_practice_2.dbo.Provisional_COVID_19_Death_Counts_in_the_United_States_by_County A
	INNER JOIN COVID_practice_2.dbo.co_est2022_pop B ON A.County_name + '_' + A.State = B.Geographic_Area
	INNER JOIN COVID_practice_2.dbo.NCHSURCodes2013 C ON A.County_name + '_' + A.State = C.County_name + '_' + C.State_Abr
	   ) x
ORDER BY 2 DESC;
