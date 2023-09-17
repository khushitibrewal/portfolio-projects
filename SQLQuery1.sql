select*
from portfolioproject..covid_death
order by 3,4

--select*
--from portfolioproject..covid_vaccination
--order by 3,4

--select data that we are going to use
select location,date,total_cases,new_cases,total_deaths,population  --here we used names of column instead of column number bcoz we wanted to keep the heading name of each column in new table otherwise we had to giive new names to each columns
from portfolioproject..covid_death
order by 1,2

--looking at total cases vs total deaths


ALTER table portfolioproject.dbo.covid_death
ALTER column total_deaths float; --here we changed the data type of total cases and total deaths to float as we need % value. if it was changed to int datatype the value fpr % was showing only 0 or null

--likelihoof of dying if you contract covid in your country

select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as deathpercentage 
from portfolioproject..covid_death
order by 1,2

--to look for a particular country

select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as deathpercentage 
from portfolioproject..covid_death
where location like 'india' 
order by 1,2

-- total cases vs population

select location,date,total_cases,population, (total_cases/population)*100 as casepercentage 
from portfolioproject..covid_death
where location like 'india' 
order by 1,2

--looking at countries with highest infection rate compaired to population

select location,population,max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as infectionRate
from portfolioproject..covid_death
group by population,location
order by infectionRate DESC


--countries with highest death count

select location,population,max(total_deaths) as HighestdeathCount, max((total_deaths/population))*100 as deathRate
from portfolioproject..covid_death
group by population,location
order by HighestdeathCount DESC

--in the above case if the total case was in nvarchar type, we could use cast function to change it into integer

select location,population,max(cast(total_deaths as int)) as HighestdeathCount, max((total_deaths/population))*100 as deathRate
from portfolioproject..covid_death

group by population,location
order by HighestdeathCount DESC

--note in the data we have counties and continents together . do following to get only countries data

select *
from portfolioproject..covid_death
where continent is not null


select location,population,max(cast(total_deaths as int)) as HighestdeathCount, max((total_deaths/population))*100 as deathRate
from portfolioproject..covid_death
where continent is not null
group by population,location
order by HighestdeathCount DESC


--comparing data continent wise


select location,max(total_deaths ) as HighestdeathCount
from portfolioproject..covid_death
where continent is null
group by location
order by HighestdeathCount DESC

--or(compare the difference)

select continent,max(total_deaths ) as HighestdeathCount
from portfolioproject..covid_death
where continent is not null
group by continent
order by HighestdeathCount DESC

--grouping data by date

select date,sum(new_cases) as total_cases ,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathPercentage
from portfolioproject..covid_death
where continent is not null 
group by date
order by 1,2



select sum(new_cases) as total_cases ,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathPercentage
from portfolioproject..covid_death
where continent is not null 
--group by date
order by 1,2



--now we join two tables

ALTER table portfolioproject..covid_vaccination
ALTER column new_vaccinations bigint;

select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(new_vaccinations) as vaccinationCount over(partition  by dea.location)    --here we converted new_vaccination into bigint type as the total number was exceeding the int limit
from portfolioproject..covid_death as dea
join portfolioproject..covid_vaccination as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3


--int the above case we summed the vaccination according to location but if we need to find the number of vaccination on particular date we do as follow..note here we get cummulative sum of number of vaccination

select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(new_vaccinations)  over(partition  by dea.location order  by dea.location,dea.date)    as vaccinationCount
from portfolioproject..covid_death as dea
join portfolioproject..covid_vaccination as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null 
order by 2,3


--use CTE   here we create new table with some data from previous data. be careful that the number of column in new table should be same as the no. of columns in output we got from previous operatioon
--it didn't give ecpected result
--try later

--with popVsVac(continent,location,date,population,new_vaccination,vaccinationCount)
--as
--(
--select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
--sum(new_vaccinations)  over(partition  by dea.location order  by dea.location,dea.date)    as vaccinationCount
--from portfolioproject..covid_death as dea
--join portfolioproject..covid_vaccination as vac
--on dea.location=vac.location
--and dea.date=vac.date
--where dea.continent is not null 
----order by 2,3
--)

--select (vaccinationCount/population)*100
--from popVsVac




--temp table

create table percentagePopulationVaccination
(
continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccination numeric,
vaccinationCount numeric
)
insert into
(
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(new_vaccinations)  over(partition  by dea.location order  by dea.location,dea.date)    as vaccinationCount
from portfolioproject..covid_death as dea
join portfolioproject..covid_vaccination as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null 
--order by 2,3
)
select (vaccinationCount/population)*100
from percentagePopulationVaccination

