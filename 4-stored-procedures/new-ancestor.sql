/*********************************************************************************
This procedure inserts a new record in ancestor.
*********************************************************************************/
CREATE or replace procedure new_ancestor (
	_family_search_id varchar(8),
	_ancestor_title VARCHAR(50),
	_ancestor_given_name VARCHAR(50),
	_ancestor_surname VARCHAR(50),
	_ancestor_suffix VARCHAR(50)
)
language sql
AS $$

insert into ancestor (
	family_search_id,
	ancestor_title,
	ancestor_given_name,
	ancestor_surname,
	ancestor_suffix
)
select 
	_family_search_id,
	_ancestor_title,
	_ancestor_given_name,
	_ancestor_surname,
	_ancestor_suffix;
$$;