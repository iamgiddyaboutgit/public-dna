begin;
/*
Insert data.
*/

INSERT INTO chromosome_name (chromosome_name)
VALUES ('1'),('2'),('3'),('4'),('5'),('6'),('7'),('8'),('9'),('10'),('11'),('12'),('13'),('14'),('15'),('16'),('17'),('18'),('19'),('20'),('21'),('22'), ('X'), ('Y'), ('MT');

INSERT INTO company (company)
VALUES ('23andMe'),('MyHeritage');

INSERT INTO reference_genome (reference_genome)
VALUES ('GRCh37'), ('GRCh38');

INSERT INTO paternal_haplogroup (paternal_haplogroup)
VALUES ('A'), ('B'), ('C'), ('D'), ('E'), ('F'), ('G'), ('H'), ('I'), ('J'), ('K'), ('M'), ('N'), ('O'), ('P'), ('Q'), ('R'), ('S'), ('T');

INSERT INTO maternal_haplogroup (maternal_haplogroup)
VALUES ('A'), ('B'), ('C'), ('D'), ('F'), ('G'), ('H'), ('I'), ('J'), ('K'), ('L0'), ('L1'), ('L2'), ('L3'), ('L4'), ('L5'), ('M'), ('N'), ('R'), ('T'), ('U'), ('V'), ('W'), ('X'), ('Y'), ('Z');

INSERT INTO chromosome_length (chromosome_name_id, reference_genome, total_chromosome_cm)
VALUES
(1, 'GRCh37', 278.1),
(2, 'GRCh37', 263.4),
(3, 'GRCh37', 224.6),
(4, 'GRCh37', 213.2),
(5, 'GRCh37', 204.0),
(6, 'GRCh37', 193.0),
(7, 'GRCh37', 187.0),
(8, 'GRCh37', 170.2),
(9, 'GRCh37', 168.3),
(10, 'GRCh37', 179.4),
(11, 'GRCh37', 159.5),
(12, 'GRCh37', 173.0),
(13, 'GRCh37', 127.2),
(14, 'GRCh37', 117.1),
(15, 'GRCh37', 131.4),
(16, 'GRCh37', 135.0),
(17, 'GRCh37', 129.5),
(18, 'GRCh37', 119.6),
(19, 'GRCh37', 107.9),
(20, 'GRCh37', 108.1),
(21, 'GRCh37', 62.3),
(22, 'GRCh37', 73.6),
(23, 'GRCh37', 120),
(24, 'GRCh37', 0),
(25, 'GRCh37', 0);

commit;