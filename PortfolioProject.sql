--All data about covid deaths

Select *
from coviddeaths
where continent is not NULL
order by 3,4;

--All data about covid vaccinations

Select *
from covidvaccinations
order by 3,4;

Select Location, ddate , total_cases,new_cases,total_deaths, population
from coviddeaths
where continent is not NULL
order by 1,2;

--Looking at total cases vs total deaths
--Shows likelihood of dying if you contract covid in India

Select Location, ddate , total_cases, total_deaths, trunc((total_deaths/total_cases)*100,2) Death_Percentage
from coviddeaths
where location='India'
and continent is not NULL
order by 1,2;

--Looking at Total cases vs Population
--Shows what percentage of population got covid

Select Location, ddate , population, total_cases, (total_cases/population)*100 PercentPopulationInfected
from coviddeaths
where location='India'
order by 1,2;


--Looking at countries with highest infection rate compared with population

Select Location , population, max(total_cases) HighestInfectionCount, trunc(max((total_cases/population)*100),5) PercentPopulationInfected
from coviddeaths
group by Location, population
order by PercentPopulationInfected desc;

--Showing countries highest death count per population

Select Location , max(total_deaths) TotalDeathCount
from coviddeaths
where continent is not NULL
group by Location
order by TotalDeathCount desc nulls last;

--Let's break things down by continent

/*Select location , max(total_deaths) TotalDeathCount
from coviddeaths
where continent is  NULL
group by location
order by TotalDeathCount desc nulls last;*/

--Showing continents with the highest death count per population

Select continent , max(cast(total_deaths as number)) TotalDeathCount
from coviddeaths
where continent is not NULL
group by continent
order by TotalDeathCount desc nulls last;

--Global Numbers

Select  sum(new_cases) Total_Cases, sum(new_deaths) Total_Deaths,(sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
from coviddeaths
where continent is not NULL
--group by ddate
order by 1,2;


--Joining tables

--Looking at total population vs vaccinations

select dea.continent, dea.location, dea.ddate, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (PARTITION by dea.location order by dea.location, dea.ddate) RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.location= vac.location
and dea.ddate=vac.ddate
where dea.continent is not null
order by 2,3

--use cte

with popvsVac (continent,location,ddate,population,new_vaccinations,RollingPeopleVaccinated)
as
(select dea.continent, dea.location, dea.ddate, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (PARTITION by dea.location order by dea.location, dea.ddate) RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.location= vac.location
and dea.ddate=vac.ddate
where dea.continent is not null
--order by 2,3
)
select continent,location,ddate,population,new_vaccinations,RollingPeopleVaccinated,(RollingPeopleVaccinated/population)*100 as PerCentRolling
from
popvsVac

--Temp Table

    BEGIN
      EXECUTE IMMEDIATE 'DROP TABLE PercentPopulationVaccinated';
  EXCEPTION
      WHEN OTHERS THEN NULL;
  END;
create global temporary table PercentPopulationVaccinated
( continent varchar2(40),
location varchar2(40),
ddate date,
population number(38),
New_vaccinations number(38),
RollingPeopleVaccinated number(38)
)
on commit preserve rows;

Insert into PercentPopulationVaccinated
select dea.continent, dea.location, dea.ddate, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (PARTITION by dea.location order by dea.location, dea.ddate) RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.location= vac.location
and dea.ddate=vac.ddate
where dea.continent is not null;

select continent,location,ddate,population,new_vaccinations,RollingPeopleVaccinated,(RollingPeopleVaccinated/population)*100 as PerCentRolling
from PercentPopulationVaccinated;

--creating view to store data for later visualizations

create view PercentPopulationVaccination as
select dea.continent, dea.location, dea.ddate, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (PARTITION by dea.location order by dea.location, dea.ddate) RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.location= vac.location
and dea.ddate=vac.ddate
where dea.continent is not null;

select * from
PercentPopulationVaccination;
