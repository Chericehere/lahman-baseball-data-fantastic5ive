/*Select namefirst
	   namelast
From people
WHere playerid Exists IN */
	Select DISTINCT(playerid),
			c.schoolid, 
			s.schoolname
	From collegeplaying as c
	Left Join schools as s
	ON c.schoolid = s.schoolid
	WHERE schoolname = 'Vanderbilt University'
--Group by schoolname,playerid; 

