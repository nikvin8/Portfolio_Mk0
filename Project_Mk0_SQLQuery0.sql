SELECT * FROM Project_Mk1..CovidDeaths
ORDER BY 3,4

SELECT * FROM Project_Mk1..CovidVaccinations
ORDER BY 3,4

-- Select the data that we are going to use

SELECT location, date, total_cases,new_cases, total_deaths, population
FROM Project_Mk1..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases VS Total Deaths
-- Shows the possibility of death if you have been exposed to Covid in your country

SELECT location, MAX(CAST(total_cases AS float)) as total_cases, MAX(CAST(total_deaths AS float)) as total_deaths, 
ROUND(MAX(CAST(total_deaths AS float))/MAX(CAST(total_cases AS float))* 100, 2) AS DeathPercentage
FROM Project_Mk1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY location

-- Looking at Total Cases vs Population
-- Shows what percentage of population had got Covid

SELECT location, population, MAX(CAST(total_cases AS float)) as total_cases, 
ROUND(MAX(CAST(total_cases AS float))/AVG(CAST(population AS float))* 100, 2) AS Percent_Infected
FROM Project_Mk1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY total_cases DESC

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(CAST(total_cases AS float)) as total_cases, 
ROUND(MAX(CAST(total_cases AS float))/AVG(CAST(population AS float))* 100, 2) AS Percent_Infected
FROM Project_Mk1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Percent_Infected DESC

-- Showing countries with the highest number of deaths per population

SELECT location, MAX(CAST(total_deaths AS int)) as total_deaths 
FROM Project_Mk1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_deaths DESC

-- Let's break it down by continent

SELECT location, MAX(CAST(total_deaths AS int)) AS total_deaths
FROM Project_Mk1..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY total_deaths DESC

-- Global Numbers

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, 
CASE
	WHEN SUM(new_cases)=0 THEN NULL
	ELSE ROUND(SUM(new_deaths)/SUM(new_cases) * 100, 2) 
	END AS death_percentage
FROM Project_Mk1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2


-- Looking at Total Population VS Vaccinations

WITH PopvsVac(Continent, Location, Date, Population, New_vaccinations, Total_vaccinated)
AS (
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(CAST(Vac.new_vaccinations AS float)) OVER (PARTITION BY Dea.location ORDER BY Dea.date)
	AS total_vaccinated
FROM Project_Mk1..CovidDeaths AS Dea
JOIN Project_Mk1..CovidVaccinations AS Vac
	ON  Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL and Vac.new_vaccinations IS NOT NULL
)
SELECT *, ROUND((Total_vaccinated/Population) * 100, 2) AS Vaccinated_percentage FROM PopvsVac
ORDER BY 2, 3



-- Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population float,
New_vaccinations float,
Total_vaccinated float)

INSERT INTO #PercentPopulationVaccinated
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(CAST(Vac.new_vaccinations AS float)) OVER (PARTITION BY Dea.location ORDER BY Dea.date)
	AS total_vaccinated
FROM Project_Mk1..CovidDeaths AS Dea
JOIN Project_Mk1..CovidVaccinations AS Vac
	ON  Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL and Vac.new_vaccinations IS NOT NULL

SELECT *, ROUND((Total_vaccinated/Population) * 100, 2) AS Vaccinated_percentage 
FROM #PercentPopulationVaccinated
ORDER BY 2, 3



-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
	SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
	SUM(CAST(Vac.new_vaccinations AS float)) OVER (PARTITION BY Dea.location ORDER BY Dea.date)
		AS total_vaccinated
	FROM Project_Mk1..CovidDeaths AS Dea
	JOIN Project_Mk1..CovidVaccinations AS Vac
		ON  Dea.location = Vac.location
		AND Dea.date = Vac.date
	WHERE Dea.continent IS NOT NULL and Vac.new_vaccinations IS NOT NULL