-- Run after the psql import.
call import_23_and_me(email_of_home_person => 'email@gmail.com');
call import_my_heritage(email_of_home_person => 'email@gmail.com');

select *
from hypothesize(
	_email => 'email.com', 
	_chromosome_name_id => null, 
	_dna_start => null, 
	_dna_end => null, 
	_min_overall_cm => null);

call new_ca(
	_dna_test_match_id => 1, 
	_family_search_id => 'AAAA-AAA', 
	_ca_is_verified => B'0');

call new_segment_ca(
	_segment_match_id => 1, 
	_family_search_id => 'AAAA-AAA', 
	_ca_is_verified => B'1');

call new_ancestor('AAAA-AAA', 'Dr.', 'given', 'surname', 'Sr.');

select * 
from get_inheritance('AAAA-AAA', 'BBBB-BBB');