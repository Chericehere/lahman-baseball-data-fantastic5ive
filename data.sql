Select *
FROM teams;

--question 1--
--1871-2017--
SELECT MIN(debut), MAX(finalgame)
FROM people;

/*question 2*/
/*Eddie Gaedel, 43 inches, St. Louis Browns*/
SELECT  DISTINCT(p.playerid), namegiven, namefirst, namelast, height, t.name as teamname
FROM people as p
Left Join batting as b
ON p.playerid = b.playerid
Left Join teams as t
ON t.teamid=b.teamid
WHERE p.playerid='gaedeed01'
ORDER BY height asc;

--QUESTION 3--

SELECT   DISTINCT(p.playerid), p.namefirst as First_Name, p.namelast as Last_Name, Sum(r.salary) as majorsal
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

--David Price--



--Question 7--
SELECT teamid, yearid, w, WSWin
FROM teams
WHERE yearid > 1969
AND wswin = 'N'
ORDER BY w DESC
LIMIT 1;

--116 Wins--

SELECT teamid, yearid, w, WSWin
FROM teams
WHERE yearid > 1969
AND wswin = 'Y'
ORDER BY w ASC
LIMIT 1;

--63 wins--

SELECT teamid, yearid, w, WSWin
FROM teams
WHERE yearid <> 1981
AND yearid > 1969
AND wswin = 'Y'
ORDER BY w ASC;

-- The 1981 Major League Baseball season had a players' strike, which lasted from June 12 to July 31, 1981, and split the season in two halves. --

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
		
--12 wins; 26.09%--

--Question 8--

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

--TOP 5 Parks--



--Question 9--

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

--