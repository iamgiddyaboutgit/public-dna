/*********************************************************************************
Given someone's email, return their person_id. 
*********************************************************************************/
CREATE or replace function get_person_id_from_email (
	_email VARCHAR(100)
)
returns integer 
language plpgsql
AS $$
begin
IF not EXISTS (
	SELECT person.email
	FROM person
	WHERE person.email = _email)			
then 
	raise 'This email is not associated with someone in the database.';
else
	return (
		select person_id
		from person
		where email = _email
	);	
end if;
end;
$$;