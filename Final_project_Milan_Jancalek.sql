/*Projekt SQL Milan Jančálek*/

/*Podtabulka z czechia_payroll jako materiál pro vytvoření primární tabulky*/

CREATE OR REPLACE TABLE t_milan_jancalek_payroll (	
	SELECT
		industry_branch_code,
		calculation_code,
		value_type_code,
		payroll_year,
		ROUND(AVG(value), 0) AS avg_values_per_year
	FROM czechia_payroll AS cp
	WHERE value_type_code = 5958 AND calculation_code = 200
	GROUP BY 
		industry_branch_code,
		payroll_year 
);

/*Podtabulka z czechia_price jako materiál pro vytvoření primární tabulky*/

CREATE OR REPLACE TABLE t_milan_jancalek_price( 
	SELECT 
		category_code,
		YEAR(date_from) AS year_of_entry,
		ROUND(AVG(value),2) AS yearly_avg_value
	FROM czechia_price cp
	WHERE region_code IS NULL
	GROUP BY year_of_entry,
		category_code
	ORDER BY
		year_of_entry,
		category_code
);


/*Vytvoření primární tabulky*/

CREATE OR REPLACE TABLE t_milan_jancalek_project_SQL_primary_final(
	SELECT 
		mjpr.category_code AS price_cat,
		mjpr.year_of_entry AS price_year,
		mjpr.yearly_avg_value AS price_year_avg,
		mjpa.industry_branch_code,
		mjpa.calculation_code,
		mjpa.payroll_year,
		mjpa.avg_values_per_year AS payroll_year_avg
	FROM t_milan_jancalek_price mjpr
	LEFT JOIN t_milan_jancalek_payroll mjpa  
		ON mjpr.year_of_entry = mjpa.payroll_year
);

/*Sekundární tabulka*/

CREATE OR REPLACE TABLE t_milan_jancalek_project_SQL_secondary_final
SELECT *
FROM economies;


/*Otázka 1- Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?*/

WITH v_difference_payroll AS(
	SELECT
		tmj.industry_branch_code,
		tmj.calculation_code,
		tmj.payroll_year AS current_year,
		tmj.payroll_year_avg AS values_current_year,
		tmj2.payroll_year AS previous_year,
		tmj2.payroll_year_avg AS values_previous_year,
		tmj.payroll_year_avg - tmj2.payroll_year_avg AS difference_from_previous_year
	FROM t_milan_jancalek_project_SQL_primary_final AS tmj
	JOIN t_milan_jancalek_project_SQL_primary_final AS tmj2 
		ON tmj.payroll_year = tmj2.payroll_year + 1 
		AND tmj.calculation_code = tmj2.calculation_code 
		AND tmj.industry_branch_code = tmj2.industry_branch_code 
	GROUP BY 
		tmj. industry_branch_code,
		tmj.payroll_year 
)
SELECT 
	cpib.name,
	v_diff.current_year AS year_of_decreased_payroll,
	v_diff.difference_from_previous_year
FROM v_difference_payroll AS v_diff
JOIN czechia_payroll_industry_branch cpib 
	ON v_diff.industry_branch_code = cpib.code 
WHERE difference_from_previous_year <= 0
GROUP BY 
	v_diff.industry_branch_code,
	v_diff.current_year;

/*Otázka 2 - Kolik je možné si koupit litrů mléka a kilogramů chleba 
 * za první a poslední srovnatelné období v dostupných datech cen a mezd?*/

WITH v_avg_sum AS(
	SELECT 
		price_cat,
		price_year,
		price_year_avg,
		payroll_year_avg,
		(payroll_year_avg*12) AS payroll_year_sum
	FROM t_milan_jancalek_project_SQL_primary_final tmjpspf 
	WHERE price_cat IN (111301, 114201) AND price_year IN (2006, 2018)
	GROUP BY
		price_cat,
		price_year 
	ORDER BY 
		price_year,
		price_cat 
)
SELECT
	p_cat.name,
	v_avg_sum.price_year,
	SUM(v_avg_sum.price_year_avg) AS avg_bread_milk,
	v_avg_sum.payroll_year_avg AS monthly_payroll_avg,
	v_avg_sum.payroll_year_sum,
	ROUND(v_avg_sum.payroll_year_avg / SUM(v_avg_sum.price_year_avg), 0) AS potential_number_of_items_per_year,
	ROUND(v_avg_sum.payroll_year_sum / SUM(v_avg_sum.price_year_avg), 0) AS potential_number_of_items_per_year
FROM v_avg_sum AS v_avg_sum
JOIN czechia_price_category AS p_cat
	ON p_cat.code = v_avg_sum.price_cat
GROUP BY 
	v_avg_sum.price_cat,
	v_avg_sum.price_year;


/*Otázka 3
 * Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)? 
 * Vyhodnocení podle kategorie jídla a jednotlivých let.*/

