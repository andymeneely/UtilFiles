
-- To be read into the sqlite database after initializing. See, e.g. ffmpeg-blame-rollup.sh
-- Assumes that blame_data exists from our blame-dump.sql
INSERT INTO filepath_results
SELECT
	filepath,
	filepath LIKE '%util%' AS is_util,
	COUNT(DISTINCT author_email) as num_authors,
	COUNT(*) AS num_lines,
	SUM(author_switch) AS author_switches,
	SUM(author_switch) * 1.0 / COUNT(*) AS author_switches_per_line
FROM (
	SELECT
		rowid,
		filepath,
		author_email,
		lag(author_email) OVER win,
		author_email <> lag(author_email) OVER win AS author_switch
		FROM blame_data_db.blame_data
		WINDOW win AS (
			PARTITION BY filepath
			ORDER BY line_no
			ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
		)
		ORDER BY rowid ASC
)
AS blame_data_windowed
GROUP BY filepath;