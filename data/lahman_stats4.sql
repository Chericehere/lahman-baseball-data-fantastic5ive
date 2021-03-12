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

--5 - Grouping by decade
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

--Number 5 ONE MORE subquery to find the average this time
--And to organize by decade for max strikeouts and homeruns
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

--Alternative number 5 instead of case whens
SELECT decade, ROUND((decso/decgames), 2) as dec_avg_so, ROUND((dechr/decgames), 2) as dec_avg_hr
	FROM(
		SELECT decade, SUM(games) as decgames, sum(totso) as decso, SUM(tothr) as dechr 
		FROM (
			Select yearid, SUM(g) as games, SUM(so) as totso, SUM(hr) as tothr,
			FLOOR(yearid/10)*10 AS decade
			FROM teams
			WHERE yearid >= 1920
			GROUP BY yearid
			ORDER BY yearid) as sub
		GROUP BY decade
		ORDER BY decade) as sub2
--Question Number 6 --<simple/no names
--Building subquery to calculate attempts and filter year  ->no names included
SELECT yearid as year, playerid as player, sb as stolen, cs as caught, 
CAST((sb + cs) as numeric) as attempts
	FROM batting
	WHERE yearid = 2016

--Solving question, calculating the highest success rate - no joins/no actual names included
Select player, stolen, caught, attempts, ROUND((stolen/attempts),2) as success_rate
FROM
	(SELECT yearid as year, playerid as player, sb as stolen, cs as caught, 
			CAST((sb + cs) as numeric) as attempts
	FROM batting
	WHERE yearid = 2016) as sub
WHERE attempts >= 20
ORDER BY success_rate DESC

--Numbe5 6 but better
--testing out joins for No6 -> to include names
--Creating subquery with all relevant information: Player name, stolen, attempts,caught
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

/* Incorrect ways of doing things
	Not sure what exactly I'm doing in all of them yet. Maybe need to filter by something else again
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

--trying to find top 5 with names --I need to filter something else out
SELECT team, park, games, attendance, ROUND((attendance/games),2) as avg_attendance
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
*/

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

--Number 12
select *
from teams

Select *
from homegames
--creating subquery for attendance and wins
SELECT t.teamid as teamletter, t.name as team, CAST(t.w as numeric) as wins, 
CAST(h.attendance as numeric) as attendance, t.WSWin as WSeries
FROM teams as t
LEFT JOIN homegames as h
ON t.teamid = h.team
AND t.yearid = h.year
WHERE t.WSWin IS NOT NULL

--Finding attendance divided by win
SELECT team, wins, attendance, wseries, ROUND((attendance/wins),2) as ApW
FROM
	(SELECT t.teamid as teamletter, t.name as team, CAST(t.w as numeric) as wins, 
	CAST(h.attendance as numeric) as attendance, t.WSWin as WSeries
	FROM teams as t
	LEFT JOIN homegames as h
	ON t.teamid = h.team
	AND t.yearid = h.year
	WHERE t.WSWin IS NOT NULL) as sub
ORDER BY ApW DESC

--Attendancer following worldseries win
SELECT team, wins, attendance, wseries, ROUND((attendance/wins),2) as ApW, year, Wseries
FROM
	(SELECT t.teamid as teamletter, t.name as team, CAST(t.w as numeric) as wins, 
	CAST(h.attendance as numeric) as attendance, t.yearid as year, t.WSWin as WSeries
	FROM teams as t
	LEFT JOIN homegames as h
	ON t.teamid = h.team
	AND t.yearid = h.year
	WHERE t.WSWin = 'Y' AND h.attendance != 0) as sub
ORDER BY ApW DESC

--Using CTE, trying to figure out attendance after world series
WITH CTE
AS (
	SELECT team, wins, attendance, ROUND((attendance/wins),2) as ApW, year, WSWin
	FROM
		(SELECT t.teamid as teamletter, t.name as team, CAST(t.w as numeric) as wins, 
		CAST(h.attendance as numeric) as attendance, t.yearid as year, t.WSWin as WSWin
		FROM teams as t
		LEFT JOIN homegames as h
		ON t.teamid = h.team
		AND t.yearid = h.year
		WHERE WSWin IS NOT NULL AND h.attendance != 0) as sub
	ORDER BY ApW DESC
)
Select team, year, ApW, WSWin
	LAG(ApW, 1) OVER(
		ORDER BY ApW ASC) as year2
FROM CTE
