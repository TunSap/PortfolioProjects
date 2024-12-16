-- Exploratory Data Analysis
SELECT *
FROM layoffs_staging2;
-- Highest amount of laid off employees, highest percentage of laid off employees
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;
-- Companies who laid off 100% of their employees
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off=1
ORDER BY funds_raised_millions DESC;
-- Sum of laid off employees by company
SELECT company, sum(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;
-- Date Range for dataset
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;
-- Sum of the most laid off by industries
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;
-- Sum of the most laid off employees by countries
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;
-- Sum of the most laid off employees by year
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;
-- Sum of the most laid off employees by stage
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;
-- Rolling total of layoffs
SELECT company, SUM(total_)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;
-- Rolling total of laid off employees by Year-Month
WITH Rolling_Total AS
(SELECT SUBSTRING(`date`,1,7) AS `Year-Month`, SUM(total_laid_off) AS Total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `Year-Month`
ORDER BY 1 ASC
)
SELECT `Year-Month`, total_off
,SUM(Total_Off) OVER(ORDER BY `Year-Month`) AS rolling_total
FROM Rolling_Total;

-- Top 5 ranking sum of laid off employees by company per year
WITH Company_Year (Company, Years, Total_Laid_Off) AS
(SELECT company, YEAR(`date`) as Year, sum(total_laid_off)
FROM layoffs_staging2
GROUP BY company, Year
), Company_Year_Rank AS(
SELECT *, 
DENSE_RANK() OVER(PARTITION BY Years ORDER BY Total_Laid_Off DESC) AS Ranking
FROM Company_Year
WHERE Years IS NOT NULL
)
SELECT *
FROM Company_Year_RANK
WHERE Ranking <=5
;







