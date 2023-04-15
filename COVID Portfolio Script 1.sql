Select* 
From CovidDeaths$
Where continent is not null 
order  by 3, 4

-- Select data we are going to be using 

select location, date , total_cases, new_cases, total_deaths, population
from CovidDeaths$
order by 1, 2

-- Looking at Total cases Vs Total Deaths 
-- This shows the likelihood of dying if you contract covid in your country depending on the date

select location, date , total_cases, total_deaths, (total_deaths/ total_cases)*100 as DeathPercentage
from CovidDeaths$
where location like 'united kingdom' 
order by 1, 2

-- Looking at Total cases Vs Population
-- Shows what percentage of a counties population got covid 

select location, date , total_cases, Population, (total_cases/ Population )*100 as InfectionPercentage
from CovidDeaths$
-- where location like 'united kingdom' 
order by 1, 2

-- Looking at countries with the highest infection rates compared to population 

select location ,Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/ Population ))*100 as PercentPopulationInfected
from CovidDeaths$
Group by population, location
order by PercentPopulationInfected desc

-- Showing countries with the highest Death Count per Population 

select location , Max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
Where continent is not null
Group by location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENTS 

select location , Max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
Where continent is  null
Group by location
order by TotalDeathCount desc


-- Showing continents with the highest Death count per population
select continent , Max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global Numbers

select location, date , total_cases, total_deaths, (total_deaths/ total_cases)*100 as DeathPercentage
from CovidDeaths$
Where continent is not null
order by 1, 2


select date , Sum(new_cases) as total_cases, Sum(Cast(new_deaths as int)) as Total_deaths, Sum(Cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths$
Where continent is not null
group by date
order by 1, 2

-- To look at Total cases, deaths and Death percentage of the globe 
select Sum(new_cases) as total_cases, Sum(Cast(new_deaths as int)) as Total_deaths, Sum(Cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths$
Where continent is not null
order by 1, 2

-- Looking at Total population vs Vaccinations 

Select*
from CovidDeaths$ as dea 
Join CovidVaccinations$ as vac
on dea.location = vac.location
and dea.date = vac.date

-
Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations, dea.total_vaccinations,
Sum(Cast(vac.new_vaccinations as int)) over (partition by dea.Location)
from CovidDeaths$ as dea 
Join CovidVaccinations$ as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3 

-- looking at rolling vaccinations 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(Convert(int, vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.date) as RollingVaccinations
from CovidDeaths$ as dea 
Join CovidVaccinations$ as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3 

-- USING a CTE to show the % of the population vaccinated over time
With PopvsVac (continent, Location, Date, Population, New_vaccinations, RollingVaccinations)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Convert(int, vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.date) as RollingVaccinations
from CovidDeaths$ as dea 
Join CovidVaccinations$ as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
Select*, (RollingVaccinations/Population)*100
from PopvsVac


-- Temp Table
Drop Table if exists #PercentPopulationVaccinated  
Create Table #PercentPopulationVaccinated
(continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccination numeric,
RollingVaccinations numeric)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Convert(int, vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.date) as RollingVaccinations
from CovidDeaths$ as dea 
Join CovidVaccinations$ as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

Select*, (RollingVaccinations/Population)*100
from #PercentPopulationVaccinated


-- Creating View to Store data for later visualisations 

Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(Convert(int, vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.date) as RollingVaccinations
from CovidDeaths$ as dea 
Join CovidVaccinations$ as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null


select* 
from PercentPopulationVaccinated
