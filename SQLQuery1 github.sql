SELECT * FROM [Covid deaths]
ORDER BY 3,4

Select *
From [Portfolio Project]..[Covid Vaccinations]
order by 3,4

--Select Data to Use

Select location,date,total_cases,new_cases,total_deaths,population
From [Covid deaths]	
Order by 1,2

--Total cases Vs Total deaths
Select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From [Covid deaths]	
Order by 1,2

--Death Percentage in Netherlands
Select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From [Covid deaths]	
Where location like '%ether%'
Order by 1,2

--Death Percentage in Africa
Select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From [Covid deaths]	
Where continent='africa'
Order by 1,2

--Looking at Total Cases Vs Population 
Select location,date,total_cases,population, (total_cases/population)*100 AS PopulationInfected 
From [Covid deaths]	
Where location like '%ether%'
Order by 1,2

--Looking at countries with highest infection 
Select location,population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 AS PopulationInfected
From [Covid deaths]	
--Where location like '%ether%'
Group By population,location
Order by PopulationInfected DESC

--Continent with highest death rate per population

Select continent, MAX(cast(total_deaths as INT)) as TotalDeathCount
From [Covid deaths]	
--Where location like '%ether%'
Where continent is not null	
Group By continent
Order by TotalDeathCount DESC

Select location, MAX(cast(total_deaths as INT)) as TotalDeathCount
From [Covid deaths]	
--Where location like '%ether%'
Where continent is null	
Group By location
Order by TotalDeathCount DESC

--Continents with Highest Death per population
Select continent, MAX(cast(total_deaths as INT)) as TotalDeathCount
From [Covid deaths]	
--Where location like '%ether%'
Where continent is not null	
Group By continent
Order by TotalDeathCount DESC

--GLOBAL NUMBERS


Select date, SUM(cast(total_deaths as INT)) as TotalDeathCount, sum(new_cases)	as Total_cases, SUM(cast(total_deaths as INT))/sum(new_cases)*100 as DeathPercentage  
From [Covid deaths]	
--Where location like '%ether%'
Where continent is not null	
Group By date
Order by 1,2

--Total Cases overall accross entire world

Select sum(new_cases)as Total_cases, SUM(cast(new_deaths as bigint)) as TotalDeathCount, SUM(cast(new_deaths as INT))/sum(new_cases)*100 as DeathPercentage  
From [Covid deaths]	
--Where location like '%ether%'
Where continent is not null	
--Group By date
Order by 1,2

SELECT *
FROM [Covid Vaccinations]

Select *
From [Covid deaths] dea
Join [Covid Vaccinations] vac
	on dea.location= vac.location
	and dea.date=vac.date

	--Total Population vs Vaccinations 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From [Covid deaths] dea
Join [Covid Vaccinations] vac
	on dea.location= vac.location
	and dea.date=vac.date
Where dea.continent is not null
Order by 1,2,3

--Vaccination Percentage by Country
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, (VAC.new_vaccinations/dea.population) * 100 AS VaccinationPercentage
From [Covid deaths] dea
Join [Covid Vaccinations] vac
	on dea.location= vac.location
	and dea.date=vac.date
Where dea.continent is not null
Group by dea.location,dea.continent,dea.date, dea.population, vac.new_vaccinations
Order by 1,2,3

--Rolling Count by Country
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingCount
From [Covid deaths] dea
Join [Covid Vaccinations] vac
	on dea.location= vac.location
	and dea.date=vac.date
Where dea.continent is not null
Order by 2,3

--CTE
With PopvsVac (Continent,Location,Date,Population, New_Vaccinations,RollingCount)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingCount
From [Covid deaths] dea
Join [Covid Vaccinations] vac
	on dea.location= vac.location
	and dea.date=vac.date
Where dea.continent is not null
--Order by 2,3
)

Select *, (RollingCount/Population) * 100
From PopvsVac


--TEMPORARY TABLE
DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingCount Numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingCount
From [Covid deaths] dea
Join [Covid Vaccinations] vac
	on dea.location= vac.location
	and dea.date=vac.date
Where dea.continent is not null
Order by 2,3

Select *, (RollingCount/Population)* 100
FROM #PercentPopulationVaccinated


--Creating View for Visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingCount
From [Covid deaths] dea
Join [Covid Vaccinations] vac
	on dea.location= vac.location
	and dea.date=vac.date
Where dea.continent is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated