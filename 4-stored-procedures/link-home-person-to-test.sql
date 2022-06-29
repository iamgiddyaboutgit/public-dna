/*********************************************************************************
This procedure updates a person's records in dna_test to include a reference
to their record in the person table.
*********************************************************************************/
CREATE or replace procedure link_home_person_to_test (
	_email VARCHAR(100),
	_kit VARCHAR(100)
) 
language plpgsql
AS $$
begin
IF not EXISTS (
	SELECT person.email
	FROM person
	WHERE person.email = _email)
			
	then raise 'This email is not associated with someone in the database.';
else
	update dna_test
	set person_id = get_person_id_from_email(_email)
	where kit = _kit;
end if;
end;
$$;