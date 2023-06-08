

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project 1]..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2


--Total Cases vs Total Deaths
--Percentage of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (CONVERT(float,total_deaths)/ CONVERT(float,total_cases))*100 AS death_percentage
FROM [Portfolio Project 1]..CovidDeaths$
WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
ORDER BY 1,2


--Total Cases vs Population
--Percentage of Population that contracted covid
SELECT location, date, total_cases,population, (CONVERT(float,total_cases)/ CONVERT(float,population))*100 AS infected_population_percentage
FROM [Portfolio Project 1]..CovidDeaths$
WHERE location = 'United States'
WHERE continent IS NOT NULL
ORDER BY 1,2

--Countries with Highest Infection Rate compared to population
SELECT location, Max(total_cases) AS highest_infection_count, population, MAX((CONVERT(float,total_cases)/ CONVERT(float,population)))*100 AS 
infected_population_percentage
FROM [Portfolio Project 1]..CovidDeaths$
--WHERE location = 'United States'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY infected_population_percentage DESC


--Countries With Highest Death Count Per Population
SELECT location, MAX(CAST(total_deaths as int)) as total_death_count
FROM [Portfolio Project 1]..CovidDeaths$
--WHERE location = 'United States'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY total_death_count DESC


--Continent Breakdwon with Highest Death Count
SELECT continent, MAX(CAST(total_deaths as int)) as total_death_count
FROM [Portfolio Project 1]..CovidDeaths$
--WHERE location = 'United States'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC


--Global Numbers
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int)) / SUM(new_cases)*100 as death_percentage
FROM [Portfolio Project 1]..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2


--Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population,vax.new_vaccinations,
SUM(CAST(vax.new_vaccinations as bigint)) over (partition by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated_count
FROM [Portfolio Project 1]..CovidDeaths$ dea
JOIN [Portfolio Project 1]..covid_vaxs$ vax
	ON dea.location = vax.location
	 AND TRY_CONVERT(date, dea.date) = TRY_CONVERT(date, vax.date)
WHERE dea.continent IS NOT NULL
ORDER BY 2,3



--CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS (
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(CONVERT(decimal, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
    FROM [Portfolio Project 1]..CovidDeaths$ dea
    JOIN [Portfolio Project 1]..covid_vaxs$ vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *, (CAST(RollingPeopleVaccinated AS decimal) / Population) * 100 AS VaccinationPercentage
FROM PopvsVac;



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project 1]..CovidDeaths$ dea
Join [Portfolio Project 1]..covid_vaxs$ vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (CAST(RollingPeopleVaccinated AS decimal) / Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [Portfolio Project 1]..CovidDeaths$ dea
Join [Portfolio Project 1]..covid_vaxs$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
