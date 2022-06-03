SELECT *
FROM PortfolioProject..CovidDeaths
Where continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Select Data that we are going to be used

SELECT Location,date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking at Total cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in your country

SELECT Location,date, total_cases,  total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%France%'
ORDER BY 1,2


--Looking at Total Cases vs Population
--Shows what percentage of the population got Covid
SELECT Location,date, total_cases, Population,(total_cases/Population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
Where location like '%France%'
ORDER BY 1,2


--Looking at countries with Highest Infection Rate compared to Population


SELECT Location, Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/Population)*100) as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location like '%France%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC


--Showing the countries with the Highest Death Count per Population

SELECT Location, Max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%France%'
Where continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC



--Let's break things down by continent

SELECT Location, Max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%France%'
Where continent is null
GROUP BY Location
ORDER BY TotalDeathCount DESC

--Showing the continent with the Highest Death Count

SELECT continent, Max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%France%'
Where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Global numbers


SELECT date, SUM(new_cases) as total_cases ,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(cast(new_cases as int))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--Where location like '%France%'
Where continent is not null
Group By date
ORDER BY 1,2


--Looking at Total Population vs Vaccinations


SELECT dea.continent, dea.location, dea.date, dea.population
, vac.new_vaccinations,SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
ORDER BY 2,3


--USE CTE

With PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population
, vac.new_vaccinations,SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--TEMP TABLE


Create table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population
, vac.new_vaccinations,SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--ORDER BY 2,3
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Add the "Drop Table" in case you want to make any alterations. For example here I commented out "where continent is not Null".

DROP Table if exists #PercentPopulationVaccinated 
Create table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population
, vac.new_vaccinations,SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--ORDER BY 2,3
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



--Creating view to store data for later visualisations


Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population
, vac.new_vaccinations,SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--ORDER BY 2,3

Select *
FROM PercentPopulationVaccinated
