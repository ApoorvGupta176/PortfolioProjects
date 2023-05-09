 use PortfolioProject
 
 select*
from CovidDeaths
where continent is not null
order by 3,4


--select*
--from CovidVaccinations 
--order by 3,4

-- select data that we are going to be using

select location, date , total_cases,new_cases , total_deaths ,population 
from CovidDeaths 
where continent is not null

order by 1,2

--  looking at total cases vs total deaths 
-- shows likelihood of dying from covid if you contract the disease in your country 

select location, date ,total_cases, total_deaths , ( total_deaths /total_cases)*100 as Death_Percentage 
from CovidDeaths
where location like 'india'
and continent is not null

order by 1,2

-- looking at total cases vs the population
-- shows what % of population has got covid 

select location, date ,total_cases, population  , ( total_cases /population)*100 as Infection_Percentage 
from CovidDeaths
where location like 'india' and continent is not null

order by 1,2

-- looking at countries with higher infection rate compared to population 

 
 select location, MAX(total_cases) as Highest_Infection_count, population  ,MAX(( total_cases /population))*100 as Infection_Percentage 
from CovidDeaths
 -- where location like 'india'
group by location,population 
order by Infection_Percentage desc 

-- showing countries with highest death count per population 


 select location, MAX(cast(total_deaths as int)) as total_death_count
from CovidDeaths
-- where location like 'india'
where continent is not null
group by location 
order by total_death_count desc 

-- LET'S BREAK THINGS DWON BY CONTINENT 

-- showing the continet with the highest death count per population 

select continent, MAX(cast(total_deaths as int)) as total_death_count
from CovidDeaths
-- where location like 'india'
where continent is not null
group by continent
order by total_death_count desc 

-- all the above queries can be broken dwon by continents

-- GOBAL NUMBERS 

select date ,SUM(new_cases) as total_cases 	, SUM (cast (new_deaths as int) ) as total_deaths ,  SUM( cast( new_deaths as int))/ SUM(new_cases) *100 as death_percentage_globally 
from CovidDeaths
-- where location like 'india'
where  continent is not null
group by date 
order by 1,2


select SUM(new_cases) as total_cases 	, SUM (cast (new_deaths as int) ) as total_deaths ,  SUM( cast( new_deaths as int))/ SUM(new_cases) *100 as death_percentage_globally 
from CovidDeaths
-- where location like 'india'
where  continent is not null
order by 1,2


-- looking at total population vs vaccinations

select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date ) as rolling_people_vaccinated
-- ,(rolling_people_vaccinated /population)*100         -- here we get an error , we cannot use the name of the column we just created, so to correct that we use CTE
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date= vac.date 
where dea.continent is not null 
order by 2,3



-- use CTE 
with populationVsVaccinations (continent , location, date , population , new_vaccinations , rolling_people_vaccinated) 
as 
-- if the no of columns in CTE is diff then the no of columns in the table then it will give an error 
(
select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date ) as rolling_people_vaccinated
-- ,(rolling_people_vaccinated /population)                         
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date= vac.date 
where dea.continent is not null 
 -- order by 2,3
)  

select * , (rolling_people_vaccinated/ population)*100 
from populationVsVaccinations

 -- temp table 

 Drop table if exists  PercentPopulationVaccinated 

 Create table PercentPopulationVaccinated 

 (continent nvarchar(255) , 
 location nvarchar(255) ,
 date datetime , 
 population numeric ,
 new_vaccinations numeric ,
 rolling_people_vaccinated numeric 
 )
 insert into PercentPopulationVaccinated 

 select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations, 

sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date ) as rolling_people_vaccinated
-- ,(rolling_people_vaccinated /population) 

from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date= vac.date 

-- where dea.continent is not null 
 -- order by 2,3

 select * , (rolling_people_vaccinated/ population)*100 as rolling_people_vaccinated_percentage
from PercentPopulationVaccinated 
 

 -- creating view to store data for visualization later 

 go 


 create view  PPV  as

  select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations, 

sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date ) as rolling_people_vaccinated
-- ,(rolling_people_vaccinated /population) 

from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date= vac.date 
where dea.continent is not null 
-- order by 2,3


select * from  PPV 
