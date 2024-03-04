--select *
--from PortfolioProject.dbo.CovidDeaths

select *
from PortfolioProject.dbo.CovidVaccinations
where continent is not null
order by 3,4



select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.dbo.CovidDeaths
order by 1,2



-- Looking at Total Cases vs Total Deaths
select Location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths in Canada
-- estimate of dying when you have covid in Canada
select Location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where location = 'Canada'
order by 1,2


-- Looking at Total Cases vs Total Deaths in US
-- estimate of dying when you have covid in US
select Location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- population percentage that got Covid 
select Location, date, total_cases,  total_deaths, population, (total_cases/population)*100 as CovidPopulation
from PortfolioProject.dbo.CovidDeaths
order by 1,2

-- Looking at Total Cases vs Population in Canada
-- population percentage that got Covid in Canada
select Location, date, total_cases,  total_deaths, population, (total_cases/population)*100 as CovidPopulation
from PortfolioProject.dbo.CovidDeaths
where location = 'Canada'
order by 1,2


-- Looking at Countries to highest infection rate compared to Population
select Location, population, max(total_cases)as HighestInfectionCount, max((total_cases/population))*100 as CovidPopulation
from PortfolioProject.dbo.CovidDeaths
--where location = 'Canada'
group by location, population
order by CovidPopulation desc

-- Showing Countries with Highest Death Count per Population
select Location, max(cast(total_deaths as int))as HighestDeathCount
from PortfolioProject.dbo.CovidDeaths
--where location = 'Canada'
where continent is not null
group by location
order by HighestDeathCount desc


-- BY CONTINENT

-- Showing continents with Highest Death Count per Population
select continent, max(cast(total_deaths as int))as HighestDeathCount
from PortfolioProject.dbo.CovidDeaths
--where location = 'Canada'
where continent is not null
group by continent
order by HighestDeathCount desc

select location, max(cast(total_deaths as int))as HighestDeathCount
from PortfolioProject.dbo.CovidDeaths
--where location = 'Canada'
where continent is null
group by location
order by HighestDeathCount desc


--- Global Numbers
-- per day
select  date, sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercent
from PortfolioProject.dbo.CovidDeaths
--where location = 'Canada' 
where continent is not null
group by date
order by 1,2

--total
select  sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercent
from PortfolioProject.dbo.CovidDeaths
--where location = 'Canada' 
where continent is not null
order by 1,2


-- total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject.dbo.CovidDeaths as dea
join PortfolioProject.dbo.CovidVaccinations as vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
order by 2,3


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (Partition by  dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths as dea
join PortfolioProject.dbo.CovidVaccinations as vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE
With PopvsVac (Continent, Location, Date, Population,New_Vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (Partition by  dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths as dea
join PortfolioProject.dbo.CovidVaccinations as vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


-- Temp table
Drop table if exists #PPV
create table #PPV
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PPV
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (Partition by  dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths as dea
join PortfolioProject.dbo.CovidVaccinations as vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
from #PPV

-- Create view of Death percentage of people with Covid in Canada

create view CanadaCovidDeathPercent as
select Location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where location = 'Canada'

select *
from CanadaCovidDeathPercent