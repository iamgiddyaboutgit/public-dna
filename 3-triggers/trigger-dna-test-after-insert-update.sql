create or replace function function_dna_test_after_insert_update()
	returns trigger
	as $$
	begin
		/* Ensure that each person has at most one favorite kit with
		   each company. 
		*/
		if exists (
			select count(inserted.kit_is_favorite_with_company)
			from dna_test
			join inserted
			on 
				dna_test.person_id = inserted.person_id 
			and 
				dna_test.company = inserted.company 
			where dna_test.kit_is_favorite_with_company = B'1'
			group by dna_test.person_id, dna_test.company			
			having count(dna_test.kit_is_favorite_with_company = B'1') > 1) 
		then
		raise 'This person already has a favorite kit with this company.';
		end if;
		
		return new;
	end;
	$$
language plpgsql;

begin;
drop trigger if exists trigger_dna_test_after_insert on dna_test;

CREATE TRIGGER trigger_dna_test_after_insert
	AFTER insert
	on dna_test
	referencing new table as inserted
	for each statement
		execute function function_dna_test_after_insert_update();

drop trigger if exists trigger_dna_test_after_update on dna_test;

CREATE TRIGGER trigger_dna_test_after_update
	AFTER update
	on dna_test
	referencing new table as inserted
	for each statement
		execute function function_dna_test_after_insert_update();
commit;