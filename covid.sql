select *
 from coviddeaths
 where continent is not null
 order by 3,4 ;

select * from covidvaccinations;

#-- select data that we are going to be useing--#

select location, date, total_cases, new_cases, total_cases, population 
from coviddeaths 
where continent is not null
order by 1,2 ;

#-- looking at total cases vs total deaths --#

select location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as death_percentage 
from coviddeaths 
where location like '%egypt%'
and continent is not null 
order by date desc ;

#-- looking at total cases vs population --#
#-- shows what percentage of population got covid
select location, date, total_cases,  population, (total_cases/population)*100 as  percentage_population_infect
from coviddeaths 
where location like '%egypt%'
order by date desc ;

#-- looking at countries with highest infection rate compared to population --#

select location, population, max(total_cases) as Highst_infection_count, max((total_cases/population))*100 as percentage_population_infect 
from coviddeaths 
group by location, population
order by percentage_population_infect desc ;

#-- Global Numners--#
SELECT 
    SUM(new_cases) AS total_new_cases,
    SUM(CAST(NULLIF(total_deaths, '') AS UNSIGNED)) AS total_deaths_count,
    SUM(new_cases) * 100 AS death_percentage
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER by 1,2;

#-- Looking at total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinations
# (rolling_people_vaccinations/population)*100
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2,3;

# use CTE

WITH popvsvac (continent, location, date, population, new_vaccinations, rolling_people_vaccinations)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinations
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
#order by 2,3
)
select *, (rolling_people_vaccinations/population)*100 from popvsvac;


# TEMP TABLE
CREATE TABLE percentpopulationvaccinated (
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATETIME,
    population NUMERIC,
    new_vaccination NUMERIC,
    rolling_peoplevaccinated NUMERIC
);
INSERT INTO percentpopulationvaccinated
SELECT 
    dea.continent, 
    dea.location, 
    STR_TO_DATE(dea.date, '%d/%m/%Y') AS date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY STR_TO_DATE(dea.date, '%d/%m/%Y')) AS rolling_people_vaccinations
FROM 
    coviddeaths dea
JOIN 
    covidvaccinations vac
    ON dea.location = vac.location
    AND STR_TO_DATE(dea.date, '%d/%m/%Y') = STR_TO_DATE(vac.date, '%d/%m/%Y')
WHERE 
    dea.continent IS NOT NULL
    AND STR_TO_DATE(dea.date, '%d/%m/%Y') IS NOT NULL
    AND STR_TO_DATE(vac.date, '%d/%m/%Y') IS NOT NULL
    AND vac.new_vaccinations REGEXP '^-?[0-9]+(\.[0-9]+)?$';
    
    select * from percentpopulationvaccinated;
    
# create view to store data for later visualizations

create view percent_population_vaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinations
# (rolling_people_vaccinations/population)*100
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2,3;

select * from percent_population_vaccinated
    
    

