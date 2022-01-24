
								/*-- COVID ANALYSIS --*/


--Database name --> CovidAnalysis
--Tables --> CovidDeaths ; CovidVaccinations 

--this data was extracted on : '05-09-2021' (so, numbers and conclusions are based on the data till the given date.)

/* Note :
How countries are specified :	location-India, continent-Asia.
How continents are specified :	location-Asia, continent-NULL.
(in the given Dataset)
*/


--===================================================================================================================================================================================================


--					***** overview of the Data presented *****

SELECT * FROM CovidAnalysis..CovidDeaths
	ORDER BY 3,4;

--SELECT * FROM CovidAnalysis..CovidVaccinations
--ORDER BY 3,4;


--to get the names of all Columns in the Tables.
use CovidAnalysis;
SELECT /* top 5 */ COLUMN_NAME
  FROM INFORMATION_SCHEMA.COLUMNS
 WHERE TABLE_CATALOG = 'CovidAnalysis' -- the database
   AND TABLE_NAME = 'CovidDeaths';


--===================================================================================================================================================================================================


--					***** #1 ‘MORTALITY RATE’ *****

--'Overall' view of 'Total_Cases', 'Total_Deaths' and 'Mortality_Rates' in the World, till date.

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as Mortality_Rate
From CovidAnalysis..CovidDeaths
--Where location like '%indi%'
where continent is not null  --i.e. only COUNTRIES.
--Group By date
order by 1,2

--		Conclusion : (India Specific)

--lowest death rate was 1.08600192167042%...went roughly around 3.59587180879957% at peak.. 
SELECT MIN((total_deaths/total_cases)*100) as Min_Mortality_Rate,
		MAX((total_deaths/total_cases)*100) as Max_Mortality_Rate
	FROM CovidAnalysis..CovidDeaths
	WHERE location like '%indi%';

--also, after 62 cases, we had the 1st Death, on 11th_March_2020.
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Mortality_Rate
	FROM CovidAnalysis..CovidDeaths
	WHERE location like '%indi%' AND total_deaths>=1
	ORDER BY location,date;

--and currently if u're in INDIA, and infected with Covid, there is just 1.3% chance that u may die of it!


--===================================================================================================================================================================================================


--					***** #2 Plain and simple, Highest No. of Deaths till date *****

SELECT location, MAX(cast(total_deaths as int)) as Total_Death_Count_till_date
	FROM CovidAnalysis..CovidDeaths
	WHERE continent is not null
	GROUP BY location
	ORDER BY Total_Death_Count_till_date DESC;
--1.United States - 647579, 2.Brazil - 582670, 3.India - 440225, 4.Mexico - 262221, 5.Peru - 198420


--breaking same thing down by CONTINENTS:
SELECT continent, MAX(cast(total_deaths as int)) as Total_Death_Count_till_date
	FROM CovidAnalysis..CovidDeaths
	WHERE continent is not null
	GROUP BY continent
	ORDER BY Total_Death_Count_till_date DESC;


--===================================================================================================================================================================================================


--					***** #3 Countries with the Highest Infection_Rate compared to Population *****
 
 SELECT location, population, MAX(total_cases) as Max_Total_Cases,
		MAX((total_cases/population)*100) as Max_Infected_Population_Percent
	FROM CovidAnalysis..CovidDeaths
	GROUP BY location, population
	ORDER BY Max_Infected_Population_Percent DESC;
--India is at 106th position,with 2.36441032171779% as highest ever.


