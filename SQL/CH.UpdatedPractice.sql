--1. What range of years does the database cover?

SELECT MIN(yearid), min_year 
	   MAX(yearid), max_year
From teams;

--2.Find the name and height, game count, and team of the shortest player in the database. 

/*SELECT  namefirst, namelast, Count(a.g_all), t.name,Min(height) as height
From people
Left Join appearances as a
Using (playerid)
Left Join teams as t
Using (teamid)
Group by namefirst, namelast, t.name
Order by height
Limit 1;*/

SELECT  namefirst, namelast, Count(a.g_all), t.name
From people
Left Join appearances as a
Using (playerid)
Left Join teams as t
Using (teamid)
Where playerid in
	(Select playerid
		From people as p
		Order BY height
		Limit 1)
Group by namefirst, namelast, t.name;
	
--3. David Price

SELECT DISTINCT(p.playerid), p.namefirst as First_Name, p.namelast as Last_Name, Sum(r.salary) as majorsal
FROM people as p
LEFT JOIN salaries as r
ON p.playerid = r.playerid
WHERE p.playerid IN 
(Select DISTINCT(playerid)
	From collegeplaying as c
	Left Join schools as s
	ON c.schoolid = s.schoolid
	WHERE s.schoolname = 'Vanderbilt University')
Group by p.playerid
Order by majorsal DESC;	
	
--4. label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". 
--Determine the number of putouts made by each of these three groups in 2016.

SELECT SUM(PO) as Putouts, 
CASE
	WHEN pos in ('SS','1B', '2B', '3B') Then 'Infield'
	WHEN pos = 'OF' THEN 'Outfield'
	WHEN pos in ('P' ,'C') THEN 'Battery' 
	End as Position
From Fielding	
GROUP BY Position, yearid
HAVING yearid = '2016'

-- 5 Find the average number of strikeouts per game by decade since 1920. 
---Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
SELECT FLOOR(yearid/10)*10 as decade, 
		ROUND(Sum(cast(So as numeric(100,2)))/Sum(cast (g as numeric(100,2))),2) as avg_strikeouts,
		ROUND(Sum(cast(HR  as numeric(100,2)))/Sum(cast(g  as numeric(100,2))),2) as avg_homeruns 
FROM TEAMS
Where yearid>1920
Group by decade
Order by decade;


---6. Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (
--A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.

Select CONCAT(namefirst,' ',namelast) as full_name,
	Round((Cast(sb as numeric)/(sb + cs)),2)*100 as sb_success,
	sb as stolen, cs as caught, (sb+cs) as attempts
	FROM batting
	Left Join people as p
	USING (playerid)
Where (sb+cs) > 20 And yearid= 2016
Order by sb_success Desc
Limit 1;



--7a. what is the largest number of wins for a team that did not win the world series? 116
SELECT teamid, yearid, w, WSWin
FROM teams
WHERE yearid > 1969
AND wswin = 'N'
ORDER BY w DESC
LIMIT 1;


--7b. What is the smallest number of wins for a team that did win the world series? 63
----Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case: The 1981 players' strike
SELECT teamid, yearid, w, WSWin
FROM teams
WHERE yearid > 1969
AND wswin = 'Y'
ORDER BY w ASC
LIMIT 1;

--7c. Redo your query, excluding the problem year

SELECT teamid, yearid, w, WSWin
FROM teams
WHERE yearid <> 1981
AND yearid > 1969
AND wswin = 'Y'
ORDER BY w ASC
LIMIT 1;

--7d. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?


WITH winners as	(	SELECT teamid as champ, 
				           yearid, w as champ_w
	  				FROM teams
	  				WHERE 	(wswin = 'Y')
				 			AND (yearid BETWEEN 1970 AND 2016) ),
max_wins as (	SELECT yearid, 
			           max(w) as maxw
	  			FROM teams
	  			WHERE yearid BETWEEN 1970 AND 2016
				GROUP BY yearid)
SELECT 	COUNT(*) AS all_years,
		COUNT(CASE WHEN champ_w = maxw THEN 'Yes' end) as max_wins_by_champ,
		to_char((COUNT(CASE WHEN champ_w = maxw THEN 'Yes' end)/(COUNT(*))::real)*100,'99.99%') as Percent
FROM 	winners LEFT JOIN max_wins
		USING(yearid)

				 

--8. Find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). 
--Only consider parks where there were at least 10 games played. 
--Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance
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
LIMIT 5;

--9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? 
--Give their full name and the teams that they were managing when they won the award.
SELECT DISTINCT NL.playerid, CONCAT(p.namefirst, ' ', p.namelast) AS manager_name, nl.yearid AS year, m.teamid, t.name, 'NL' AS league
FROM (
	SELECT *
	FROM awardsmanagers
	WHERE lgid = 'NL' AND awardid = 'TSN Manager of the Year') AS NL
INNER JOIN (
	SELECT *
	FROM awardsmanagers
	WHERE lgid = 'AL' AND awardid = 'TSN Manager of the Year') AS AL
USING (playerid)
LEFT JOIN people AS p
USING (playerid)
LEFT JOIN managers AS m
ON nl.playerid = m.playerid AND nl.yearid = m.yearid
LEFT JOIN teams AS t
ON m.teamid = t.teamid AND nl.yearid = t.yearid
UNION
SELECT DISTINCT AL.playerid, CONCAT(p.namefirst, ' ', p.namelast) AS manager_name, AL.yearid AS year, m.teamid, t.name, 'AL' AS league
FROM (
	SELECT *
	FROM awardsmanagers
	WHERE lgid = 'NL' AND awardid = 'TSN Manager of the Year') AS NL
INNER JOIN (
	SELECT *
	FROM awardsmanagers
	WHERE lgid = 'AL' AND awardid = 'TSN Manager of the Year') AS AL
USING (playerid)
LEFT JOIN people AS p
USING (playerid)
LEFT JOIN managers AS m
ON al.playerid = m.playerid AND al.yearid = m.yearid
LEFT JOIN teams AS t
ON m.teamid = t.teamid AND al.yearid = t.yearid
ORDER BY league;




--10. Analyze all the colleges in the state of Tennessee. Which college has had the most success in the major leagues.
--Use whatever metric for success you like - number of players, number of games, salaries, world series wins, etc.
Select Count(p.Playerid) as players,s.schoolname
From people as p
Left join collegeplaying as c
on p.playerid= c.playerid
Left join schools as s
on c.schoolid = s.schoolid 
Where schoolstate ='TN'
group by schoolname
order by players DESC;
*/