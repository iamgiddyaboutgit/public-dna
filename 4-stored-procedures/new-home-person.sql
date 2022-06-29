/*********************************************************************************
This procedure adds profile information for a new home person.
*********************************************************************************/
CREATE or replace procedure new_home_person (
	new_email VARCHAR(100),
	new_person_given_name VARCHAR(75),
	new_person_surname VARCHAR(50),
	new_person_location VARCHAR(50),
	new_person_website VARCHAR(1000)
)
language plpgsql
AS $$
declare 
	successfully_inserted_person_id integer;
begin
/* Check that this is actually a new person by checking that
their email has not been inserted before.
*/
IF EXISTS (
	SELECT person.email
	FROM person
	WHERE person.email = new_email)
			
	then raise 'This email is already associated with someone in the database.';
end if;

-- Put them in.
insert into person (email, person_given_name, person_surname, person_location)
select new_email, new_person_given_name, new_person_surname, new_person_location
returning person.person_id into successfully_inserted_person_id;

IF new_person_website IS NOT NULL
	then 
	insert into person_website (person_id, person_website)
	select successfully_inserted_person_id, new_person_website;
end if;
end;
$$;