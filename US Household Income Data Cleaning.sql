
select *
from ushouseholdincome
;
select *
from ushouseholdincome_statistics
;


# check how many data are imported
select count(id)
from ushouseholdincome
;
select count(id)
from ushouseholdincome_statistics
;


########################## Remove Duplicate ##########################
select id, count(id)
from ushouseholdincome
group by id
having count(id) > 1
;

select * 
from (
	select 
		row_id, 
		id, 
		row_number() over(partition by id order by id) as row_num
	from ushouseholdincome
	) as row_tab
where row_num > 1
;

delete from ushouseholdincome 
where row_id in (
	select row_id 
	from (
		select 
			row_id, 
			id, 
			row_number() over(partition by id order by id) as row_num
		from ushouseholdincome
		) as row_tab
	where row_num > 1
	)
;


select id, count(id)
from ushouseholdincome_statistics
group by id
having count(id) > 1
;


########################## State_Name ##########################
select State_Name, count(State_Name)  # select distinct State_Name
from ushouseholdincome
group by State_Name
order by State_Name
;
# there's a typo "georia"
update ushouseholdincome
set State_Name = 'Georgia' 
where State_Name = 'georia' 
;
# another issue not detected by statements above, but can visually see it: 
update ushouseholdincome
set State_Name = 'Alabama' 
where State_Name = 'alabama' 
;


########################## State_ab ##########################
select distinct State_ab
from ushouseholdincome
order by State_ab
;


########################## Place ##########################
select *
from ushouseholdincome
where Place = ''
;
select *
from ushouseholdincome
where Place is null
;
# there is one null value
update ushouseholdincome t1
join ushouseholdincome t2
	on t1.Zip_Code = t2.Zip_Code
set t1.Place = t2.Place 
where 
	t1.Place is null
    and t2.Place is not null
	and t2.Zip_Code = '35179'
;


########################## Type ##########################
select `Type`, count(`Type`)
from ushouseholdincome
group by `Type`
order by `Type`
;
# typo: 'Boroughs' should be 'Borough'
update ushouseholdincome
set `Type` = 'Borough'
where `Type` = 'Boroughs'
;


########################## ALand AWater ##########################
# a place should have either land or water or both. They can't have no land and no water at the same time
select ALand, AWater
from ushouseholdincome
where 
	(ALand = 0 or ALand is null)
    and (AWater = 0 or AWater is null)
;






