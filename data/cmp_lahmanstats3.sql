/*Testing out some code
Select yearid, team, g
from battingpost
WHERE yearid >= 1920

Select yearid, teamid, g
from battingpost
WHERE yearid >= 1920

Select yearid AS year, teamid, g AS game
from battingpost
WHERE yearid >= 1920
GROUP BY battingpost.teamid, battingpost.g, year
order by year, game
--GROUP BY year
--ORDER BY year

Select yearid AS year, teamid, g AS game
from battingpost
WHERE yearid >= 1920
order by year, game
*/
--SELECT ROUND(num, 2)

Select yearid, teamid, g, so
from battingpost
WHERE yearid >= 1920
GROUP BY g,teamid, yearid, so
order by yearid, g

SELECT *
FROM battingpost
WHERE yearid >= 1920
ORDER BY yearid, g

--Q5: Find strikeouts and homeruns per game by decade
--Ordering by year, grouping years into decades, and summing games/tot_strikeouts
Select yearid, SUM(g) as games, SUM(so) as totso, SUM(hr) as tothr,
CASE
    WHEN yearid <= 1929 THEN 1920
	WHEN yearid <= 1939 THEN 1930
	WHEN yearid <= 1949 THEN 1940
	WHEN yearid <= 1959 THEN 1950
	WHEN yearid <= 1969 THEN 1960
	WHEN yearid <= 1979 THEN 1970
	WHEN yearid <= 1989 THEN 1980
	WHEN yearid <= 1999 THEN 1990
	WHEN yearid <= 2009 THEN 2000
	ELSE 2010
END AS decade
FROM teams
WHERE yearid >= 1920
GROUP BY yearid
ORDER BY yearid


--Grouping by decade
SELECT decade, SUM(games) as decgames, sum(totso) as decso, SUM(tothr) as dechr 
FROM 
(Select yearid, SUM(g) as games, SUM(so) as totso, SUM(hr) as tothr,
CASE
    WHEN yearid <= 1929 THEN 1920
	WHEN yearid <= 1939 THEN 1930
	WHEN yearid <= 1949 THEN 1940
	WHEN yearid <= 1959 THEN 1950
	WHEN yearid <= 1969 THEN 1960
	WHEN yearid <= 1979 THEN 1970
	WHEN yearid <= 1989 THEN 1980
	WHEN yearid <= 1999 THEN 1990
	WHEN yearid <= 2009 THEN 2000
	ELSE 2010
END AS decade
FROM teams
WHERE yearid >= 1920
GROUP BY yearid
ORDER BY yearid) as Subquery
GROUP BY decade
ORDER BY decade

--ONE MORE subquery to find the average this time
SELECT decade, ROUND((decso/decgames), 2) as dec_avg, ROUND((dechr/decgames), 2)
	FROM
	(SELECT decade, SUM(games) as decgames, sum(totso) as decso, SUM(tothr) as dechr 
		FROM 
		(Select yearid, SUM(g) as games, SUM(so) as totso, SUM(hr) as tothr,
		CASE
			WHEN yearid <= 1929 THEN 1920
			WHEN yearid <= 1939 THEN 1930
			WHEN yearid <= 1949 THEN 1940
			WHEN yearid <= 1959 THEN 1950
			WHEN yearid <= 1969 THEN 1960
			WHEN yearid <= 1979 THEN 1970
			WHEN yearid <= 1989 THEN 1980
			WHEN yearid <= 1999 THEN 1990
			WHEN yearid <= 2009 THEN 2000
		ELSE 2010
			END AS decade
	FROM teams
		WHERE yearid >= 1920
			GROUP BY yearid
			ORDER BY yearid) as Subquery
				GROUP BY decade
				ORDER BY decade) as sub2
--We noticed that there are more homeruns and more strikeouts per game every decade

--Question Number 6
--Building subquery to calculate attempts and filter year
SELECT yearid as year, playerid as player, sb as stolen, cs as caught, 
CAST((sb + cs) as numeric) as attempts
	FROM batting
	WHERE yearid = 2016

--Solving question, calculating the highest success rate
Select player, stolen, caught, attempts, ROUND((stolen/attempts),2) as success_rate
FROM
	(SELECT yearid as year, playerid as player, sb as stolen, cs as caught, 
			CAST((sb + cs) as numeric) as attempts
	FROM batting
	WHERE yearid = 2016) as sub
WHERE attempts >= 20
ORDER BY success_rate DESC

--Num 8 Setting up subqueries - probably unnecessary but that's ok
SELECT team, park, CAST(games as numeric), CAST(attendance as numeric)
FROM homegames
WHERE year = 2016 AND games >1

--finding answer top 5
SELECT team, park, games, attendance, ROUND((attendance/games),2) as avg_attendance
FROM
	(SELECT team, park, CAST(games as numeric), CAST(attendance as numeric)
	FROM homegames
	WHERE year = 2016 AND games >1) as sub
ORDER BY avg_attendance DESC
LIMIT 5

--finding answer bottom 5
SELECT team, park, games, attendance, ROUND((attendance/games),2) as avg_attendance
FROM
	(SELECT team, park, CAST(games as numeric), CAST(attendance as numeric)
	FROM homegames
	WHERE year = 2016 AND games >1) as sub
ORDER BY avg_attendance
LIMIT 5