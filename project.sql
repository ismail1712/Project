select *
from portofolioproject..coviddeaths
order by 3,4

--select *
--from portofolioproject..covidvaccination
--order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from portofolioproject..coviddeaths
order by 1,2

--totalcases vs total deaths death percentage
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercent
from portofolioproject..coviddeaths
where location='India'
order by 1,2


--total cases vs population
select location,date,population,total_cases,(total_cases/population)*100 as casepercent
from portofolioproject..coviddeaths
where location='India'
order by 1,2


--infection rate vs population
select location,population,max(total_cases) as infectionrate,max(total_cases/population)*100 as casepercent
from portofolioproject..coviddeaths
group by location, population
order by casepercent desc


--death count 
select location,max(cast(total_deaths as int)) as deathcount --cast for varcahr to int conv
from portofolioproject..coviddeaths
where continent is not null
group by location
order by deathcount desc


select distinct continent
from portofolioproject..coviddeaths
 
 --global numbers

 select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as totaldeaths,( sum(cast(new_deaths as int)) /sum(new_cases))*100 as deathpercent
from portofolioproject..coviddeaths
--where location='India'
order by 1,2


--total vaccination vs population

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from portofolioproject..coviddeaths dea
join portofolioproject..covidvaccination vac
on dea.location=vac.location and dea.date=vac.date
where vac.continent is not null
order by 1,2

--use cte

with PopvsVac (Continent,Location,Date,Population,New_vaccination,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from portofolioproject..coviddeaths dea
join portofolioproject..covidvaccination vac
on dea.location=vac.location and dea.date=vac.date
where vac.continent is not null
)
select *,(RollingPeopleVaccinated/Population)*100
from PopvsVac

--temp table


drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(Continent nvarchar(255),
Location nvarchar(255),
DAte datetime,
Population numeric,
New_vaccinated numeric,
rollingpeoplevaccinated numeric
)

Insert into #percentpopulationvaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from portofolioproject..coviddeaths dea
join portofolioproject..covidvaccination vac
on dea.location=vac.location and dea.date=vac.date
where vac.continent is not null

select *,(RollingPeopleVaccinated/Population)*100 as percentvaccinated
from #percentpopulationvaccinated


--create view

create view percentpopulationvaccinated as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from portofolioproject..coviddeaths dea
join portofolioproject..covidvaccination vac
on dea.location=vac.location and dea.date=vac.date
where vac.continent is not null