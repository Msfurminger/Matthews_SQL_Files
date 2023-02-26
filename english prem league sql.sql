

select * 
from soccer21_22;

-- Which half has more goals?
with sum_of_goals_per_half as
(select
hometeam
,awayteam
 ,sum(hthg + htag) as first_half_goals
   ,sum(fthg + ftag) as full_time_goals
from soccer21_22 
group by 1,2)
select 
sum(first_half_goals) as first_hf_goals
  ,sum(full_time_goals - first_half_goals) as second_hf_goals
 ,sum(full_time_goals) as full_time_goals
 from sum_of_goals_per_half;
 -- Second half has more goals
 
 -- What is the % of goals scored in the first half per game
 with Perc_of_goals_per_half as
(select
hometeam
,awayteam
 ,sum(hthg + htag) as first_half_goals
   ,sum(fthg + ftag) as full_time_goals
from soccer21_22 
group by 1,2)
 select 
  hometeam
  ,awayteam
   ,first_half_goals/full_time_goals as per_of_first_half_goals
 from Perc_of_goals_per_half;
 
 
-- Is homefield advantage real?
with home_and_away_match_results as
(select
count(case when ftr = 'H' then 'hometeam' else null end) as hometeam_win
,count(case when ftr = 'A' then 'awayteam' else null end) as awayteam_win
 ,count(case when ftr = 'D' then 'draw' else null end) as tie
  ,count(ftr) as total_games
 from soccer21_22)
 select 
  hometeam_win/total_games
,awayteam_win/total_games
from home_and_away_match_results;
-- Hometeam wins more often than away

-- Total yellow cards given 
select 
sum(hy + ay)
from soccer21_22;
-- 1291 yellow cards given in the season

-- using the partition by to rank referees based on average cards per game
select 
distinct referee
,avg(hy + ay) over (partition by referee)
from soccer21_22
order by 2 desc;
-- John Brooks averages most yellow cards 

-- When John brooks is reffing is there less goals scored?
select 
avg(fthg + ftag) as avg_goals_per_game
from soccer21_22
where referee = 'J Brooks';
-- average goals scored per game is 2.250

-- find average of goals per game to answer above questions
select
avg(fthg + ftag) as avg_goals_per_game
from soccer21_22;
-- average is 2.8184
-- less goals are scored when John Brooks is reffing

-- Do more shots on target result in more goals?
-- Find total shots per game
select 
sum(hst + ast) as sum_of_shots_on_goal
from soccer21_22;
-- Total shots on target is 3352
select 
avg(hst + ast) as avg_of_shots_on_goal
from soccer21_22;
-- Average shots on target per game are 8.82
-- Find the average of goals scored when shots on target are above average to see if more shots lead to more goals
select 
avg(hst + ast) as avg_of_shots_on_goal
,avg(fthg + ftag) as average_goals_scored
from soccer21_22
group by hst, ast
having avg(hst + ast) > 8.82
order by 2;
-- More shots on goal usually results in more goals being scored, but not for every game

-- Find the team Arsenal average goals per home game
select 
hometeam
,avg(fthg) avg_home_game_goals
from soccer21_22
where hometeam = 'Arsenal'
group by 1
;

-- Find the team Arsenal average goals per away game
select 
 awayteam
 ,avg(ftag) avg_home_game_goals
from soccer21_22
where awayteam = 'Arsenal'
group by 1
;
-- Arsenal score more goals at home 

-- Did Arsenal score more home goals in the year 2021 or 2022?
select 
 hometeam
  ,sum(fthg) as total_goals_scored
 from soccer21_22
 where date < '20-12-2021'
 and hometeam = 'Arsenal'
 group by 1;
 -- 12-20 was Arsenals last game of the year
 
 select 
 hometeam
  ,sum(fthg) as total_goals_scored
 from soccer21_22
 where date > '20-12-2021'
 and hometeam = 'Arsenal'
 group by 1;
 -- Arsenal scored more goals in the second half, showing they picked up the effort






