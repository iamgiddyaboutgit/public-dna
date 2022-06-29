create or replace function get_total_autosomal_cm_in_genome(ref_genome varchar(10))
	returns numeric(6,1)
	
as $$
	select sum(total_chromosome_cm) as total_autosomal_cm_in_genome
	from chromosome_length
	where chromosome_name_id <= 22 and reference_genome = ref_genome;
$$
language sql;