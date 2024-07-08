.echo on
.mode column
.headers on
.width auto

.open /home/axmvse/blames/interactive/example-linux.sqlite

DROP VIEW IF EXISTS blame_data_windowed;

------ BLAME DATA SIZE ------
SELECT COUNT(*) FROM blame_data;
-----------------------------

------ BLAME DATA SIZE ------
SELECT * FROM blame_data LIMIT 10;
-----------------------------

------ SPREAD DATA ------
-- Moved this right into an "AS" clause so we don't need to create a view
-- CREATE VIEW blame_data_windowed AS
-- SELECT
--   rowid,
--   filepath,
--   author_email,
--   lag(author_email) OVER win,
--   author_email <> lag(author_email) OVER win AS author_switch
-- FROM blame_data
-- WINDOW win AS (
-- 	PARTITION BY filepath
-- 	ORDER BY line_no
-- 	ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
-- )
-- ORDER BY rowid ASC
; ------------------------

------ SPREAD DATA EXAMPLE ------
SELECT * FROM blame_data_windowed LIMIT 10;
---------------------------------

.width 100 10 10 10 30

------ Authorship Spread Metric ------
SELECT
	filepath,
	COUNT(DISTINCT author_email) as num_authors,
	COUNT(*) AS num_lines,
	SUM(author_switch) AS author_switches,
	SUM(author_switch) * 1.0 / COUNT(*) AS author_switches_per_line,
	filepath LIKE '%util%' AS is_util
FROM (
	SELECT
		rowid,
		filepath,
		author_email,
		lag(author_email) OVER win,
		author_email <> lag(author_email) OVER win AS author_switch
		FROM blame_data
		WINDOW win AS (
			PARTITION BY filepath
			ORDER BY line_no
			ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
		)
		ORDER BY rowid ASC
)
AS blame_data_windowed
GROUP BY filepath;
------------------------------------

