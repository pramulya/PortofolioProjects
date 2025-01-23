

select *
from PortofolioRaja..CovidDeaths
Where continent is not null
order by 3,4

--select *
--from PortofolioRaja..CovidVaccinations
--order by 3,4

-- Select the Data that will be use

Select Location, date, total_cases, new_cases, total_deaths, population
From PortofolioRaja..CovidDeaths
Where continent is not null
order by 1,2

-- Review Total Cases vs Total Deaths
-- Search based on the country you want to search
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortofolioRaja..CovidDeaths
Where location like '%state%'
and continent is not null
order by 1,2

-- Review Total Cases vs Population
-- Show percentage of population that get covid

Select Location, date, total_cases, population, (total_cases/population)*100 as CasesPercentage
From PortofolioRaja..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2

--Highest location that get infected by percentage

Select Location, date, MAX(total_cases) as HighestInfectedCount, population, MAX((total_cases/population))*100 as PopulationInfectedPercentage
From PortofolioRaja..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location, Population, date
order by PopulationInfectedPercentage desc

-- Location with Highest Death count based on Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortofolioRaja..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc

-- Break things down by the continent

-- Continent with Highest Death count based on Population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortofolioRaja..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Number

-- Based on date

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
	SUM(cast(new_deaths as int)) /SUM(New_cases)*100 as DeathPercentage--, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortofolioRaja..CovidDeaths
where continent is not null
Group by date
order by 1, 2

-- Total Cases

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
	SUM(cast(new_deaths as int)) /SUM(New_cases)*100 as DeathPercentage--, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortofolioRaja..CovidDeaths
where continent is not null
order by 1, 2


--Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date)
From PortofolioRaja..CovidDeaths dea
join PortofolioRaja..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3


--Use CTE

With PopvsVac(Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated) as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortofolioRaja..CovidDeaths dea
join PortofolioRaja..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select* , (RollingPeopleVaccinated/Population)*100
From PopvsVac
order by 2, 3

-- TEMP Table

Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date Datetime,
Population Numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date)
From PortofolioRaja..CovidDeaths dea
join PortofolioRaja..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating view for later Data Visualizations

CREATE VIEW dbo.PercentPopulationVaccinated AS
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM PortofolioRaja..CovidDeaths dea
JOIN PortofolioRaja..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;


Select*
From PercentPopulationVaccinated