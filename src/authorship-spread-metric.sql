.echo on
.mode column
.headers on

DROP TABLE IF EXISTS example;
DROP VIEW IF EXISTS example_windowed;

CREATE TABLE example(
	id INTEGER PRIMARY KEY, --sqlite auto increments anyway
	filepath VARCHAR(1000),
	line_num INTEGER,
	author VARCHAR(100)
);

INSERT INTO example(filepath, line_num, author)
VALUES
('file_sam_only', 1, 'sam'),
('file_sam_only', 2, 'sam'),
('file_sam_only', 3, 'sam'),
('file_sam_only', 4, 'sam'),
('file_sam_only', 5, 'sam'),

('frodo_only', 1, 'frodo'),
('frodo_only', 2, 'frodo'),
('frodo_only', 3, 'frodo'),
('frodo_only', 4, 'frodo'),
('frodo_only', 5, 'frodo'),

('frodo_sam_separate', 1, 'frodo'),
('frodo_sam_separate', 2, 'frodo'),
('frodo_sam_separate', 3, 'frodo'),
('frodo_sam_separate', 4, 'sam'),
('frodo_sam_separate', 5, 'sam'),

('frodo_sam_interweave', 1, 'frodo'),
('frodo_sam_interweave', 2, 'sam'),
('frodo_sam_interweave', 3, 'frodo'),
('frodo_sam_interweave', 4, 'sam'),
('frodo_sam_interweave', 5, 'frodo'),

('frodo_sam_gollum', 1, 'frodo'),
('frodo_sam_gollum', 2, 'sam'),
('frodo_sam_gollum', 3, 'frodo'),
('frodo_sam_gollum', 4, 'sam'),
('frodo_sam_gollum', 5, 'gollum'),
('frodo_sam_gollum', 6, 'gollum'),
('frodo_sam_gollum', 7, 'gollum'),
('frodo_sam_gollum', 8, 'gollum')
;

SELECT * FROM example;

------ Number of authors ------
SELECT filepath, COUNT(DISTINCT author) as num_authors
FROM example
GROUP BY filepath
; -----------------------------

------ Authorship Spread ------
CREATE VIEW example_windowed AS
SELECT
  id,
  filepath,
  author,
  lag(author) OVER win,
  author <> lag(author) OVER win AS author_switch
FROM example
WINDOW win AS (
	PARTITION BY filepath
	ORDER BY line_num
	ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
)
ORDER BY id ASC
; -----------------------------

------ Authorship Spread Data ------
SELECT * FROM example_windowed;
; ----------------------------------

------ Authorship Spread Metric ------
SELECT
	filepath,
	COUNT(DISTINCT author) as num_authors,
	COUNT(*) AS num_lines,
	SUM(author_switch) AS author_switches,
	SUM(author_switch) * 1.0 / COUNT(*) AS author_switches_per_line
FROM example_windowed
GROUP BY filepath
;
------ Authorship Spread Metric ------


