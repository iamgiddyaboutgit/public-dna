/****************************************************************************************************************
STORED PROC: import_my_heritage
DESC: Imports data collected from MyHeritage. Duplicate imports will be prevented by 
using the kit numbers hidden within the dna_match_id field.  
*************************************************************************************************/
CREATE or replace procedure import_my_heritage (
	email_of_home_person VARCHAR(100)
) 
language plpgsql
AS $$
declare _kit varchar(100);
declare _home_dna_test_id integer;
begin
-- Get the favorite _home_dna_test_id and corresponding _kit for the home person.
select dna_test_id, kit
into _home_dna_test_id, _kit 
from get_fav_tests(email_of_home_person) 
where company = 'MyHeritage';

IF NOT FOUND THEN
    RAISE 'A favorite test with MyHeritage 
		could not be found for the email %', email_of_home_person;
END IF;

/* If the _kit does not match the test results,
   then raise an exception.
*/
if lower(_kit) <>
	(select lower(substring(dna_match_id from 3 for 8)) 
	from raw_data_my_heritage
	limit 1)
then raise 'It appears that you are trying
to link DNA matches to the wrong home person.';
	
/* But if the _kit matches the test results,
   then the correct data is in raw_data_my_heritage
   and we can proceed with the inserting. 
*/
else

	insert into dna_test (kit, company, person_user_name)
	/* We select distinct because raw_data_my_heritage 
	   contains segment info, but we don't need that yet. */
	select distinct
		substring(raw_data_my_heritage.dna_match_id from 42 for 8) as kit,
		'MyHeritage' as company,
		cast(raw_data_my_heritage.match_name as varchar(75)) as person_user_name
	from raw_data_my_heritage
	left join dna_test
	on lower(substring(raw_data_my_heritage.dna_match_id from 42 for 8)) 
		= lower(dna_test.kit)
	where dna_test.dna_test_id is null;

	with new_dna_test_match as (
				
		with all_overlap as (
	
		select distinct
		/* Use the max function here because the ids should
		be the same within the group and some kind of 
		aggregate function is required. */
			_home_dna_test_id as dna_test_id1, 
			max(dna_test.dna_test_id) as dna_test_id2,
			sum(raw_data_my_heritage.cm) as cm,
			count(raw_data_my_heritage.dna_match_id) as segments,
			max(dna_test_match.dna_test_match_id) as dna_test_match_id
		from raw_data_my_heritage
		join dna_test
		on lower(substring(raw_data_my_heritage.dna_match_id from 42 for 8)) 
			= lower(dna_test.kit)
		/* Note that the purpose of the following join is actually to
		   know which records to exclude later. */
		left join dna_test_match  
		on 
				_home_dna_test_id = dna_test_match.dna_test_id1 
			and 
				dna_test.dna_test_id = dna_test_match.dna_test_id2
		group by substring(raw_data_my_heritage.dna_match_id from 42 for 8)
		)
		
		insert into dna_test_match (dna_test_id1, dna_test_id2, cm, segments)
		select 
			dna_test_id1,
			dna_test_id2,
			cm,
			segments
		from all_overlap
		where dna_test_match_id is null
		
		returning dna_test_match.dna_test_match_id, dna_test_match.dna_test_id2
	)
	
	insert into segment_match (
		dna_test_match_id,
		chromosome_name_id,
		dna_start,
		dna_end,
		cm,
		snps)
	select 
		new_dna_test_match.dna_test_match_id, 
		raw_data_my_heritage.chromosome,
		raw_data_my_heritage.start_location,
		raw_data_my_heritage.end_location,
		raw_data_my_heritage.cm,
		raw_data_my_heritage.snps
	from raw_data_my_heritage
		join dna_test
		on lower(substring(raw_data_my_heritage.dna_match_id from 42 for 8)) 
			= lower(dna_test.kit)
		join new_dna_test_match
		on dna_test.dna_test_id = new_dna_test_match.dna_test_id2;

	truncate raw_data_my_heritage;
end if;
end;
$$;