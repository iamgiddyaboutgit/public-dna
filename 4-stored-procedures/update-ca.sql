/*********************************************************************************
This procedure updates a record in ca.
*********************************************************************************/
CREATE or replace procedure update_ca (
	_dna_test_match_id integer,
	_old_family_search_id VARCHAR(8),
	_updated_family_search_id VARCHAR(8),
	_updated_ca_is_verified bit(1)
)
language plpgsql
AS $$

declare _ca_id integer;
declare _old_ancestor_id integer;
declare _updated_ancestor_id integer;
begin

/* Get the _old_ancestor_id to assist in pulling
the correct record from ca. */
select ancestor_id
into _old_ancestor_id
from ancestor
where family_search_id = _old_family_search_id;

IF NOT FOUND THEN
    RAISE 'An ancestor with the family_search_id of % could not be found. 
		Please check your input.', _old_family_search_id;
END IF;

/* Get the _updated_ancestor_id. */
select ancestor_id
into _updated_ancestor_id
from ancestor
where family_search_id = _updated_family_search_id;

IF NOT FOUND THEN
    RAISE 'An ancestor with the family_search_id of % could not be found. 
		Please insert a new ancestor first.', _updated_family_search_id;
END IF;

/* Figure out which record in ca needs to be updated. */
select ca_id
into _ca_id
from ca
where 
		ca.dna_test_match_id = _dna_test_match_id
	and
		ca.ancestor_id = _old_ancestor_id;

IF NOT FOUND THEN
    RAISE 'A corresponding record in ca could not be found.';
END IF;

/* Update the correct record in ca. */
update ca 
set 
	dna_test_match_id = _dna_test_match_id,
	ancestor_id = _updated_ancestor_id,
	ca_is_verified = _updated_ca_is_verified
where ca.ca_id = _ca_id;

end;
$$;