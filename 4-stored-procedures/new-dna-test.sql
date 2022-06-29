/*********************************************************************************
This procedure inserts a new record in dna_test.
*********************************************************************************/
CREATE or replace procedure new_dna_test (
	_kit VARCHAR(100),
	_company VARCHAR(50),
	_kit_is_favorite_with_company bit(1),
	_paternal_haplogroup VARCHAR(50),
	_maternal_haplogroup VARCHAR(50),
	_reference_genome varchar(10),
	_person_user_name varchar(75)
)
language sql
AS $$
/* GRCh37 will be used as the default reference genome. */
insert into dna_test (
	kit, 
	company, 
	kit_is_favorite_with_company, 
	paternal_haplogroup, 
	maternal_haplogroup,
	reference_genome,
	person_user_name
)
select 
	_kit,
	_company,
	case when _kit_is_favorite_with_company is null then B'0'
		else _kit_is_favorite_with_company
	end,
	_paternal_haplogroup,
	_maternal_haplogroup,
	case when _reference_genome is null then 'GRCh37'
		else _reference_genome
	end,
	_person_user_name;
$$;