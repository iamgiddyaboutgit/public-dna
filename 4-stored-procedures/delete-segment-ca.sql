/*********************************************************************************
This procedure deletes a record in segment_ca.
*********************************************************************************/
CREATE or replace procedure delete_segment_ca (
	_segment_match_id integer,
	_old_family_search_id VARCHAR(8)
)
language plpgsql
AS $$

declare _segment_ca_id integer;
declare _old_ancestor_id integer;
begin

/* Get the _old_ancestor_id to help figure
out which record in segment_ca needs to be deleted. */
select ancestor_id
into _old_ancestor_id
from ancestor
where family_search_id = _old_family_search_id;

IF NOT FOUND THEN
    RAISE 'An ancestor with the family_search_id of % could not be found. 
		Please check your input.', _old_family_search_id;
END IF;

/* Figure out which record in segment_ca needs to be deleted. */
select segment_ca_id
into _segment_ca_id
from segment_ca
where 
		segment_ca.segment_match_id = _segment_match_id
	and
		segment_ca.ancestor_id = _old_ancestor_id;

IF NOT FOUND THEN
    RAISE 'A corresponding record in segment_ca could not be found.';
END IF;

/* Delete the correct record in segment_ca. */
delete from segment_ca 
where segment_ca.segment_ca_id = _segment_ca_id;

end;
$$;