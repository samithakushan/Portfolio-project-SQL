SELECT * 
FROM dbo.Coviddeaths
order by 3,4

SELECT *
FROM dbo.Coviddeaths
WHERE continent is NULL AND location like '%asia%'



--SELECT * 
--FROM dbo.Covidvaccinations
--order by 3,4

--Show Deathpercentage
SELECT Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM dbo.Coviddeaths
WHERE location like '%states%'
order by 1,2

SELECT Location, population, MAX(total_cases) as MaxInfectedCount
FROM dbo.Coviddeaths
GROUP BY location, population


--Total cases vs population
--SELECT location, date, total_cases,population, (total_cases / population)*100 as CasesvsPopulation
SELECT location, MAX(total_cases) as MaxInfectedCount,population, MAX(total_cases / population)*100 as MaxInfectedpercentage
FROM dbo.Coviddeaths
--WHERE location like '%Afghanistan%'
GROUP BY location, population
order by 4 DESC

SELECT location, date, total_cases,population
FROM dbo.Coviddeaths
WHERE location like '%Afghanistan%'
--GROUP BY location, population
order by 1,2


--Show Countries with highest death count per population
SELECT location, total_cases, MAX(CAST(total_deaths as int)) as MaxDeathCount
FROM dbo.Coviddeaths
WHERE continent is not null
GROUP BY location, total_cases
ORDER BY total_cases desc

--Analyzing though Continent
SELECT continent, MAX(cast(total_deaths as int)) as Totaldeathcount
FROM dbo.Coviddeaths
WHERE continent is NOT NULL
GROUP BY continent

-- Global numbers
SELECT dbo.Coviddeaths.date, SUM(new_cases) as TotalCases, SUM(cast(dbo.Coviddeaths.new_deaths as int)) as TotalDeaths, (SUM(cast(dbo.Coviddeaths.new_deaths as int))/NULLIF(SUM(dbo.Coviddeaths.new_cases),0)*100) as Deathpercentage
FROM dbo.Coviddeaths
GROUP BY dbo.Coviddeaths.date
Order BY 1,2 DESC


SELECT *
FROM dbo.Covidvaccinations

--Joining Vaccinations and deaths
SELECT cd.continent,
		cd.location,
		cd.date,
		cd.population,
		cv.new_vaccinations,
		SUM(cast(cv.new_vaccinations as bigint)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as CumulativeNewVaccines
		--SUM(NULLIF(cast(cv.new_vaccinations as bigint),0)) OVER (PARTITION BY cd.location)
FROM dbo.Coviddeaths cd
JOIN dbo.Covidvaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3

--DROP Table if exists #TEMPVaccinatedbypopulation
CREATE TABLE #TEMPVaccinatedbypopulation
(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	cummulativenewvaccines numeric
)

Insert into #TEMPVaccinatedbypopulation
SELECT cd.continent,
		cd.location,
		cd.date,
		cd.population,
		cv.new_vaccinations,
		SUM(cast(cv.new_vaccinations as bigint)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as CumulativeNewVaccines
		--SUM(NULLIF(cast(cv.new_vaccinations as bigint),0)) OVER (PARTITION BY cd.location)
FROM dbo.Coviddeaths cd
JOIN dbo.Covidvaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
WHERE cd.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (cummulativenewvaccines/population)*100 as populatioVSVaccines
FROM #TEMPVaccinatedbypopulation


--Creating Views
CREATE VIEW VaccinatedVSPopulation as
SELECT cd.continent,
		cd.location,
		cd.date,
		cd.population,
		cv.new_vaccinations,
		SUM(cast(cv.new_vaccinations as bigint)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as CumulativeNewVaccines
		--SUM(NULLIF(cast(cv.new_vaccinations as bigint),0)) OVER (PARTITION BY cd.location)
FROM dbo.Coviddeaths cd
JOIN dbo.Covidvaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
WHERE cd.continent IS NOT NULL
--ORDER BY 2,3

SELECT * 
FROM VaccinatedVSPopulation