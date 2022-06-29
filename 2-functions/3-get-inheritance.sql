create or replace function get_inheritance (variadic family_search_ids varchar(8)[])
returns table(
	ancestor_name text, 
	inherited_cm numeric(5, 1),
	total_autosomal_cm_in_genome numeric(5, 1),
	percentage_inherited numeric(5, 3))

as $$
declare total_autosomal_cm_in_genome numeric(5, 1);
begin
	select get_total_autosomal_cm_in_genome('GRCh37') into total_autosomal_cm_in_genome; 

	return query
	select 
		get_ancestor_from_family_search_id(ancestor.family_search_id) as ancestor_name, 
		sum(cm) as inherited_cm, 
		total_autosomal_cm_in_genome,
		cast(sum(cm)/total_autosomal_cm_in_genome * 100 as numeric(5, 3)) as percentage_inherited		
	from ancestor
	join segment_ca
	on ancestor.ancestor_id = segment_ca.ancestor_id
	join segment_match
	on segment_ca.segment_match_id = segment_match.segment_match_id
	where (chromosome_name_id <= 22) 
	AND (ancestor.family_search_id = any(family_search_ids))
	group by ancestor.family_search_id;
end;
$$ language plpgsql;