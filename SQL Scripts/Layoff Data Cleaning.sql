-- Data Cleaning

-- Full Precleaned Table
SELECT *
FROM  world_layoffs.layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or blank values
-- 4. Remove Any Columns or Rows

-- Create a new table for data cleaning
CREATE TABLE layoffs_staging
LIKE layoffs;
-- Return all columns from layoffs table
SELECT *
FROM  layoffs_staging;
-- Copy data from main table to staging table
INSERT layoffs_staging
SELECT * 
FROM layoffs;
-- Search for duplicate rows within data
SELECT *, 
row_number() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off,`date`, stage, country, funds_raised_millions ) as row_num
FROM layoffs_staging;
-- Create CTE to find duplicate rows
WITH duplicate_cte as
(SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
FROM layoffs_staging
)
SELECT * 
FROM duplicate_cte
WHERE row_num >1;
-- Look at example of a duplicate company
SELECT *
FROM  layoffs_staging
WHERE company = 'Casper';
-- Create another staging table, and add row_num as a column
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
-- View query to check if all columns transferred over
SELECT *
FROM layoffs_staging2;
-- Insert data from first staging table to the new table
INSERT INTO layoffs_staging2
SELECT *,ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
FROM layoffs_staging; 
-- Delete duplicate rows greater than 1 row number
DELETE 
FROM layoffs_staging2
WHERE row_num>1;
-- View new table after deletion
SELECT * 
FROM layoffs_staging2
WHERE row_num>1;

# Standardizing data
-- Look at whitespace in company text
SELECT company, TRIM(company)
FROM layoffs_staging2
-- Update white space for company names
UPDATE layoffs_staging2
SET company = TRIM(company);
-- Check for similar industry categorization & blank/nulls
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;
-- Check industry column categorization
SELECT DISTINCT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';
-- Update industry crypto variations to crypto
UPDATE layoffs_staging2
SET industry= 'Crypto' 
WHERE industry LIKE 'Crypto%';
-- Check location
SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1;
-- Check country
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;
-- Update United States variations to United States
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;
-- Update United States variations to United States
UPDATE layoffs_staging2
SET country= TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';
-- Change date  to datetype
SELECT `date`,STR_TO_DATE(`date`,'%m/%d/%Y')
FROM layoffs_staging2;
-- Format date (text) to date (date)
UPDATE layoffs_staging2
SET `date`= STR_TO_DATE(`date`,'%m/%d/%Y');
-- Change column type to date type.
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;
-- Check null & blank data for industry values
SELECT DISTINCT *
FROM layoffs_staging2
WHERE industry = ''
OR industry IS NULL
;
-- Check an example company
SELECT DISTINCT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%';
-- Update blank values in industry to nulls
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';
-- View
SELECT t1.industry,
t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry is NULL)
AND t2. industry is NOT NULL;
-- Update industry that are blank with results to rows with industries
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry is NULL)
AND t2. industry is NOT NULL;
-- REMOVE null rows for total_laid_off, percentage_laid_off
DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
-- REMOVE row_num column
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- View Cleaned Table
SELECT *
FROM layoffs_staging2