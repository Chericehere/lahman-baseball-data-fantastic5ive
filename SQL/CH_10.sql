--3. David Price

/*SELECT   DISTINCT(p.playerid), p.namefirst as First_Name, p.namelast as Last_Name, Sum(r.salary) as majorsal
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
*/	
--4 
/*
SELECT  count(pos) as Putouts, 
CASE
	WHEN pos in ('SS','1B', '2B', '3B') Then 'Infield'
	WHEN pos = 'OF' THEN 'Outfield'
	WHEN pos in ('P' ,'C') THEN 'Battery' 
	End as Position
From Fielding	
GROUP BY Position, yearid
HAVING yearid = '2016';
*/	

--9
/*SELECT DISTINCT NL.playerid, CONCAT(p.namefirst, ' ', p.namelast) AS manager_name, nl.yearid AS year, m.teamid, t.name, 'NL' AS league
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
*/



--10



Select Count(p.Playerid) as players,s.schoolname
From people as p
Left join collegeplaying as c
on p.playerid= c.playerid
Left join schools as s
on c.schoolid = s.schoolid 
Where schoolstate ='TN'
group by schoolname
order by players DESC;