WITH perc_growth AS(	
	WITH v_yearly_avg AS(	
		SELECT 
			price_cat,
			price_year,
			price_year_avg  
		FROM t_milan_jancalek_project_SQL_primary_final tmj
		GROUP BY price_cat,
			price_year 
	)		
	SELECT 
		yavg.price_cat,
		yavg.price_year,
		yavg.price_year_avg,
		yavg2.price_year AS previous_year,
		yavg2.price_cat AS cat_code_prev,
		yavg2.price_year_avg AS val_prev_year,
		yavg.price_year_avg-yavg2.price_year_avg AS difference,
		ROUND(((yavg.price_year_avg-yavg2.price_year_avg)/yavg2.price_year_avg)*100,2) AS perc_growth_of_price
	FROM v_yearly_avg AS yavg
	JOIN v_yearly_avg AS yavg2
		ON yavg.price_year = yavg2.price_year +1	
		AND yavg.price_cat = yavg2.price_cat
	GROUP BY price_cat,
		price_year 	
)		
SELECT 
	cpc.name,
	pg.price_year,
	pg.perc_growth_of_price
FROM perc_growth AS pg
JOIN czechia_price_category AS cpc
	ON cpc.code = pg.price_cat
ORDER BY perc_growth_of_price;

/*Otázka 3 - pokračování
 * Vyhodnocení podle kategorií jídla za celé období 
 * (vycházím z počátečních hodnot v roku 2006 konečných hodnot v roku 2018)*/

WITH result_value AS(	
	WITH perc_growth AS(	
		WITH v_yearly_avg AS(	
			SELECT 
				price_cat,
				price_year,
				price_year_avg
			FROM t_milan_jancalek_project_SQL_primary_final tmj
			WHERE price_year IN (2006, 2018)
			GROUP BY price_cat,
				price_year
		)		
		SELECT 
			yavg.price_cat,
			yavg.price_year,
			yavg.price_year_avg,
			yavg2.price_year AS previous_year,
			yavg2.price_cat AS cat_code_prev,
			yavg2.price_year_avg AS val_prev_year,
			yavg.price_year_avg-yavg2.price_year_avg AS difference,
			ROUND((((yavg.price_year_avg-yavg2.price_year_avg)/yavg2.price_year_avg)*100/12),2) AS yearly_perc_growth_of_price_for_the_whole_period
		FROM v_yearly_avg AS yavg
		JOIN v_yearly_avg AS yavg2
			ON yavg.price_year = yavg2.price_year +12	
			AND yavg.price_cat = yavg2.price_cat
		GROUP BY price_cat,
			price_year 	
	)		
	SELECT *
	FROM perc_growth
	ORDER BY yearly_perc_growth_of_price_for_the_whole_period
)
SELECT 
	price.name,
	result_value.yearly_perc_growth_of_price_for_the_whole_period
FROM result_value
JOIN czechia_price_category AS price
	ON result_value.price_cat = price.code 
ORDER BY yearly_perc_growth_of_price_for_the_whole_period;


/*Otázka 4
 * Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?*/

/*"mezitabulka" s hodnotami mezd a jejich % změny z roku na rok*/

CREATE OR REPLACE TABLE increment_payroll (
	WITH avg_payroll_sum AS(
		SELECT *
		FROM t_milan_jancalek_project_SQL_primary_final tmjpspf 
		WHERE industry_branch_code IS NULL
		GROUP BY payroll_year 
	)
	SELECT
		avgp.industry_branch_code,
		avgp.payroll_year AS payroll_current_year,
		avgp.payroll_year_avg AS values_current_year,
		avgp2.payroll_year AS previous_year,
		avgp2.payroll_year_avg AS values_previous_year,
		avgp.payroll_year_avg - avgp2.payroll_year_avg AS difference_from_previous_year,
		ROUND(((avgp.payroll_year_avg - avgp2.payroll_year_avg)/avgp2.payroll_year_avg)*100,2) AS yearly_perc_growth_of_payroll
	FROM avg_payroll_sum AS avgp
	JOIN avg_payroll_sum AS avgp2
		ON avgp.payroll_year = avgp2.payroll_year + 1 
		AND avgp.calculation_code = avgp2.calculation_code 
	GROUP BY 
		avgp.calculation_code,
		avgp.payroll_year,
		avgp.payroll_year_avg,
		avgp2.payroll_year,
		avgp2.payroll_year_avg
	ORDER BY yearly_perc_growth_of_payroll DESC
);

/*vlastní výsledek otázky 4*/

