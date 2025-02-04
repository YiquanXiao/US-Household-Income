
select 
	State_Name, 
    sum(ALand), 
    sum(AWater)
from ushouseholdincome
group by State_Name
order by 2 desc
;

select 
	State_Name, 
    sum(ALand), 
    sum(AWater)
from ushouseholdincome
group by State_Name
order by 3 desc
;


select 
	*
from ushouseholdincome u 
join ushouseholdincome_statistics us 
	on u.id = us.id
where us.Mean != 0
;


# top 10 states with highest household income
select 
	u.State_Name, 
    round(avg(us.Mean), 1), 
    round(avg(us.Median), 1)
from ushouseholdincome u 
join ushouseholdincome_statistics us 
	on u.id = us.id
where us.Mean != 0
group by u.State_Name
order by 2 desc  # also asc for lowest 10
limit 10
;
# similarly, for median
select 
	u.State_Name, 
    round(avg(us.Mean), 1), 
    round(avg(us.Median), 1)
from ushouseholdincome u 
join ushouseholdincome_statistics us 
	on u.id = us.id
where us.Mean != 0
group by u.State_Name
order by 3 desc  # also asc for lowest 10
limit 10
;


# although 'Municipality' has highest Mean income, it only has 1 value which is unreliable
select 
	u.`Type`, 
    count(u.`Type`), 
    round(avg(us.Mean), 1), 
    round(avg(us.Median), 1)
from ushouseholdincome u 
join ushouseholdincome_statistics us 
	on u.id = us.id
where us.Mean != 0
group by u.`Type`
order by 3 desc  
;
# get rid of Type with low counts
select 
	u.`Type`, 
    count(u.`Type`), 
    round(avg(us.Mean), 1), 
    round(avg(us.Median), 1)
from ushouseholdincome u 
join ushouseholdincome_statistics us 
	on u.id = us.id
where us.Mean != 0
group by u.`Type`
having count(u.`Type`) > 100
order by 3 desc  
;

# 'CDP' has extremely high Median income
select 
	u.`Type`, 
    count(u.`Type`), 
    round(avg(us.Mean), 1), 
    round(avg(us.Median), 1)
from ushouseholdincome u 
join ushouseholdincome_statistics us 
	on u.id = us.id
where us.Mean != 0
group by u.`Type`
having count(u.`Type`) > 100
order by 4 desc  
;


# Look at City with highest income
# Notice that it seems there is an upper bound on the median, might need to further figure it out
select 
	u.State_Name, 
    u.City, 
    round(avg(us.Mean), 1), 
    round(avg(us.Median), 1)
from ushouseholdincome u 
join ushouseholdincome_statistics us 
	on u.id = us.id
where us.Mean != 0
group by u.State_Name, u.City
order by 3 desc
;






