/*
When creating a new database, be sure to set 
the owner correctly.

Set the encoding to "UTF8".
I just left the Template and Tablespace blank.
For the collation and character type, use "C".
*/
CREATE UNLOGGED TABLE public.raw_data_my_heritage
(
	dna_match_id varchar(100),
	home_person varchar(100),
	match_name varchar(100),
	chromosome int,
	start_location int,
	end_location int,
	start_rsid varchar(20),
	end_rsid varchar(20),
	cm numeric(5, 1),
	snps int,
	primary key (dna_match_id, chromosome, start_location)
)

tablespace pg_default;

alter table if exists public.raw_data_my_heritage
	OWNER to admin;
	
CREATE UNLOGGED TABLE public.raw_data_23_and_me
(
	display_name varchar(200),
	surname varchar(30),
	chromosome_number varchar(2),
	chromosome_start_point varchar(50),
	chromosome_end_point varchar(50),
	genetic_distance varchar(50),
	num_snps varchar(50),
	full_ibd varchar(10),
	link_to_profile_page varchar(100),
	sex varchar(10),
	birth_year varchar(4),
	set_relationship varchar(500),
	predicted_relationship varchar(500),
	relative_range varchar(100),
	percent_dna_shared varchar(6),
	num_segments_shared smallint,
	maternal_side varchar(8),
	paternal_side varchar(8),
	maternal_haplogroup varchar(50),
	paternal_haplogroup varchar(50),
	family_surnames varchar(5000),
	family_locations varchar(5000),
	maternal_grandmother_birth_country varchar(50),
	maternal_grandfather_birth_country varchar(50),
	paternal_grandmother_birth_country varchar(50),
	paternal_grandfather_birth_country varchar(50),
	notes varchar(2000),
	sharing_status varchar(9),
	showing_ancestry_results varchar(5),
	family_tree_url varchar(1000),
	primary key (link_to_profile_page, chromosome_number, chromosome_start_point)
)

tablespace pg_default;

alter table if exists public.raw_data_23_and_me
	OWNER to admin;

CREATE TABLE public.person
(
    person_id integer primary key generated always as identity,
	email varchar(100),
	person_given_name varchar(75),
	person_surname varchar(50),
	person_location varchar(50),
	CONSTRAINT unique_email UNIQUE (email)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.person
    OWNER to admin;

CREATE TABLE public.paternal_haplogroup
(
    paternal_haplogroup_id integer primary key generated always as identity,
	paternal_haplogroup varchar(50) not null,
	CONSTRAINT unique_paternal_haplogroup UNIQUE(paternal_haplogroup)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.paternal_haplogroup
    OWNER to admin;

CREATE TABLE public.maternal_haplogroup
(
    maternal_haplogroup_id integer primary key generated always as identity,
	maternal_haplogroup varchar(50) not null,
	CONSTRAINT unique_maternal_haplogroup UNIQUE(maternal_haplogroup)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.maternal_haplogroup
    OWNER to admin;

CREATE TABLE public.company
(
    company varchar(50) primary key
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.company
    OWNER to admin;

CREATE TABLE public.ancestor
(
    ancestor_id integer primary key generated always as identity,
	family_search_id varchar(8) not null,
	ancestor_title varchar(50),
	ancestor_given_name varchar(50),
	ancestor_surname varchar(50),
	ancestor_suffix varchar(50),
	CONSTRAINT unique_family_search_id UNIQUE(family_search_id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.ancestor
    OWNER to admin;

CREATE TABLE public.reference_genome
(
    reference_genome varchar(10) primary key
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.reference_genome
    OWNER to admin;

CREATE TABLE public.chromosome_name
(
    chromosome_name_id integer primary key generated always as identity,
	chromosome_name varchar(2) not null,
	CONSTRAINT unique_chromosome_name UNIQUE(chromosome_name)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.chromosome_name
    OWNER to admin;



-- Create child tables second.

CREATE TABLE public.person_website
(
    person_website_id integer primary key generated always as identity,
	person_id integer not null references person(person_id),
	person_website varchar(1000) not null,
	CONSTRAINT unique_person_id_person_website UNIQUE (person_id, person_website)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.person_website
    OWNER to admin;

CREATE TABLE public.dna_test
(
    dna_test_id integer primary key generated always as identity,
	person_id integer references person(person_id),
	kit varchar(100) not null,
	company varchar(50) not null references company(company),
	kit_is_favorite_with_company bit(1) not null default B'0',
	paternal_haplogroup varchar(50) references paternal_haplogroup(paternal_haplogroup),
	maternal_haplogroup varchar(50) references maternal_haplogroup(maternal_haplogroup),
	reference_genome varchar(10) references reference_genome(reference_genome),
	person_user_name varchar(75),
	date_inserted date not null default current_date,
	CONSTRAINT unique_kit_company UNIQUE (kit, company),
	constraint check_company_kit check ((not company = 'MyHeritage') or (char_length(kit) = 8))
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.dna_test
    OWNER to admin;


CREATE TABLE public.chromosome_length
(
    chromosome_name_id integer references chromosome_name(chromosome_name_id),
	reference_genome varchar(10) references reference_genome(reference_genome),
	total_chromosome_cm numeric(4, 1) not null,
	PRIMARY KEY (chromosome_name_id, reference_genome)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.chromosome_length
    OWNER to admin;

CREATE TABLE public.dna_test_match
(
    dna_test_match_id integer primary key generated always as identity,
	dna_test_id1 integer not null references dna_test(dna_test_id),
	dna_test_id2 integer not null references dna_test(dna_test_id),
	cm numeric(5, 1) not null,
	segments smallint,
	prop_of_fully_identical_snps numeric(3, 2),
	match_has_been_contacted bit(1) default B'0',
	note varchar(2000),
	CONSTRAINT unique_dna_test_id1_dna_test_id2 UNIQUE(dna_test_id1, dna_test_id2)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.dna_test_match
    OWNER to admin;


CREATE TABLE public.segment_match
(
    segment_match_id integer primary key generated always as identity,
	dna_test_match_id integer not null references dna_test_match(dna_test_match_id),
	chromosome_name_id integer not null references chromosome_name(chromosome_name_id),
	dna_start integer not null,
	dna_end integer not null,
	cm numeric(5, 1) not null,
	snps integer not null,
	CONSTRAINT unique_dna_test_match_id_chromosome_name_id_dna_start UNIQUE(dna_test_match_id, chromosome_name_id, dna_start)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.segment_match
    OWNER to admin;

CREATE TABLE public.ca
(
    ca_id integer primary key generated always as identity,
	dna_test_match_id integer not null references dna_test_match(dna_test_match_id),
	ancestor_id integer not null references ancestor(ancestor_id),
	ca_is_verified bit(1) not null default B'0',
	CONSTRAINT unique_dna_test_match_id_ancestor_id UNIQUE(dna_test_match_id, ancestor_id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.ca
    OWNER to admin;

CREATE TABLE public.segment_ca
(
    segment_ca_id integer primary key generated always as identity,
	segment_match_id integer not null references segment_match(segment_match_id),
	ancestor_id integer not null references ancestor(ancestor_id),
	ca_is_verified bit(1) not null,
	CONSTRAINT unique_segment_match_id_ancestor_id UNIQUE(segment_match_id, ancestor_id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.segment_ca
    OWNER to admin;