WITH food_cat_view AS(
	WITH perc_growth AS(	
		WITH v_yearly_avg AS(	
			SELECT 
				tmj.price_cat,
				tmj.price_year,
				tmj.price_year_avg,
				price.name
			FROM t_milan_jancalek_project_SQL_primary_final tmj
			JOIN czechia_price_category AS price
				ON tmj.price_cat = price.code
			GROUP BY price_cat,
				price_year 
		)		
		SELECT 
			yavg.price_cat,
			yavg.name,
			yavg.price_year,
			yavg.price_year_avg,
			yavg2.price_year AS previous_year,
			yavg2.price_cat AS cat_code_prev,
			yavg2.price_year_avg AS val_prev_year,
			yavg.price_year_avg-yavg2.price_year_avg AS difference,
			ROUND(((yavg.price_year_avg-yavg2.price_year_avg)/yavg2.price_year_avg)*100,2) AS perc_growth_of_price
		FROM v_yearly_avg AS yavg
		JOIN v_yearly_avg AS yavg2
			ON yavg.price_year = yavg2.price_year +1	
			AND yavg.price_cat = yavg2.price_cat
		GROUP BY price_cat,
			price_year 	
	)		
	SELECT 
		price_year AS food_cat_year,
		ROUND(AVG(perc_growth_of_price),2) AS yearly_avg_food_cat
	FROM perc_growth
	GROUP BY
		price_year 
	ORDER BY 
		yearly_avg_food_cat DESC
)
SELECT 
	fv.food_cat_year,
	fv.yearly_avg_food_cat,
	pt.payroll_current_year,
	pt.yearly_perc_growth_of_payroll,
	fv.yearly_avg_food_cat - pt.yearly_perc_growth_of_payroll AS diff_food_payroll_increment
FROM food_cat_view AS fv
JOIN increment_payroll AS pt 
	ON fv.food_cat_year = pt.payroll_current_year
ORDER BY diff_food_payroll_increment;

/*Otázka 5
 * Má výška HDP vliv na změny ve mzdách a cenách potravin? 
 * Neboli, pokud HDP vzroste výrazněji v jednom roce, 
 * projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?*/

/*Nezbytná podtabulka s hodnotami % změn HDP pro Českou republiku*/

CREATE OR REPLACE TABLE hdp_milan
	WITH cz_info AS(	
		SELECT *
		FROM t_milan_jancalek_project_SQL_secondary_final tmjpssf 
		WHERE country = 'Czech Republic' AND GDP IS NOT NULL
	)
	SELECT 
		tmjs.year AS hdp_current_year,
		tmjs.GDP AS current_hdp,
		tmjs2.year AS previous_year,
		tmjs2.GDP AS previous_hdp,
		ROUND(tmjs.GDP - tmjs2.GDP,2) AS diff_hdp,
		ROUND((tmjs.GDP - tmjs2.GDP)/tmjs2.GDP * 100,2) AS proc_growth_hdp
	FROM cz_info tmjs 
	JOIN cz_info tmjs2
		ON tmjs.year = tmjs2.year + 1;
	
/*Vlastní odpověď na otázku 5*/

WITH food_payroll_perc_growth AS(
	WITH food_cat_view AS(
		WITH perc_growth AS(	
			WITH v_yearly_avg AS(	
				SELECT 
					tmj.price_cat,
					tmj.price_year,
					tmj.price_year_avg,
					price.name
				FROM t_milan_jancalek_project_SQL_primary_final tmj
				JOIN czechia_price_category AS price
					ON tmj.price_cat = price.code
				GROUP BY price_cat,
					price_year 
			)		
			SELECT 
				yavg.price_cat,
				yavg.name,
				yavg.price_year,
				yavg.price_year_avg,
				yavg2.price_year AS previous_year,
				yavg2.price_cat AS cat_code_prev,
				yavg2.price_year_avg AS val_prev_year,
				yavg.price_year_avg-yavg2.price_year_avg AS difference,
				ROUND(((yavg.price_year_avg-yavg2.price_year_avg)/yavg2.price_year_avg)*100,2) AS perc_growth_of_price
			FROM v_yearly_avg AS yavg
			JOIN v_yearly_avg AS yavg2
				ON yavg.price_year = yavg2.price_year +1	
				AND yavg.price_cat = yavg2.price_cat
			GROUP BY price_cat,
				price_year 	
		)		
		SELECT 
			price_year AS food_cat_year,
			ROUND(AVG(perc_growth_of_price),2) AS yearly_avg_food_cat
		FROM perc_growth
		GROUP BY
			price_year 
		ORDER BY 
			yearly_avg_food_cat DESC
	)
	SELECT 
		fv.food_cat_year,
		fv.yearly_avg_food_cat,
		pt.payroll_current_year,
		pt.yearly_perc_growth_of_payroll
	FROM food_cat_view AS fv
	JOIN increment_payroll AS pt 
		ON fv.food_cat_year = pt.payroll_current_year
)	
SELECT 
	fpp.*,
	hdp.hdp_current_year,
	hdp.proc_growth_hdp
FROM food_payroll_perc_growth AS fpp
JOIN hdp_milan AS hdp
	ON fpp.food_cat_year = hdp.hdp_current_year 
