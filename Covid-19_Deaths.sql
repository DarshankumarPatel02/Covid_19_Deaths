--select data that we are going to be using--

select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
order by 1,2

--looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country--
SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    CAST(total_deaths AS float) / total_cases * 100 AS DeathPercentage
FROM 
    CovidDeaths
WHERE location='Asia' and continent is not null
ORDER BY 
    location, date;

--total cases vs population
--shows % of population got covid
SELECT 
    location,
    date,
   	population,
	total_cases,
    CAST(total_deaths AS float) / total_cases * 100 AS PercentPopulationInfected
FROM 
    CovidDeaths
WHERE location='Asia' and continent is not null
ORDER BY 
    location, date;

--highest infection rate
SELECT 
    location,
   	population,
	max(total_cases) as HighestInfectionCount,
    max(CAST(total_deaths AS float) / total_cases * 100) AS PercentPopulationInfected
FROM 
    CovidDeaths
where continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected desc;

-- showing highest deathcount in countries
SELECT 
    location,
	max(cast(total_deaths as int)) as TotalDeaths
FROM 
    CovidDeaths
where continent is not null
GROUP BY location
ORDER BY TotalDeaths desc;

--break things down by continent
SELECT 
    continent,
	max(cast(total_deaths as int)) as TotalDeaths
FROM 
    CovidDeaths
where continent is not null
GROUP BY continent
ORDER BY TotalDeaths desc;

--GLobal numbers--
SELECT 
	SUM(new_cases) as TotalCases,
	SUM(new_deaths) as TotalDeaths,
	SUM(new_deaths)/SUM(new_cases)*100 as DeathPErcentage
FROM 
    CovidDeaths
where continent is not null and new_cases!=0
order by 1,2;

--Looking at Total Population vs vaccinations

select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations
, SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (PARTITION BY cd.location,cd.date) as RollingPeopleVaccinated
from 
CovidDeaths cd join 
CovidVaccinations cv on cd.location=cv.location
and cd.date=cv.date
where cd.continent is not null 
order by 2,3 ;


-- USE CTE
WITH PopvsVac (Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as
(
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations
, SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (PARTITION BY cd.location,cd.date) as RollingPeopleVaccinated
from 
CovidDeaths cd join 
CovidVaccinations cv on cd.location=cv.location
and cd.date=cv.date
where cd.continent is not null 
--order by 2,3 
)
select *,(RollingPeopleVaccinated/Population)*100 from PopvsVac


--Temp Tables
DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric)

INSERT INTO #PercentPopulationVaccinated
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations
, SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (PARTITION BY cd.location,cd.date) as RollingPeopleVaccinated
from 
CovidDeaths cd join 
CovidVaccinations cv on cd.location=cv.location
and cd.date=cv.date
--where cd.continent is not null 
--order by 2,3 
select *,(RollingPeopleVaccinated/Population)*100 from #PercentPopulationVaccinated




--country and continent has the highest death count
SELECT continent, location, MAX(total_deaths) as hightestDeathCount
FROM CovidDeaths
WHERE CONTINENT IS NOT NULL 
Group by continent, location
order by hightestDeathCount desc

-- global cases for each day
SELECT date, SUM(new_cases) as total_newcases, sum(new_deaths) as total_newdeaths, 
    case
        WHEN SUM(new_cases) <> 0 THEN SUM(new_deaths)*1.0/SUM(new_cases)*100 
        ELSE NULL
    END AS death_rate
FROM coviddeaths
WHERE Continent is not NULL
GROUP BY DATE
Order by date 

--death ratio
SELECT 
    continent,
    location,
    SUM(new_cases) AS Total_cases,
    SUM(new_deaths) AS Total_Deaths,
    CASE 
        WHEN SUM(new_cases) = 0 THEN 'N/A' 
        ELSE CONCAT(ROUND(SUM(new_deaths) / SUM(new_cases) * 100, 2), '%')
    END AS death_ratio
FROM 
    coviddeaths 
WHERE 
    continent != ' '
GROUP BY 
    continent,
    location 
ORDER BY 
    death_ratio DESC;


--Countries which have highest death percentage per population
select location ,population, sum(new_deaths) as total_deaths ,
concat(round(sum(new_deaths)/population*100,2),'%') as Death_percent
from coviddeaths 
where continent!=''
group by location , population 
order by Death_percent desc;


-- tableau queries

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union','High income','Upper middle income','lower middle income','low income', 'International')
Group by location
order by TotalDeathCount desc


Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc













