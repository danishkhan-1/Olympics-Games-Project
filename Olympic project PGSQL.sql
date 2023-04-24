
SELECT * FROM olympics_history ;

SELECT * FROM olympics_history_noc_regions ;


-- How many olympics games have been held?
SELECT COUNT(DISTINCT games) AS total_num_of_olym_games 
FROM olympics_history ;


-- List down all Olympics games held so far.
SELECT DISTINCT games 
FROM olympics_history ;

-- Mention the total no of nations who participated in each olympics game?

SELECT 
	games ,
	COUNT(DISTINCT noc) AS num_of_nations
FROM olympics_history
GROUP BY 1 ;


-- Which nation has participated in all of the olympic games?
SELECT team , noc 
FROM olympics_history
GROUP BY 1 , 2 
HAVING COUNT(DISTINCT games) = (SELECT COUNT(DISTINCT games) AS total_num_of_olym_games 
FROM olympics_history ) ;


-- Which year saw the highest and lowest no of countries participating in olympics? 
WITH lowest_num_cte AS 
 (SELECT 
	games AS least_nation_year ,
	COUNT(DISTINCT noc) AS num_of_nations1
FROM olympics_history
GROUP BY 1 
ORDER BY 2
 LIMIT 1 ) ,
highest_num_cte AS 
( SELECT 
	games as most_nation_year ,
	COUNT(DISTINCT noc) AS num_of_nations2
FROM olympics_history
GROUP BY 1 
ORDER BY 2 DESC
LIMIT 1)

SELECT 
	CONCAT(least_nation_year,'-',num_of_nations1) ,
	CONCAT(most_nation_year,'-',num_of_nations2)
FROM lowest_num_cte , highest_num_cte ;



-- Which year saw the highest and lowest no of countries participating in olympics?

WITH CTE AS 
(SELECT 
	games ,
	COUNT(DISTINCT noc) AS num_of_nations
FROM olympics_history
GROUP BY 1 )

SELECT DISTINCT 
	FIRST_VALUE(games) OVER(ORDER BY num_of_nations ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING ) AS least_num ,
	LAST_VALUE(games) OVER(ORDER BY num_of_nations ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS most_num 
FROM CTE ;



-- Fetch the top 5 athletes who have won the most gold medals.

WITH Gold_medal_rank AS 
(
SELECT name , COUNT(medal) AS num_of_gold_medals
FROM olympics_history 
WHERE medal='Gold'
GROUP BY 1	
ORDER BY num_of_gold_medals DESC )

SELECT * 
FROM (
    SELECT 
	name ,
	num_of_gold_medals , 
	DENSE_RANK() OVER (ORDER BY num_of_gold_medals DESC ) AS ranking
    FROM Gold_medal_rank
	) sub 
WHERE sub.ranking <=5 ;



-- Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).

WITH all_medal AS 
(
SELECT name , COUNT(medal) AS num_of_all_medals
FROM olympics_history 
WHERE medal IN ('Gold','Silver','Bronze')
GROUP BY 1
ORDER BY num_of_all_medals DESC )

SELECT * 
FROM (
    SELECT 
	name ,
	num_of_all_medals , 
	DENSE_RANK() OVER (ORDER BY num_of_all_medals DESC ) AS ranking
    FROM all_medal
	) sub 
WHERE sub.ranking <=5 ;



-- Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.

WITH all_medal AS 
(
SELECT 
	name ,
	team , 
	COUNT(medal) AS num_of_all_medals
FROM olympics_history 
GROUP BY 1 , 2
ORDER BY num_of_all_medals DESC )

SELECT * 
FROM (
    SELECT 
	name , team ,
	num_of_all_medals , 
	DENSE_RANK() OVER (ORDER BY num_of_all_medals DESC ) AS ranking
    FROM all_medal
	) sub 
WHERE sub.ranking <=5 ;



--List down total gold, silver and broze medals won by each country.

SELECT 
	b.region , 
	COUNT(a.medal) AS num_of_all_medals
FROM olympics_history a
JOIN olympics_history_noc_regions b
ON a.noc=b.noc
WHERE medal IN ('Gold','Silver','Bronze')
GROUP BY 1
ORDER BY num_of_all_medals DESC ;


--List down total gold, silver and broze medals won by each country corresponding to each olympic games.

SELECT 
    a.games ,
	b.region , 
	COUNT(CASE WHEN medal='Gold' THEN 1 ELSE NULL END ) AS num_of_gold_medals ,
	COUNT(CASE WHEN medal='Silver' THEN 1 ELSE NULL END ) AS num_of_silver_medals ,
	COUNT(CASE WHEN medal='Bronze' THEN 1 ELSE NULL END ) AS num_of_bronze_medals ,
	COUNT(*) AS all_medals
FROM olympics_history a
JOIN olympics_history_noc_regions b
ON a.noc=b.noc
WHERE medal IN ('Gold','Silver','Bronze')
GROUP BY 1 , 2
ORDER BY a.games ; 



-- Identify which country won the most gold, most silver and most bronze medals in each olympic games.

WITH medals_cte AS 
(SELECT 
    a.games ,
	b.region , 
	COUNT(CASE WHEN medal='Gold' THEN 1 ELSE NULL END ) AS num_of_gold_medals ,
	COUNT(CASE WHEN medal='Silver' THEN 1 ELSE NULL END ) AS num_of_silver_medals ,
	COUNT(CASE WHEN medal='Bronze' THEN 1 ELSE NULL END ) AS num_of_bronze_medals ,
	COUNT(*) AS all_medals
FROM olympics_history a
JOIN olympics_history_noc_regions b
ON a.noc=b.noc
WHERE medal IN ('Gold','Silver','Bronze')
GROUP BY 1 , 2
ORDER BY a.games )

