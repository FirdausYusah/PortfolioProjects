select * 
from CovidDeath$
where continent is not null
order by 1,2


select location, date, total_cases, new_cases, total_deaths, population
from CovidDeath$
order by location, date

--Total Cases vs Total Deaths in Malaysia

select 
	location, date, total_cases, total_deaths, population,
	(total_deaths/total_cases)*100 as DeathPercentage
from 
	CovidDeath$
WHERE location = 'Malaysia'
order by 
	location, date

-- Total Cases vs Population
-- looking at infection rate in Malaysia
select 
	location, date, population, total_cases, 
	(total_cases/population)*100 as InfectionRate
from CovidDeath$
where location = 'Malaysia'
order by location, date

-- Countries with highest infection rate

select 
	location, population, MAX(total_cases) AS HighestInfectionCount, 
	MAX((total_cases/population))*100 as PercentPopulationInfected 
from CovidDeath$
--where location = 'Malaysia'
group by location, population
order by PercentPopulationInfected desc

--Country with highest Death Count per Population

select 
	location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
from CovidDeath$
where continent is not null --to exclude continent data
group by location
order by TotalDeathCount desc

--breakdown by continent

select 
	location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
from CovidDeath$
where continent is null --to exclude country data
group by location
order by TotalDeathCount desc

--continent with highest death count per population

select continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
from CovidDeath$
where continent is not null --to exclude continent data
group by continent
order by TotalDeathCount desc

--Global Number

select 
	sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_death,
	(sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from 
	CovidDeath$
where continent is not null
--group by date
order by total_cases, total_death

--working with 2 tables

select * 
from CovidVaccination$

--join table

select *
from CovidDeath$ as dea
join CovidVaccination$ as vac
	on dea.location = vac.location
	and dea.date = vac.date

--country total population vs total vaccination

select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as DailyTotalVaccination  --to add daily new_vaccination 
from CovidDeath$ as dea
join CovidVaccination$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use CTE

with PopvsVac (Continent, Location, Date, Population, New_vaccinations, DailyTotalVaccination)
as
(
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as DailyTotalVaccination  --to add daily new_vaccination 
from CovidDeath$ as dea
join CovidVaccination$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null --and vac.new_vaccinations is not null
--order by 2,3
)
select *, (DailyTotalVaccination/Population)*100 as DailyVaccinationPercent
from PopvsVac

-- creating view to store data for later visualization

Create View PercentPopulationVaccinated as --create virtual table
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as DailyTotalVaccination  --to add daily new_vaccination 
from CovidDeath$ as dea
join CovidVaccination$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated