select * from PortfolioProject..[Covid Deaths] order by 3,4
--select * from PortfolioProject..[Covid Vaccination] order by 3,4

select location,date,total_cases,new_cases,total_deaths,population from PortfolioProject..[Covid Deaths] order by 1,2

--total cases VS total deaths (probability of dying if infected by covid in Malaysia)
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from PortfolioProject..[Covid Deaths] 
where location like '%lay%'
order by 2 desc

--total cases VS population per country
select location, date, total_cases, population, (total_cases/population)*100 as InfectionRate
from PortfolioProject..[Covid Deaths]
where location like'%pore%'
order by 2 desc

--Compare percentage of population infected VS population per country
select location, population, max(total_cases) as HighestInfectionCount, (max(total_cases)/population)*100 as PercentPopulationInfected
from PortfolioProject..[Covid Deaths]
group by location, population
order by PercentPopulationInfected desc

--Show the country with the highest death count 
select location, max(total_deaths) as TotalDeathCount
from PortfolioProject..[Covid Deaths]
group by location
order by TotalDeathCount desc
--The above query won't work properly because the data type of that column needs to be converted to an integer
--Get rid of data which have region in the country column
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..[Covid Deaths]
where continent is not null or location like '%world%'
group by location
order by TotalDeathCount desc

--Compare total death count by continent
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..[Covid Deaths]
where continent is not null or location like '%world%'
group by continent
order by TotalDeathCount desc
--The NULL row refers to the entire globe

--New cases each day + death rate each day (across the globe)
select date, sum(new_cases) as NewCases, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..[Covid Deaths]
where continent is not null
group by date


--Total population VS vaccinations
--use CTE
with popVSvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..[Covid Deaths] dea join PortfolioProject..[Covid Vaccination] vac
on dea.date = vac.date and dea.location = vac.location
where dea.continent is not null and dea.location like '%laysia%'
)
select * , (RollingPeopleVaccinated/population)*100 as VaccinationRate from popVSvac
--the vaccination rate exceeds 100% is because the rolling number doesn't partition fisrt dose and second dose

--temporary table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..[Covid Deaths] dea join PortfolioProject..[Covid Vaccination] vac
on dea.date = vac.date and dea.location = vac.location
where dea.continent is not null and dea.location like '%laysia%'

select * , (RollingPeopleVaccinated/population)*100 as VaccinationRate from #PercentPopulationVaccinated
