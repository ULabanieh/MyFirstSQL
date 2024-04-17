SELECT * FROM CovidDeaths
ORDER BY 3, 4

--SELECT * FROM CovidVaccinations
--ORDER BY 3, 4

-- Select Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1, 2

-- Looking at Total Cases vs Total Death
-- Shows the likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location = 'Syria'
ORDER BY 1, 2

-- Looking at percentage of the population that got covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS InfectedPercentage
FROM CovidDeaths
WHERE location = 'Spain'
ORDER BY 1, 2

-- Looking at highest infection rates (compared to population) by countries
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS HighestInfectionPercentage
FROM CovidDeaths
GROUP BY location, population
ORDER BY HighestInfectionPercentage DESC

-- Showing countries with Highest Death Count per Population
SELECT location, MAX(total_deaths) AS HighestDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestDeathCount DESC

-- Let's break things down by continent
SELECT continent, MAX(total_deaths) AS HighestDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC

SELECT location, MAX(total_deaths) AS HighestDeathCount
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY HighestDeathCount DESC

-- Global Numbers

SELECT date, SUM(new_cases) AS new_cases_worldwide, SUM(new_deaths) AS new_deaths_worlwide, SUM(new_deaths)/SUM(NULLIF(new_cases, 0)) *100 AS DeathPercentage
FROM CovidDeaths
--WHERE location = 'United States'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2


SELECT date, new_cases, new_deaths
FROM CovidDeaths
ORDER BY date


-- Looking at Total Population vs Vaccinations

SELECT *
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date 

-- CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/population)*100 
FROM PopvsVac

-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
( 
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/population)*100 
FROM #PercentPopulationVaccinated

-- Creating view to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3


-- Additional query for creating a map, showing the number of deaths by country, as of now query is not working as expected, will try to sort it out later on
--SELECT location, population, SUM(total_cases) AS total_cases, SUM(total_deaths) AS total_deaths
--FROM CovidDeaths
--WHERE continent IS NOT NULL
--GROUP BY location, population
--ORDER BY total_deaths DESC
