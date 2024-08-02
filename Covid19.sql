/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/





SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4


--Selecting relevant data

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Total cases vs Total deaths
-- Shows death rate for infected for each country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location like '%india%'
ORDER BY 1,2



-- Total cases vs Population
-- percentage of population who got covid

SELECT Location, date, Population, total_cases, (total_cases/Population)*100 as InfectionPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location like '%india%'
ORDER BY 1,2

--Countries with Highest Infection rate vs Population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%india%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc



--Showing Countries with Highest Death Count per Population
-- need to cast tatal deaths because of a problem with the data type otherwise doesnt work

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%india%'
Where continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc


--Break down by continent - using location works because of formatting of the data

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%india%'
Where continent is null
GROUP BY Location
ORDER BY TotalDeathCount desc



--Global death rate

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
 SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%india%'
Where continent is null
--GROUP BY Location
ORDER BY 1, 2

--Total pop vs vaccinations -> join tables
--Rolling Count of Peopple being vaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int, vac.new_vaccinations)) OVER( Partition by dea.Location Order by dea.Location, dea.Date) RollingPeopleVaccinations

FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.Location = vac.Location
and dea.date = vac.date
Where dea.continent is not null
ORDER BY 2,3



--CTE because cant use rollingpeoplevaccinations in further calculations because I just made it

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVac) 
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int, vac.new_vaccinations)) 
OVER(Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVac
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.Location = vac.Location
and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVac/Population)*100
FROM PopvsVac


--Temp Tables

DROP table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaaccinations numeric,
RollingPeopleVac numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int, vac.new_vaccinations)) 
OVER(Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVac
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.Location = vac.Location
and dea.date = vac.date
--Where dea.continent is not null

Select *, (RollingPeopleVac/Population)*100
FROM #PercentPopulationVaccinated



-- Creatnig a view for later visualisations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int, vac.new_vaccinations)) 
OVER(Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVac
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.Location = vac.Location
and dea.date = vac.date
Where dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated
