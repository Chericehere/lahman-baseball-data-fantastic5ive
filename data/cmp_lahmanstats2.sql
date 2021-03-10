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

--Ordering by year, grouping years into decades, and summing games/tot_strikeouts
Select yearid, SUM(g) as games, SUM(so) as totso,
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
SELECT decade, SUM(games) as totgames, sum(totso) as tottotso
FROM 
(Select yearid, SUM(g) as games, SUM(so) as totso,
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
SELECT decade, ROUND((tottotso/totgames), 2) as dec_avg
FROM
(SELECT decade, SUM(games) as totgames, sum(totso) as tottotso
FROM 
(Select yearid, SUM(g) as games, SUM(so) as totso,
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