-- very worsely affected countries, with %population infected >10.
--(not by numbers, but by % to population) 
--(small population countries might top this list let's see)
SELECT location, population, MAX(total_cases) as Max_Total_Cases,
		MAX((total_cases/population)*100) as Max_Infected_Population_Percent
	FROM CovidAnalysis..CovidDeaths
	WHERE ((total_cases/population)*100)>10
	GROUP BY location, population
	ORDER BY Max_Infected_Population_Percent DESC;
--big countries here are : Israel, USA, European countries mostly like : UK, France, Netherland, Spain, Belgium.


--===================================================================================================================================================================================================


--					***** #4 On a particular DATE, what were the Cases, Deaths, Mortality around the world *****
 
SELECT date, SUM(new_cases) as TodaysWorldwide_NewCases_total, 
				SUM(cast(new_deaths as int)) as TodaysWorldwide_Deaths_total, 
				(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as TodaysWorldwide_MortalityRate
	FROM CovidAnalysis..CovidDeaths
	WHERE continent is not NULL
	GROUP BY date
	ORDER BY date;
--SUM(new_cases) ==> shows the no. of new cases arised around the world, on a particular DATE.
--Cases started on 23rd_Jan_2020, 1st day 98 cases around the world....or maybe the reporting of cases started that day!
--SUM(cast(new_deaths as int)) ==> shows the no. of Deaths counted around the world, on a particular DATE.
--Deaths also started on 23rd_Jan_2020, 1st day only 1 death out of the 98 cases detected around the world.

SELECT date, SUM(new_cases) as TodaysWorldwide_NewCases_total, 
				SUM(cast(new_deaths as int)) as TodaysWorldwide_Deaths_total, 
				(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as TodaysWorldwide_MortalityRate
	FROM CovidAnalysis..CovidDeaths
	WHERE continent is not NULL
	GROUP BY date
	ORDER BY TodaysWorldwide_MortalityRate desc;
--Maximum Mortality_Rate on a single day, around the world was 28.3687943262411%, which was on 24th February 2020. 
/* Similarly -
Maximum Total_New_Cases on a single day, around the world were 9,05,932, which was on 28th April 2021.
Maximum Total_Deaths on a single day, around the world were 17,977, which was on 20th January 2021. 
*/


--===================================================================================================================================================================================================


--					***** #5 Total Global Population vs. Total Global 'VACCINATED' Population (with 'Rolling counter' on the fly) *****

--here, the last column is a 'Cumulative/Rolling Counter' using OVER and PARTITION BY

SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccs.new_vaccinations, 
		SUM(CONVERT(int, vaccs.new_vaccinations)) OVER (Partition By deaths.location ORDER BY deaths.location, deaths.date) as Vaccs_Counter_Cumulative
	FROM CovidAnalysis..CovidDeaths deaths
	JOIN CovidAnalysis..CovidVaccinations vaccs
	ON deaths.location=vaccs.location AND deaths.date=vaccs.date
	WHERE deaths.continent is not NULL  --implies Countries only.
	ORDER BY 2,3;

SELECT * FROM CovidAnalysis..CovidVaccinations


--===================================================================================================================================================================================================


--					***** #6 using CTE --> How much % of Population is 'VACCINATED'? ...on the Fly. *****

--here, the last column is a 'Cumulative/Rolling Counter' using OVER and PARTITION BY

With PopVsVacc (continent, location, date, population, new_vaccinations, Vaccs_Counter_Rolling)
as
(
	SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccs.new_vaccinations, 
		SUM(CONVERT(int, vaccs.new_vaccinations)) OVER (Partition By deaths.location ORDER BY deaths.location, deaths.date) as Vaccs_Counter_Rolling
	FROM CovidAnalysis..CovidDeaths deaths
	JOIN CovidAnalysis..CovidVaccinations vaccs
	ON deaths.location=vaccs.location AND deaths.date=vaccs.date
	WHERE deaths.continent is not NULL  --implies Countries only.
	--ORDER BY 2,3  DONT USE HERE, use in the end.
)
SELECT *, ((Vaccs_Counter_Rolling/population)*100) as Percent_Population_Vacced
	FROM PopVsVacc 
	ORDER BY location, date ;

--To select the Current Max Vaccinated Country by Population (using this CTE) (easier way exists though)

/* SELECT location, MAX(population) as Population, MAX(Vaccs_Counter_Rolling) as PeopleVaccinated, 
		((MAX(Vaccs_Counter_Rolling)/MAX(population))*100) as Percent_Population_Vacced
	FROM PopVsVacc 
	--ORDER BY location, date ;
	GROUP BY location
	ORDER BY Percent_Population_Vacced DESC; */


--===================================================================================================================================================================================================


--					***** #7 using TEMP TABLE --> How much % of Population is 'VACCINATED'? ...on the Fly. *****

-- (same as before, but using Temp Tables instead of CTE, and limited to 'India' only.)

DROP Table if exists #PopVsVaccTemp
CREATE Table #PopVsVaccTemp
(
continent_temp nvarchar(255),
location_temp nvarchar(255),
date_temp datetime,
population_temp numeric,
new_vaccs_temp numeric,
cumulative_vaccs_temp numeric
)

INSERT INTO #PopVsVaccTemp
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccs.new_vaccinations, 
		SUM(CONVERT(int, vaccs.new_vaccinations)) OVER (Partition By deaths.location ORDER BY deaths.location, deaths.date) as Vaccs_Counter_Rolling
	FROM CovidAnalysis..CovidDeaths deaths
	JOIN CovidAnalysis..CovidVaccinations vaccs
	ON deaths.location=vaccs.location AND deaths.date=vaccs.date
	WHERE deaths.continent is not NULL  --implies Countries only.
	--ORDER BY 2,3  DONT USE HERE, use in the end.

SELECT *, ((cumulative_vaccs_temp/population_temp)*100) as Percent_Population_Vacced
	FROM #PopVsVaccTemp
	WHERE location_temp='India'
	ORDER BY location_temp, date_temp ;

--Vaccination in India started on 16_January_2021 ; with 1,91,181 vaccines on 1st day ; covering just 0.0137203789750371% of the population.
--As of Today, 5_September_2021 ; with 5,87,9308 vaccines dispensed today, total count has gone up to 60,63,70,676 vaccines till date ; covering a massive 43.5170622293504251% of the population.
--note : this includes people who've recieved Both doses, as well as ones with just 1st dose.


--===================================================================================================================================================================================================


--					***** #8 using VIEWS (to store Data for later Visualization.) *****

DROP View if exists DeathsPerContinent;

USE CovidAnalysis;

CREATE View DeathsPerContinent as
SELECT location, MAX(cast(total_deaths as int)) as Total_Death_Count_till_date
	FROM CovidAnalysis..CovidDeaths
	WHERE continent is null --i.e. select only Continents.
	GROUP BY location;
--	ORDER BY Total_Death_Count_till_date DESC;

SELECT location, Total_Death_Count_till_date FROM DeathsPerContinent 
	WHERE location not in ('World', 'European Union', 'International')
	ORDER BY Total_Death_Count_till_date DESC;

sp_helptext DeathsPerContinent;


--===================================================================================================================================================================================================


--					***** #9 overall VACCINATION Stats. *****

--'Overall' view of 'Population', 'People Vaccinated', '% of World Vaccinated' till date.

Select SUM(a.population) - SUM(cast(a.new_deaths as int)) as World_Population, 
	SUM(cast(b.new_vaccinations as numeric)) as People_Vaccinated, 
	SUM(cast(b.new_vaccinations as numeric))/(SUM(a.population)-SUM(cast(new_deaths as int)))*100 as Percent_Popln_Vaccd
From CovidAnalysis..CovidVaccinations b
INNER JOIN CovidAnalysis..CovidDeaths a
ON a.location=b.location and a.date=b.date and a.continent=b.continent
--Where location like '%indi%'
where a.continent is not null --i.e. only Continents.
--Group By date
order by 1

--		Conclusion : (India Specific)

Select SUM(a.population) - SUM(cast(a.new_deaths as int)) as Indian_Population, 
	SUM(cast(b.new_vaccinations as numeric)) as People_Vaccinated, 
	SUM(cast(b.new_vaccinations as numeric))/(SUM(a.population)-SUM(cast(new_deaths as int)))*100 as Percent_Popln_Vaccd
From CovidAnalysis..CovidVaccinations b
INNER JOIN CovidAnalysis..CovidDeaths a
ON a.location=b.location and a.date=b.date and a.continent=b.continent
where a.continent is not null and a.location like '%indi%'--i.e. only Continents.
--Group By date
order by 1


--===================================================================================================================================================================================================


--					***** #10 Places which are at least risk as of now. (highest People Vaccinated per 100) *****

SELECT continent, location, 
	MAX(people_vaccinated_per_hundred) as Ppl_vaccd_per_100, 
	MAX(people_fully_vaccinated_per_hundred) as Ppl_FullyVaccd_per_100
	FROM CovidAnalysis..CovidVaccinations
	WHERE continent is not null --i.e. only Countries included.
	GROUP BY continent, location
	ORDER BY Ppl_vaccd_per_100, Ppl_FullyVaccd_per_100 DESC


--===================================================================================================================================================================================================
