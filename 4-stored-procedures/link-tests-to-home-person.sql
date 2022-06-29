/*********************************************************************************
link_tests_to_home_person will allow multiple tests to be linked to the same 
home person. The tests will have already been inserted but the home person will 
not exist yet. The procedure will create the home person using one of the 
usernames.
*********************************************************************************/
CREATE or replace procedure link_tests_to_home_person (
	test_id variadic integer[]
) 
language plpgsql
AS $$
declare 
	current_test_id integer;
begin
	foreach current_test_id in array test_id loop
		with new_person as (
			insert into person (person_given_name)
			select dna_test.person_user_name
			from dna_test
			where dna_test.dna_test_id = current_test_id
			returning person.person_id
		)
		
		update dna_test 
		set person_id = new_person.person_id
		from new_person
		where dna_test.dna_test_id = current_test_id;
	end loop;
end;
$$;