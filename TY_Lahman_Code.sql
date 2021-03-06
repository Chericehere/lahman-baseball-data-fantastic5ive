--Q1. Finding the range of years provided by the database
SELECT MIN(yearid) AS earliest_year, MAX(yearid) AS most_recent_year
FROM appearances;

--Q2a. Find the name and height of the shortest player in the database.
SELECT playerid, namefirst, namelast, namegiven, height AS height_inches
FROM people
WHERE height IS NOT NULL
ORDER BY height
LIMIT 1;

--Q2b. How many games did Eddie Gaedel play in and what is the name of the team?
SELECT COUNT(*) AS num_games, t.name
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
GROUP BY t.name;