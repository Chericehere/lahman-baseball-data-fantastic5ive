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
SELECT decade, ROUND((decso/decgames), 2) as dec_avg_so, ROUND((dechr/decgames), 2) as dec_avg_hr
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

--Solving question, calculating the highest success rate - no joins/no actual names
Select player, stolen, caught, attempts, ROUND((stolen/attempts),2) as success_rate
FROM
	(SELECT yearid as year, playerid as player, sb as stolen, cs as caught, 
			CAST((sb + cs) as numeric) as attempts
	FROM batting
	WHERE yearid = 2016) as sub
WHERE attempts >= 20
ORDER BY success_rate DESC

--testing out joins for No6 -> to include names
SELECT 	b.yearid as year, b.sb as stolen, b.cs as caught, 
	  	CAST((b.sb + b.cs) as numeric) as attempts,
		CONCAT(p.namefirst, ' ', p.namelast) as player
	FROM batting as b
LEFT JOIN people as p
	USING (playerid)
--INCLUDING JOINS/ACTUAL Names of players ->this is the final answer
Select full_name, stolen, caught, attempts, ROUND((stolen/attempts),2) as success_rate
FROM
	(SELECT 	b.yearid as year, b.sb as stolen, b.cs as caught, 
	  	CAST((b.sb + b.cs) as numeric) as attempts,
		CONCAT(p.namefirst, ' ', p.namelast) as full_name
	FROM batting as b
LEFT JOIN people as p
	USING (playerid)) as sub
WHERE attempts >= 20 AND year = 2016
ORDER BY success_rate DESC
LIMIT 1

--Num 8 Finding names of parks and teams
Select DISTINCT sub.games as games, sub.attendance as attendance, sub.park_name as park, t.name as team
FROM 
(SELECT h.team as teamid, CAST(h.games as numeric), CAST(h.attendance as numeric), 
		p.park_name 
	FROM homegames as h
LEFT JOIN parks as p
USING (park)	
WHERE year = 2016 AND games >1) as sub
LEFT JOIN teams as t
USING (teamid)

--trying to find top 5 with names included
SELECT team, DISTINCT park, games, attendance, ROUND((attendance/games),2) as avg_attendance
FROM
	(Select DISTINCT sub.games as games, sub.attendance as attendance, sub.park_name as park, t.name as team
FROM 
(SELECT h.team as teamid, CAST(h.games as numeric), CAST(h.attendance as numeric), 
		p.park_name 
	FROM homegames as h
LEFT JOIN parks as p
USING (park)	
WHERE year = 2016 AND games >1) as sub
LEFT JOIN teams as t
USING (teamid)) as sub
ORDER BY avg_attendance DESC

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

--combining the necessary tables to create subquery  - for some reason I need to specify both years as 2016?
SELECT t.teamid, t.park, t.name, h.park, h.games, h.attendance
FROM teams as t
LEFT JOIN homegames as h
ON t.teamid = h.team
WHERE h.games > 10 AND h.year = 2016 AND t.yearid = 2016

--using subquery to make answer -> highest
SELECT park, team, games, attendance, ROUND((attendance/games),2) as avg_attendance
FROM
	(SELECT t.teamid as team_letters, t.park as park, t.name as team, 
	 h.park as parkletters, CAST(h.games as numeric) as games, 
	 CAST(h.attendance as numeric) as attendance
	FROM teams as t
	LEFT JOIN homegames as h
	ON t.teamid = h.team
	WHERE h.games > 10 AND h.year = 2016 AND t.yearid = 2016) as sub
ORDER BY avg_attendance desc
LIMIT 5