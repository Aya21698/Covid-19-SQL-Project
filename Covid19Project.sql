SELECT *
FROM [PortfolioProject].[dbo].[CovidDeaths]
WHERE continent is NOT NULL

--SELECT *
--FROM [PortfolioProject].[dbo].[CovidVaccinations]

SELECT Location,date,total_cases,new_cases,total_deaths,population
FROM [PortfolioProject].[dbo].[CovidDeaths]

-- Total_deaths VS Total_cases
-- Likelihhod of dying from Covid-19 in Morocco
SELECT Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as PercentageOfDeath
FROM [PortfolioProject].[dbo].[CovidDeaths]
WHERE location = 'Morocco' and continent is not NULL

-- Total_cases VS Population
SELECT Location,date,population,total_cases,(total_cases/population)*100 as CovidPercentage
FROM [PortfolioProject].[dbo].[CovidDeaths]
WHERE location = 'Morocco'


-- Highest Infection Rate for all countries compared to all Population
SELECT Location,population,MAX(total_cases),MAX((total_cases/population))*100 as PercentPopulationInfected
FROM [PortfolioProject].[dbo].[CovidDeaths]
--WHERE location = 'Morocco'
GROUP BY location,population
Order by PercentPopulationInfected DESC


-- Countries with Highest Death Counts Per Population
SELECT Location,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [PortfolioProject].[dbo].[CovidDeaths]
--WHERE location = 'Morocco' 
WHERE continent is NOT NULL
GROUP BY location
Order by TotalDeathCount DESC

-- Countries with Highest Death Counts by continent
-- when continent is NULL the location is the continent 
SELECT Location,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [PortfolioProject].[dbo].[CovidDeaths]
--WHERE location = 'Morocco' 
WHERE continent is NULL
GROUP BY location
Order by TotalDeathCount DESC


-- Global Numbers 
SELECT date,SUM(total_cases)
FROM [PortfolioProject].[dbo].[CovidDeaths]
--WHERE location = 'Morocco'
WHERE continent is NOT NULL
GROUP BY date 
ORDER BY date


--Global Numbers 
SELECT date,SUM(new_cases) TotalCases , SUM(cast(new_deaths as int)) TotalDeaths ,(SUM(cast(new_deaths as int)) /SUM(new_cases))*100 
DeathPercentage
FROM [PortfolioProject].[dbo].[CovidDeaths]
--WHERE location = 'Morocco'
WHERE continent is NOT NULL
GROUP BY date 
ORDER BY date ,2


--Total Population VS vaccination
SELECT *
FROM PortfolioProject..CovidDeaths death
JOIN
PortfolioProject..CovidVaccinations vacc
ON    death.location=vacc.location
       and death.date= vacc.date


--Total Population VS vaccination
SELECT death.continent, death.location,death.date, population, vacc.new_vaccinations, 
SUM(cast(vacc.new_vaccinations as int)) OVER (Partition by death.location ORDER BY death.location,death.date ) 
AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths death
JOIN
PortfolioProject..CovidVaccinations vacc
ON    death.location=vacc.location
       and death.date= vacc.date
WHERE death.continent IS NOT NULL
ORDER BY 2,3


-- Use CTE 
With Popvsvacc  
as
(
SELECT death.continent, death.location,death.date, population, vacc.new_vaccinations, 
SUM(cast(vacc.new_vaccinations as int)) OVER (Partition by death.location ORDER BY death.location,death.date ) 
AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths death
JOIN
PortfolioProject..CovidVaccinations vacc
ON    death.location=vacc.location
       and death.date= vacc.date
WHERE death.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM Popvsvacc
ORDER BY 2,3






--Temp TABLE 
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(250),
Location nvarchar(250),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated int
)
INSERT INTO #PercentPopulationVaccinated
SELECT death.continent, death.location,death.date, population, vacc.new_vaccinations, 
SUM(cast(vacc.new_vaccinations as int)) OVER (Partition by death.location ORDER BY death.location,death.date ) 
AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths death
JOIN
PortfolioProject..CovidVaccinations vacc
ON    death.location=vacc.location
       and death.date= vacc.date
--WHERE death.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated
ORDER BY 2,3


--Create a view 
CREATE VIEW PercentPopulationVaccinated as 
SELECT death.continent, death.location,death.date, population, vacc.new_vaccinations, 
SUM(cast(vacc.new_vaccinations as int)) OVER (Partition by death.location ORDER BY death.location,death.date ) 
AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths death
JOIN
PortfolioProject..CovidVaccinations vacc
ON    death.location=vacc.location
       and death.date= vacc.date
WHERE death.continent IS NOT NULL
--ORDER BY 2,3

SELECT*
FROM PercentPopulationVaccinated