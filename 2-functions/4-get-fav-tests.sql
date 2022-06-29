/*********************************************************************************
Given someone's email, look up that person's preferred test for each company.  
*********************************************************************************/
CREATE or replace function get_fav_tests (
	_email VARCHAR(100)
)
returns table (
	company varchar(50),
	dna_test_id integer,
	kit varchar(100)
)
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
	return query
		select dna_test.company, dna_test.dna_test_id, dna_test.kit
		from person
		join dna_test
		on person.person_id = dna_test.person_id
		where kit_is_favorite_with_company = B'1' and email = _email;
		
end if;
end;
$$;