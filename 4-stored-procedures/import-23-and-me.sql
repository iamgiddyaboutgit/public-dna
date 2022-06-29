/****************************************************************************************************************
STORED PROC: import_23_and_me
DESC: Imports data collected from 23andMe. Duplicate imports will be prevented by 
using the link_to_profile_page.
*************************************************************************************************/
CREATE or replace procedure import_23_and_me (
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
where company = '23andMe';

IF NOT FOUND THEN
    RAISE 'A favorite test with 23andMe 
		could not be found for the email %', email_of_home_person;
END IF;
	

insert into dna_test (kit, company, paternal_haplogroup, maternal_haplogroup, person_user_name)
select distinct
	raw_data_23_and_me.link_to_profile_page as kit,
	'23andMe' as company,
	case when raw_data_23_and_me.paternal_haplogroup = ''
		then null
		else substring(raw_data_23_and_me.paternal_haplogroup from 1 for 1)
	end as paternal_haplogroup,
	case when raw_data_23_and_me.maternal_haplogroup = ''
		then null
		when substring(raw_data_23_and_me.maternal_haplogroup from 1 for 1) = 'L'
		then substring(raw_data_23_and_me.maternal_haplogroup from 1 for 2)
		else substring(raw_data_23_and_me.maternal_haplogroup from 1 for 1)
	end as maternal_haplogroup,
	cast(raw_data_23_and_me.display_name as varchar(75)) as person_user_name
from raw_data_23_and_me
left join dna_test
on lower(raw_data_23_and_me.link_to_profile_page)
	= lower(dna_test.kit)
where dna_test.dna_test_id is null;


with new_dna_test_match as (
	
	with all_overlap as (
	
		select distinct
		/* Use the max function here because the ids should
		be the same within the group and some kind of 
		aggregate function is required. */
			max(_home_dna_test_id) as dna_test_id1, 
			max(dna_test.dna_test_id) as dna_test_id2,
			cast(sum(cast(raw_data_23_and_me.genetic_distance as numeric(7, 3))) as numeric(5, 1)) as cm,
			max(raw_data_23_and_me.num_segments_shared) as segments,
			nullif(max(cast(raw_data_23_and_me.notes as varchar(2000))), '') as note,
			max(dna_test_match.dna_test_match_id) as dna_test_match_id
		from raw_data_23_and_me
		join dna_test
		on lower(raw_data_23_and_me.link_to_profile_page) 
			= lower(dna_test.kit)
		/* Note that the purpose of the following join is actually to
		   know which records to exclude later. */
		left join dna_test_match  
		on 
				_home_dna_test_id = dna_test_match.dna_test_id1 
			and 
				dna_test.dna_test_id = dna_test_match.dna_test_id2
		group by raw_data_23_and_me.link_to_profile_page
	)
	
	insert into dna_test_match (dna_test_id1, dna_test_id2, cm, segments, note)
	select
		dna_test_id1, 
		dna_test_id2,
		cm,
		segments,
		note
	from all_overlap
	where dna_test_match_id is null
	
	returning dna_test_match.dna_test_match_id, dna_test_id2
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
	chromosome_name.chromosome_name_id,
	cast(raw_data_23_and_me.chromosome_start_point as integer),
	cast(raw_data_23_and_me.chromosome_end_point as integer),
	cast(raw_data_23_and_me.genetic_distance as numeric(5, 1)),
	cast(raw_data_23_and_me.num_snps as integer)
from raw_data_23_and_me
	join dna_test
	on lower(raw_data_23_and_me.link_to_profile_page) 
		= lower(dna_test.kit)
	join new_dna_test_match
	on dna_test.dna_test_id = new_dna_test_match.dna_test_id2
	join chromosome_name
	on raw_data_23_and_me.chromosome_number = chromosome_name.chromosome_name;

truncate raw_data_23_and_me;

end;
$$;