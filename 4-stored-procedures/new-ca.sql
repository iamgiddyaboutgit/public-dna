/*********************************************************************************
This procedure inserts a new record in ca.
*********************************************************************************/
CREATE or replace procedure new_ca (
	_dna_test_match_id integer,
	_family_search_id VARCHAR(8),
	_ca_is_verified bit(1)
)
language plpgsql
AS $$

declare _ancestor_id integer;
begin
select ancestor_id
into _ancestor_id
from ancestor
where family_search_id = _family_search_id;

IF NOT FOUND THEN
    RAISE 'An ancestor with the family_search_id of % could not be found. 
		Please insert a new ancestor first.', _family_search_id;
END IF;

insert into ca (
	dna_test_match_id,
	ancestor_id,
	ca_is_verified
)
select 
	_dna_test_match_id,
	_ancestor_id,
	_ca_is_verified;
end;
$$;