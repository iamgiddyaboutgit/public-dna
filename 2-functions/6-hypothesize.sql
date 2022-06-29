/* Find all of the segment matches
associated with the home person's email.  
Display hypothesized common ancestors.
*/
create or replace function hypothesize (
	_email varchar(100),
	_chromosome_name_id int,
	_dna_start int,
	_dna_end int,
	_min_overall_cm numeric(5,1))
returns table
(
	dna_test_match_id integer,
	match_has_been_contacted bit(1), 	
	paternal_haplogroup varchar(50),
	maternal_haplogroup varchar(50),
	overall_cm numeric(5, 1),
	segment_match_id integer,
	chromosome_name_id integer,
	kit varchar(100),
	company varchar(50),
	person_user_name varchar(75),
	dna_start integer,
	dna_end integer,
	cm numeric(5,1),
	snps integer,
	segment_ca_family_search_id varchar(8),
	segment_ca text,
	segment_ca_is_verified bit(1),
	other_segment_ca text,
	other_segment_ca_is_verified bit(1),
	ca text,
	ca_is_verified bit(1)
)
as $$
begin

	/* The thing that is most confusing about this query
	is that there are three different types of common
	ancestors.  There are those in ca.  There are
	those that are for the particular segment in
	question and there are those that are for other
	segments. */
	return query
	select 
		dna_test_match.dna_test_match_id,
		dna_test_match.match_has_been_contacted,
		dna_test.paternal_haplogroup,
		dna_test.maternal_haplogroup,
		dna_test_match.cm as overall_cm,
		segment_match.segment_match_id,
		segment_match.chromosome_name_id,
		dna_test.kit,
		dna_test.company,
		dna_test.person_user_name,
		segment_match.dna_start,
		segment_match.dna_end,
		segment_match.cm,
		segment_match.snps,
		anc1.family_search_id as segment_ca_family_search_id,
		CONCAT_WS(
				' ', 
				anc1.ancestor_title, 
				anc1.ancestor_given_name, 
				anc1.ancestor_surname, 
				anc1.ancestor_suffix) as segment_ca,
		segment_ca.ca_is_verified as segment_ca_is_verified,
		CONCAT_WS(
				' ', 
				anc2.ancestor_title, 
				anc2.ancestor_given_name, 
				anc2.ancestor_surname, 
				anc2.ancestor_suffix) as other_segment_ca,
		other_seg_stuff.other_seg_ca_is_verified,
		CONCAT_WS(
				' ', 
				anc3.ancestor_title, 
				anc3.ancestor_given_name, 
				anc3.ancestor_surname, 
				anc3.ancestor_suffix) as ca,
		ca.ca_is_verified as ca_is_verified
	from dna_test_match
	join get_fav_tests(_email) as fav_tests
		on dna_test_match.dna_test_id1 = fav_tests.dna_test_id	
	join dna_test
		on dna_test.dna_test_id = dna_test_match.dna_test_id2 
	join segment_match
		on dna_test_match.dna_test_match_id = segment_match.dna_test_match_id
	left join ca
		on dna_test_match.dna_test_match_id = ca.dna_test_match_id
	left join segment_ca
		on segment_match.segment_match_id = segment_ca.segment_match_id
	left join (
		select 
			segment_match.segment_match_id,
			segment_match.dna_test_match_id,
			other_seg_match.segment_match_id as other_seg_match_id,
			other_seg_ca.segment_ca_id as other_seg_ca_id,
			other_seg_ca.ca_is_verified as other_seg_ca_is_verified
		from segment_match 
		join segment_match as other_seg_match
			on 
				(segment_match.dna_test_match_id = other_seg_match.dna_test_match_id)
			and
				(segment_match.segment_match_id <> other_seg_match.segment_match_id)
		join segment_ca as other_seg_ca
			on other_seg_match.segment_match_id = other_seg_ca.segment_match_id
	) as other_seg_stuff
		on segment_match.segment_match_id = other_seg_stuff.segment_match_id
	left join ancestor as anc1
		on segment_ca.ancestor_id = anc1.ancestor_id
	left join ancestor as anc2
		on other_seg_stuff.other_seg_ca_id = anc2.ancestor_id
	left join ancestor as anc3
		on ca.ancestor_id = anc3.ancestor_id
	where 
			(segment_match.chromosome_name_id = _chromosome_name_id 
			or 
			_chromosome_name_id is null)
		and
			(_dna_end >= segment_match.dna_start or _dna_end is null
			and
			_dna_start <= segment_match.dna_end or _dna_start is null)
		and
			(dna_test_match.cm >= _min_overall_cm
			or
			_min_overall_cm is null)			
	order by 
		segment_match.chromosome_name_id, 
		segment_match.dna_start, 
		segment_match.dna_end,
		dna_test_match.dna_test_match_id;
end;
$$ language plpgsql;

	

