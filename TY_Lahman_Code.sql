--Q1. Finding the range of years provided by the database
SELECT MIN(yearid) AS earliest_year, MAX(yearid) AS most_recent_year
FROM appearances;

--Q2a. Find the name and height of the shortest player in the database.
SELECT playerid, namefirst, namelast, namegiven, height AS height_inches
FROM people
WHERE height IS NOT NULL
ORDER BY height
LIMIT 3;

--Q2b. How many games did Eddie Gaedel play in and what is the name of the team?
SELECT p.namefirst, p.namelast, COUNT(*) AS num_games, t.name
FROM appearances AS a
LEFT JOIN people AS p
USING (playerid)
LEFT JOIN teams AS t
USING (teamid)
WHERE p.playerid = (
	SELECT playerid
	FROM people
	WHERE height IS NOT NULL
	ORDER BY height
	LIMIT 1)
GROUP BY p.namefirst, p.namelast, t.name;

--Q9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

/*
Let's break this one down. What do I need first? Let's find the Manager of the Year awards. 
*/

--This will UNION all the managers that have gotten the TSN award, first with the NL and then with AL. I think I will need to use a inner join to find managers that won both. 
SELECT *
FROM (
	SELECT *
	FROM awardsmanagers
	WHERE lgid = 'NL' AND awardid = 'TSN Manager of the Year'
	UNION ALL
	SELECT *
	FROM awardsmanagers
	WHERE lgid = 'AL' AND awardid = 'TSN Manager of the Year') sub
;

/*
I will use a CTE to define a table for TSN winners for the NL, and another CTE for TSN winners for AL.
Let's try an INNER JOIN. 
This gives me a list of managers that have won both TSN awards in the NL and the AL. 
I will add a LEFT JOIN to include the manager's full name. I will CONCAT their first name and their last name.
*/

WITH NL AS (
	SELECT *
	FROM awardsmanagers
	WHERE lgid = 'NL' AND awardid = 'TSN Manager of the Year'),
	
	AL AS (
	SELECT *
	FROM awardsmanagers
	WHERE lgid = 'AL' AND awardid = 'TSN Manager of the Year')

SELECT NL.playerid, CONCAT(p.namefirst, ' ', p.namelast) AS manager_name, NL.yearid AS TSN_NL_year, AL.yearid AS TSN_AL_year
FROM NL
INNER JOIN AL
USING (playerid)
LEFT JOIN people AS p
USING (playerid)
;

/*
Now I need the teams they were on during those winning years. Tough. Stuck.
Let's try this with subqueries
Top portion finds all of the NL TSN and bottom finds all the AL. Subqueries limit only to coaches that have won both. 
*/

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
ORDER BY league
; 

/*
Q11. Is there any correlation between number of wins and team salary? 
Use data from 2000 and later to answer this question.
As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.
*/

--This gives me a teams yearly wins starting in year 2000.
SELECT teamid, yearid, SUM(w) AS wins_year
FROM teams
WHERE yearid >= 2000
GROUP BY ROLLUP(teamid, yearid)
ORDER BY teamid, yearid;

--This gives me the yearly salary starting in the year 2000
SELECT teamid, yearid, SUM(salary) AS yearly_salary
FROM salaries
WHERE yearid >= 2000
GROUP BY ROLLUP(teamid, yearid)
ORDER BY teamid, yearid;

--Let's join them
SELECT t.teamid, t.yearid, SUM(t.w) AS wins_year, s.yearly_salary
FROM teams AS t
LEFT JOIN (
	SELECT teamid, yearid, SUM(salary) AS yearly_salary
	FROM salaries
	WHERE yearid >= 2000
	GROUP BY ROLLUP(teamid, yearid)
	ORDER BY teamid, yearid) AS s
WHERE t.yearid >= 2000
GROUP BY ROLLUP(t.teamid, t.yearid)
ORDER BY t.teamid, t.yearid;

