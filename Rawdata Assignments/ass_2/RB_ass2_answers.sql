use raw1;

-- ---------------------------------------- a)
drop function if exists movie_count;
delimiter //
create function movie_count (actor_name char(50)) 
returns integer
begin
declare mov_count integer;
SELECT 
    COUNT(DISTINCT movie_id)
INTO mov_count FROM imdb2016.cast_info c, imdb2016.name n, imdb2016.role_type r, imdb2016.title t
WHERE c.person_id = n.id AND c.role_id = r.id
        AND c.movie_id = t.id
        AND t.kind_id = 1
        AND r.role = 'actor'
        AND n.name LIKE actor_name;
return mov_count;
end;//
delimiter ; 

SELECT MOVIE_COUNT('Bacon, Kevin');

-- ---------------------------------------- b)
drop procedure if exists movies;
delimiter //
create procedure movies (cast_name char(50))
begin
	select distinct title from imdb2016.title t, imdb2016.cast_info c, imdb2016.name n, kind_type
	where c.person_id = n.id
	and c.movie_id = t.id
    and t.kind_id = kind_type
    and kind_type = 'movie'
	and name = cast_name;
end;//
delimiter ;

call movies('Mikkelsen, Mads');

-- ---------------------------------------- c)
drop procedure if exists recent_movs;
delimiter //
create procedure recent_movs(titleText char(50))
begin
	select title from imdb2016.title 
    where title like titleText
    order by production_year desc 
    limit 10;
end;//
delimiter ;

call recent_movs('The%');

-- ---------------------------------------- d)
drop function if exists roles;

delimiter //
create function roles(person_name varchar(32))
returns varchar(255)

begin
declare done int default false;
declare role_concat varchar(255) default "" ;
declare role_str varchar(32);
declare role_cursor cursor for SELECT DISTINCT role
	FROM imdb2016.cast_info
	JOIN imdb2016.name
	ON cast_info.person_id = name.id
	JOIN imdb2016.role_type
	ON cast_info.role_id = role_type.id
WHERE name like person_name;
declare continue handler for not found set done = true;

open role_cursor;
#set role_concat = "";
read_loop: loop
	fetch role_cursor into role_str;
    if done then
		leave read_loop;
	end if;
    if char_length(role_concat) > 0 then
	set role_concat = concat(role_concat,  ", ", role_str);
    else set role_concat = concat(role_concat, role_str);
    end if;
end loop;
return role_concat;
close role_cursor;
end;//
delimiter ;

select roles('Bacon, Kevin');

SELECT name,roles(name)
FROM imdb2016.name where name like 'De Niro, R%';

drop function if exists movie_count;
drop procedure if exists movies;
drop procedure if exists recent_movs;
drop function if exists roles;
 
