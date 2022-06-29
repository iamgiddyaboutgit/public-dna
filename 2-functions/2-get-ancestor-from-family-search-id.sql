create or replace function get_ancestor_from_family_search_id (_family_search_id varchar(8))
returns table (
	ancestor_name text
)
as $$
begin
	return query
	select CONCAT_WS(
		' ', 
		ancestor_title, 
		ancestor_given_name, 
		ancestor_surname, 
		ancestor_suffix) AS ancestor_name
	FROM ancestor
	where ancestor.family_search_id = _family_search_id
	limit 1;

end;
$$ language plpgsql;