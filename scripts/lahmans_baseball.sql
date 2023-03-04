-- Initial Questions

-- For baseball games played, what range of years does the provided database cover?

SELECT MIN(year) as min_year,
	   MAX(year) as max_year	
FROM homegames;
--OUTPUT--
--1871 - 2016

SELECT 
	MIN(yearid) as min_year,
	MAX(yearid) as max_year
FROM batting;
--OUTPUT--
--1871 - 2016


-- Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?



SELECT 
	p.namefirst || ' ' || p.namelast as name,
	MIN(height) as shortest_height,
	(SELECT COUNT(g)
	FROM batting 
	WHERE playerid = 'gaedeed01') as game_count,
	t.name as team_name
FROM people as p
JOIN batting as b
USING(playerid)
JOIN teams as t
USING(teamid)
WHERE playerid = 'gaedeed01'
GROUP BY p.namefirst, p.namelast, height, teamid, team_name



-- Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

SELECT 
	DISTINCT p.playerid,
	namefirst,
	namelast,
	SUM(salary) as total_salary
FROM people as p
JOIN salaries
USING(playerid)
WHERE playerid IN
	(SELECT DISTINCT playerid
	FROM collegeplaying 
	WHERE schoolid = 'vandy')
GROUP BY p.playerid
ORDER BY total_salary DESC;


-- Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.


SELECT 
	CASE WHEN pos = 'OF' THEN 'Outfield'
	WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
	ELSE 'Battery' END AS position,
	SUM(po) total_putout
FROM fielding
WHERE yearid = 2016
GROUP BY position


-- Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?


SELECT 
	CASE WHEN yearID BETWEEN 1920 AND 1929 THEN '1920s'
	WHEN yearID BETWEEN 1930 AND 1939 THEN '1930s'
	WHEN yearID BETWEEN 1940 AND 1949 THEN '1940s'
	WHEN yearID BETWEEN 1950 AND 1959 THEN '1950s'
	WHEN yearID BETWEEN 1960 AND 1969 THEN '1960s'
	WHEN yearID BETWEEN 1970 AND 1979 THEN '1970s'
	WHEN yearID BETWEEN 1980 AND 1989 THEN '1980s'
	WHEN yearID BETWEEN 1990 AND 1999 THEN '1990s'
	WHEN yearID BETWEEN 2000 AND 2009 THEN '2000s'
	ELSE '2010s' END AS decade,
	ROUND(SUM(SO)::NUMERIC/SUM(G/2)::NUMERIC,2) as strikeouts_per_game,
	ROUND(SUM(HR)::NUMERIC/SUM(G/2)::NUMERIC,2) as homeruns_per_game
FROM teams
WHERE yearID >= 1920
GROUP BY decade
ORDER BY decade



-- Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.

SELECT 
	CONCAT(namefirst, ' ', namelast) as name,
	SUM(sb) as stolenbases,
	SUM(cs) as caughtstealing,
	sum(sb+cs) as attempts,
 	SUM(sb) / SUM(sb + cs)::NUMERIC as perc_stolen
FROM batting
LEFT JOIN people as p
USING(playerid)
WHERE yearid = 2016
AND sb+cs >20
GROUP BY playerid, namefirst, namelast
ORDER BY perc_stolen DESC
LIMIT 1;


-- From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

--greats wins not winning worldseries
SELECT 
	teamid,
	w as greatest_wins_nows
FROM teams
WHERE wswin = 'N'
AND yearid BETWEEN '1970' AND '2016'
ORDER BY greatest_wins_nows DESC
LIMIT 1;

--least wins, winning world series
SELECT 
	teamid,
	w as least_wins_ws
FROM teams
WHERE wswin = 'Y'
AND yearid BETWEEN '1970' AND '2016'
AND yearid <> '1981'
ORDER BY least_wins_ws
LIMIT 1

--below query is reviewing all years to get an idea of a normal range of WS wins, I see 1981 is much lower than the rest of the year
SELECT 
	yearid,
	teamid,
	w as least_wins_ws
FROM teams
WHERE wswin = 'Y'
AND yearid BETWEEN '1970' AND '2016'
ORDER BY yearid

-- How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?
SELECT 
	teamid,
	w as wins,
	wswin
FROM teams
WHERE yearid BETWEEN '1970' AND '2016'
AND yearid <> '1981'
ORDER BY wins DESC





-- Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

-- Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

-- Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.