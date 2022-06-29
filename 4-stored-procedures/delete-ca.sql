/*********************************************************************************
This procedure deletes a record in ca.
*********************************************************************************/
CREATE or replace procedure delete_ca (
	_dna_test_match_id integer,
	_old_family_search_id VARCHAR(8)
)
language plpgsql
AS $$

declare _ca_id integer;
declare _old_ancestor_id integer;
begin

/* Get the _old_ancestor_id to help figure
out which record in ca needs to be deleted. */
select ancestor_id
into _old_ancestor_id
from ancestor
where family_search_id = _old_family_search_id;

IF NOT FOUND THEN
    RAISE 'An ancestor with the family_search_id of % could not be found. 
		Please check your input.', _old_family_search_id;
END IF;

/* Figure out which record in ca needs to be deleted. */
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

/* Delete the correct record in ca. */
delete from ca 
where ca.ca_id = _ca_id;

end;
$$;