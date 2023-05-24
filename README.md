# SQL-project

## Tabulky
Nejdříve jsem se seznámil s daty v tabulkách czechia_payroll a czechia_price. Porozumět hodnotám v tabulkách včetně tabulek doplňujících již zmíněné tabulky. 

Pro vytvoření tabulky t_milan_jancalek_project_SQL_primary_final jsem se rozhodl nejdříve vytvořit „podtabulky“ t_milan_jancalek_payroll a t_milan_jancalek_price. 

Do t_milan_jancalek_payroll jsem vložil pouze relevatní informace, tudíž se zde nacházejí pouze mzdy (value_type_code = 5958) a rozhodl jsem se to dělat z hodnot přepočtených (calculation_code = 200). V případě fyzických hodnot to zahrnuje všechny fyzické pracovníky a to včetně těch co pracují na částečný úvazek. Tudíž v tomto případě hodnoty průměrných mezd jsou tím ovlivněné a nepodávají výsledky normálních průměrných mezd plnočasových pracovníků. Přepočtené hodnoty tyto hodnoty upravují tak, že dostáváme hodnoty mezd všech pracovníků přepočtených na hodnoty plnočasových pracovníků.

t_milan_jancalek_price opět obsahuje pouze relevantní informace. Jídelní kategorii, rok a průměrnou roční hodnotu. Vzhledem k tomu, že již v czechia_price se nacházejí průměrné hodnoty pro celou Českou republiku pro každou kategorii tak jsme vybíral pouze ty hodnoty (region_code IS NULL).

Příslušné tabulky a grafy jsou v průvodní zprávě ve formátu pdf.

## Otázka 1
Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

Nejdříve jsem si pro jednotlivá odvětví vytvořil další sloupec s hodnotami předchozího roku. Následně jsem je vzájemně odečetl. Následně jsou zobrazeny pouze záporné hodnoty, tedy hodnoty mezd, kde průměrné hodnoty klesají v daných letech a odvětvích (viz Tabulka 1.- výsledky jsou zobrazeny jako obrázek tabulky v Excelu).

## Otázka 2
Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

Ze základní tabulky jsem si zjistil, že první a poslední rok srovnatelného období je 2006 a 2018. Poté jsem si vytvořil průměry, jak cen mléka a chleba, mezd. Následně jsem podělil tyto hodnoty (mzdy/cena jídla) a to jak za měsíční mzdy, tak za roční mzdy (12* průměrná mzda). Výsledky jsem následně v excelu zformátoval jako tabulku 2. Nakonec jsem zde přidal i procentuální nárůst potenciálního množství jednotlivého jídla respektive. V případě chleba jsme mohli koupit o 9% více v roce 2018 oproti roku 2006. U mléka je tahle hodnota dokonce 20%.

## Otázka 3
Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

Otázku jsem pochopil jako procentuální nárůst a nikoliv percentuální. Dále jsem si otázku vyložil dvěmi způsoby. Porovnával jsem kategoria jídla během jednotlivých let. Další způsob jsem vyhodnotil podle počátečních hodnot v roce 2006 a konečných hodnot v roce 2018.

U prvního případu jsem nejdříve vytvořil průměry pro jednotlivé jídelní kategorie. Následně jsem vytvořil sloupce s hodnotami předchozích let. Ty jsem od sebe odečetl a spočítal procentuální růst či pokles. Pak jsem přidal názvy kategorií a seřadil je vzestupně. Mínusové hodnoty uvádějí pokles ceny dané kategorie v procentech oproti předchozímu roku (viz tabulka 3). Nejvíce zlevnila rajská jablka o 30,28% v roce 2007 (oproti roku 2006).

V druhém případě jsem si nejdříve připravil roční hodnoty z roku 2006 a 2018. Následně jsem hodnoty dal na jeden řádek pro každou kategorii jídla a odečetl, zprůměroval a seřadil od nejmenšího po největší. Nakonec jsem přiřadil názvy kategorií. Za pozorované období slevnili pouze 2 kategorie potravin. Nejvíce slevnil cukr krystalový s 2,29% a poté rajská jablka s 1,92%. Zbytek kategorií zdražil (viz tabulka 4).

## Otázka 4
Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

U ročních průměrných hodnot kategorií jídla jsem vypočítal průměrnou změnu v procentech oproti předchozímu roku. Dále jsem vyextrahoval pouze relevatní hodnoty (rok a roční % změnu). Stejné průměrné hodnoty jsem vytvořil pro mzdy a uložil je do tabulky increment_payroll. Následně obě hodnoty (jak kategorie jídla tak mzdy) jsem vzájemně porovnal (odečet % kategorií jídel od mezd). Ani v případě slevnění (kategorií jídle vůči mzdám) či zdražení v žádném případě nedošlo k překročení hranice 10% stanovené v otázce (viz tabulka 5).

## Otázka 5
Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?

Pro tuto odpověď jsem nejdříve potřeboval výpočet % změny HDP z roku na rok. Uložil jsem to jako tabulku hdp_milan. Hodnoty jsou pouze pro Českou republiku tam, kde HDP nebylo nulové.

Pro vlastní výsledek jsem opět použil % změny kategorií jídel a mezd. Poté jsem také připojil hodnoty z předpřipravené tabulky hdp_milan. Výsledné hodnoty jsem za pomoci excelu vložil, jak do tabulky 6, tak do liniového grafu (viz obrázek 1).

Z výsledného grafu lze vyčíst, že změny v HDP se blízce promítly ve změnách cen jídla (obvláště je to znatelné v roce 2009 kdy se snížilo HDP a zároveň se slevnily ceny potravin). Změny mezd obecně reagovali pomaleji na změny HDP nicméně také následovaly trend (rostly či klesaly v závislosti na HDP). Obrázek 2 zobrazuje změny HDP – změna jídla či mzdy ve stejném roce. Obrázek 3 dále zobrazuje změny HDP – změny jídla a mezd v následujícím roce (oproti HDP). Kde se hodnoty pohybují kolem 0 tak se jedná o blízké následování změny HDP. Naopak kde se jedná o větší vzdálenost od hodnot nuly tak reagovaly různě. 
