.echo on

DROP TABLE IF EXISTS filepath_results;

CREATE TABLE filepath_results(
	filepath 				 VARCHAR(1000) PRIMARY KEY,
	is_util					 INTEGER,
	num_authors				 INTEGER,
	num_lines				 INTEGER,
	author_switches          INTEGER,
	author_switches_per_line REAL
);