
SELECT *

FROM PortfolioProject..CovidDeaths

WHERE continent is not null

order by 3,4



----Looking at total cases vs total deaths
SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS Death_percentage

FROM PortfolioProject..CovidDeaths

WHERE location like '%poland%'
	AND continent is not null
ORDER BY 1,2



----Looking at total cases vs population
SELECT location, date, population, total_cases, (total_cases/population)*100 AS percentage

FROM PortfolioProject..CovidDeaths

WHERE location like '%poland%'

ORDER BY 1,2



----Country with highest infection rates compare to population
SELECT Location, Population, MAX(total_cases) AS HIC , MAX((total_cases/population))*100 AS percent_population_infected

FROM PortfolioProject..CovidDeaths

GROUP BY Location, Population

ORDER BY percent_population_infected DESC




----Country with highest Death counts compare to population
SELECT Location, Max(Cast(total_deaths AS INT)) AS TTDC

FROM PortfolioProject..CovidDeaths

WHERE continent is not null

GROUP BY Location

ORDER BY TTDC DESC




----BREAK DOWN BY CONTINENT
SELECT location, Max(Cast(total_deaths AS INT)) AS TTDC

FROM PortfolioProject..CovidDeaths

WHERE continent is null

GROUP BY location

ORDER BY TTDC DESC


---SHOWING conitent with highest death count per population

SELECT continent, Max(Cast(total_deaths AS INT)) AS TTDC

FROM PortfolioProject..CovidDeaths

WHERE continent is not null

GROUP BY continent

ORDER BY TTDC DESC



---GLOBAL NUMBERS

SELECT Sum(new_cases) AS total_cases, Sum(Cast(new_deaths AS INT)) AS total_deaths, Sum(Cast(new_deaths AS INT))/Sum(new_cases)*100 AS Death_percentage

FROM PortfolioProject..CovidDeaths

WHERE continent is not null

ORDER BY 1,2


----Looking at total population vs vaccinations


----CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS 
(
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
			,Sum(Convert(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated

	FROM PortfolioProject..CovidDeaths AS dea
	Join PortfolioProject..CovidVaccinations AS vac
		ON dea.location = vac.location
		AND dea.date = vac.date

	WHERE dea.continent IS NOT NULL

	--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS Rolling_percentage
FROM PopvsVac



----Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	TRY_CAST(dea.population AS numeric) AS population,
    TRY_CAST(vac.new_vaccinations AS numeric) AS new_vaccinations,
	Sum(TRY_CAST(vac.new_vaccinations as numeric)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated

FROM PortfolioProject..CovidDeaths AS dea
Join PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date

--WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100 AS Rolling_percentage

FROM #PercentPopulationVaccinated




----Create View to store data for later

CREATE VIEW PercentPopulationVaccinated AS 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,Sum(Convert(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated

FROM PortfolioProject..CovidDeaths AS dea
Join PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date

WHERE dea.continent IS NOT NULL




SELECT *
FROM PercentPopulationVaccinated
