Select *
From PortfoilioProject..CovidDeaths
--Where continent is not NULL
--Where location like '%states%'
--Where continent like '%north%'
Order by 3,4



--Select *
--From PortfoilioProject..CovidVaccinations
--Order by 3,4

--Select the Data that we are going to be using

Select location, date, total_cases, new_cases,total_deaths, population
From PortfoilioProject..CovidDeaths
Order by 1,2


-- Looking at Total Cases vs Total Deaths

-- Shows likelihood of dying of covid in Kenya
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfoilioProject..CovidDeaths
where location = 'Kenya'
Order by 1,2


--Shows likelihood of dying of covid in USA
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfoilioProject..CovidDeaths
where location like '%states%'
Order by 1,2

-- Looking at Total Cases vs Population

-- Shows percentage of Population infected by Covid in Kenya
Select location, date, total_cases, population, (total_cases/population)*100 AS CovidInfectionPercentage
From PortfoilioProject..CovidDeaths
where location = 'Kenya'
Order by 1,2

-- Shows percentage of Population infected by Covid in USA
Select location, date, population, total_cases, (total_cases/population)*100 AS CovidInfectionPercentage
From PortfoilioProject..CovidDeaths
--where location like '%states%'
Order by 1,2


--Country with highest infection rates compared to Population

Select location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS CovidInfectionPercentage
From PortfoilioProject..CovidDeaths
Group by location,population
Order by CovidInfectionPercentage desc


-- Showing countries with Highest Death Count per Population
Select location, population, MAX(cast(total_deaths as int)) AS HighestDeathCount, MAX((total_deaths/population))*100 AS 
HighestDeathPercentagePerPopulation
From PortfoilioProject..CovidDeaths
Where continent is not NULL
Group by location,population
Order by HighestDeathPercentagePerPopulation desc


--BREAKING DOWN BY CONTINENT

--Showing countries with Highest Death Count per Population

Select continent, location, Max(cast(total_deaths as int)) As TotalDeathCount
From PortfoilioProject..CovidDeaths
--Where continent is not NULL
--Where location like '%states%'
Where continent like '%north%'
Group by continent, location
Order by TotalDeathCount desc


Select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfoilioProject..CovidDeaths
Where continent is not NULL
Group by continent
Order by TotalDeathCount desc


--GLOBAL NUMBERS

--Looking at percentage death per day on global scale

Select date, sum(new_cases) as TotalNewCases, Sum(cast(new_deaths as int)) as TotalDeaths, Sum(cast
(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfoilioProject..CovidDeaths
Where continent is not null
Group by date
order by 1,2


--Global percentage death of infected people

Select sum(new_cases) as TotalNewCases, Sum(cast(new_deaths as int)) as TotalDeaths, Sum(cast
(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfoilioProject..CovidDeaths
Where continent is not null
--Group by date
order by 1,2

--Looking at Total Population vs Vaccinations
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
From PortfoilioProject..CovidDeaths dea
Join PortfoilioProject..CovidVaccinations vac
	on Dea.location = Vac.location
	and Dea.date = Vac.date
Where Dea.continent is not null
Order by 2,3


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(bigint, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.date) as RollingPeopleVaccinated
From PortfoilioProject..CovidDeaths dea
Join PortfoilioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(bigint, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.date) as RollingPeopleVaccinated, (SUM(Convert(bigint, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.date)/population)*100 As percentageofPopulationVaccinated
From PortfoilioProject..CovidDeaths dea
Join PortfoilioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

--By USE of CTE we have

With PopvsVac (Continent, location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(bigint, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.date) as RollingPeopleVaccinated
From PortfoilioProject..CovidDeaths dea
Join PortfoilioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100 AS PercentVaccinated
From PopvsVac


--TEMP TABLE

Drop Table  if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(bigint, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.date) as RollingPeopleVaccinated
From PortfoilioProject..CovidDeaths dea
Join PortfoilioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100 AS PercentVaccinated
From #PercentPopulationVaccinated
Order by 2,3


--Creating View to store Data for visualization


Create View
PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(bigint, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.date) as RollingPeopleVaccinated
From PortfoilioProject..CovidDeaths dea
Join PortfoilioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *
From PercentPopulationVaccinated