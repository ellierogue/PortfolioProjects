--Purpose: Covid19 Number Data

--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

Select *
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--From PortfolioProject.dbo.CovidVaccinations
--Order by 3,4

--Select Data to start with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Order by 1,2

--Comparing Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where location like '%states%' AND continent is NOT null
Order by 1,2

-- Comparing Total Cases vs Population
-- Shows the percentage of the population infected with Covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PositivePercentage
From PortfolioProject.dbo.CovidDeaths
Where location like '%states%' AND continent is NOT null
Order by 1,2

-- Look at Countries with Highest Infection Rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfection
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group by Location, Population
Order by PercentPopulationInfection desc

--Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group by Location
Order by TotalDeathCount desc



-- Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc


--Global Numbers

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where continent is NOT null
--Group By date
Order by 1,2

--Global Numbers By Date

Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where continent is NOT null
Group By date
Order by 1,2

--Total Population vs Vaccinations
-- Shows Percentage of Population that has received at least one Covid vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use Common Table Expression (CTE) and Partition By

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated
