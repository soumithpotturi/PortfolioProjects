SELECT * FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Total cases vs Total Deaths
-- Chances of death if you're infected with covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%' and continent is not null
ORDER BY 1,2

-- Total cases vs Population
-- Shows the % of population that got covid

SELECT Location, date, population, total_cases, (total_cases/population) * 100 as PercentOfPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%' and continent is not null
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as PercentOfPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY population, location
ORDER BY PercentOfPopulationInfected desc


-- Showing countries with the highest death rate per population

SELECT Location, population, MAX(cast(total_deaths as int)) as HighestDeathCount, MAX((total_deaths/population)) * 100 as PercentOfDeath
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY population, location
ORDER BY HighestDeathCount desc

-- Death Rate by Continent

SELECT location, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is null
GROUP BY location
ORDER BY HighestDeathCount desc

SELECT continent, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY HighestDeathCount desc


-- GLOBAL Numbers per day

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) as DeathPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%states%' 
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- GLOBAL Numbers Total

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) as DeathPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%states%' 
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


-- JOINING TWO TABLES

SELECT * FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location and dea.date = vac.date

-- TOTAL POPULATION VS VACCINATION

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac 
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1,2,3

-- Trying something funky

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(cast(vac.new_vaccinations as int)) 
OVER (Partition by dea.location ORDER BY dea.location, dea. Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac 
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null and dea.location = 'Albania'
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/Population) * 100 
FROM PopvsVac


-- USING TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(cast(vac.new_vaccinations as numeric)) 
OVER (Partition by dea.location ORDER BY dea.location, dea. Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac 
ON dea.location = vac.location and dea.date = vac.date
--WHERE dea.continent is not null and dea.location = 'Albania'
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population) * 100 
FROM #PercentPopulationVaccinated


-- Creating a view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(cast(vac.new_vaccinations as numeric)) 
OVER (Partition by dea.location ORDER BY dea.location, dea. Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac 
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3