SELECT 
	DISTINCT games , 
	CONCAT (FIRST_VALUE(region)OVER(PARTITION BY games ORDER BY num_of_gold_medals DESC),'-',FIRST_VALUE(num_of_gold_medals)OVER(PARTITION BY games ORDER BY num_of_gold_medals DESC)) AS most_gold_medal_country ,
    CONCAT (FIRST_VALUE(region)OVER(PARTITION BY games ORDER BY num_of_silver_medals DESC),'-',FIRST_VALUE(num_of_silver_medals)OVER(PARTITION BY games ORDER BY num_of_silver_medals DESC)) AS most_silver_medal_country ,
	CONCAT (FIRST_VALUE(region)OVER(PARTITION BY games ORDER BY num_of_bronze_medals DESC),'-',FIRST_VALUE(num_of_bronze_medals)OVER(PARTITION BY games ORDER BY num_of_bronze_medals DESC)) AS most_bronze_medal_country 
FROM medals_cte 
ORDER BY games ;



--Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.
WITH medals_cte AS 
(SELECT 
    a.games ,
	b.region , 
	COUNT(CASE WHEN medal='Gold' THEN 1 ELSE NULL END ) AS num_of_gold_medals ,
	COUNT(CASE WHEN medal='Silver' THEN 1 ELSE NULL END ) AS num_of_silver_medals ,
	COUNT(CASE WHEN medal='Bronze' THEN 1 ELSE NULL END ) AS num_of_bronze_medals ,
	COUNT(*) AS all_medals
FROM olympics_history a
JOIN olympics_history_noc_regions b
ON a.noc=b.noc
WHERE medal IN ('Gold','Silver','Bronze')
GROUP BY 1 , 2
ORDER BY a.games )

SELECT 
	DISTINCT games , 
	CONCAT (FIRST_VALUE(region)OVER(PARTITION BY games ORDER BY num_of_gold_medals DESC),'-',FIRST_VALUE(num_of_gold_medals)OVER(PARTITION BY games ORDER BY num_of_gold_medals DESC)) AS most_gold_medal_country ,
    CONCAT (FIRST_VALUE(region)OVER(PARTITION BY games ORDER BY num_of_silver_medals DESC),'-',FIRST_VALUE(num_of_silver_medals)OVER(PARTITION BY games ORDER BY num_of_silver_medals DESC)) AS most_silver_medal_country ,
	CONCAT (FIRST_VALUE(region)OVER(PARTITION BY games ORDER BY num_of_bronze_medals DESC),'-',FIRST_VALUE(num_of_bronze_medals)OVER(PARTITION BY games ORDER BY num_of_bronze_medals DESC)) AS most_bronze_medal_country ,
    CONCAT (FIRST_VALUE(region)OVER(PARTITION BY games ORDER BY all_medals DESC),'-',FIRST_VALUE(all_medals)OVER(PARTITION BY games ORDER BY all_medals DESC)) AS most_overall_medal_country 
FROM medals_cte 
ORDER BY games ;



--. Which countries have never won gold medal but have won silver/bronze medals?
SELECT * FROM 
(SELECT 
	b.region , 
	COUNT(CASE WHEN medal='Gold' THEN 1 ELSE NULL END ) AS num_of_gold_medals ,
	COUNT(CASE WHEN medal='Silver' THEN 1 ELSE NULL END ) AS num_of_silver_medals ,
	COUNT(CASE WHEN medal='Bronze' THEN 1 ELSE NULL END ) AS num_of_bronze_medals ,
	COUNT(*) AS all_medals
FROM olympics_history a
JOIN olympics_history_noc_regions b
ON a.noc=b.noc
WHERE medal IN ('Gold','Silver','Bronze')
GROUP BY 1  ) sub 
WHERE sub.num_of_gold_medals=0
ORDER BY sub.all_medals DESC;


-- In which Sport/event, India has won highest medals.

SELECT 
    a.sport ,
	COUNT(CASE WHEN medal='Gold' THEN 1 ELSE NULL END ) AS num_of_gold_medals ,
	COUNT(CASE WHEN medal='Silver' THEN 1 ELSE NULL END ) AS num_of_silver_medals ,
	COUNT(CASE WHEN medal='Bronze' THEN 1 ELSE NULL END ) AS num_of_bronze_medals ,
	COUNT(*) AS all_medals
FROM olympics_history a
JOIN olympics_history_noc_regions b
ON a.noc=b.noc
WHERE medal IN ('Gold','Silver','Bronze')
AND b.region='India'
GROUP BY 1 
ORDER BY all_medals DESC
LIMIT 1 ;



--Break down all olympic games where India won medal for Hockey and how many medals in each olympic games .

SELECT 
	b.region ,
	a.games ,
    a.sport ,
	COUNT(*) AS all_medals
FROM olympics_history a
JOIN olympics_history_noc_regions b
ON a.noc=b.noc
WHERE medal IN ('Gold','Silver','Bronze')
AND b.region='India' AND a.sport='Hockey'
GROUP BY 1 , 2 , 3
ORDER BY a.games   ;


