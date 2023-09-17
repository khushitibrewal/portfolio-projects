
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
insert into percentagePopulationVaccination
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(new_vaccinations)  over(partition  by dea.location order  by dea.location,dea.date)    as vaccinationCount
from portfolioproject..covid_death as dea
join portfolioproject..covid_vaccination as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null 
--order by 2,3

select *, (vaccinationCount/population)*100 as vaccinationPercentage
from percentagePopulationVaccination


drop table if exists percentagePopulationVaccination
create table percentagePopulationVaccination
(
continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccination numeric,
vaccinationCount numeric
)
insert into percentagePopulationVaccination
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(new_vaccinations)  over(partition  by dea.location order  by dea.location,dea.date)    as vaccinationCount
from portfolioproject..covid_death as dea
join portfolioproject..covid_vaccination as vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null 
--order by 2,3

select *, (vaccinationCount/population)*100 as vaccinationPercentage
from percentagePopulationVaccination


--creating view to store data for later visualization

create view percentPopulationVaccinated 
as
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(new_vaccinations)  over(partition  by dea.location order  by dea.location,dea.date)    as vaccinationCount
from portfolioproject..covid_death as dea
join portfolioproject..covid_vaccination as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null 
--order by 2,3

select *
from  percentPopulationVaccinated 