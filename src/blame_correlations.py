from scipy import stats
from numpy import median
import sqlite3

conn = sqlite3.connect("blame_results/ffmpeg.sqlite")
results = conn.cursor().execute("""
	SELECT filepath, is_util, num_authors, num_lines, author_switches, author_switches_per_line
		FROM filepath_results WHERE author_switches IS NOT NULL
""").fetchall()
conn.close()


filepath_column          = list(map(lambda x: x[0], results))
is_util_column           = list(map(lambda x: x[1], results))
num_authors_column       = list(map(lambda x: x[2], results))
num_lines_column         = list(map(lambda x: x[3], results))
author_switches_column   = list(map(lambda x: x[4], results))
author_switches_per_line = list(map(lambda x: x[5], results))

AUTHORS_INDEX=2
LINES_INDEX=3
AUTHOR_SWITCHES_INDEX=4
AUTHOR_SWITCHES_PER_LINE_INDEX=5

print("--SUMMARY STATS--")
print(f"describe(is_util): {stats.describe(is_util_column)}" )
print(f"describe(num_authors_column): {stats.describe(num_authors_column)}" )
print(f"describe(num_lines): {stats.describe(num_lines_column)}" )
print(f"describe(author_switches): {stats.describe(author_switches_column)}" )
print(f"describe(author_switches_per_line): {stats.describe(author_switches_per_line)}" )

def mww_analyze_medians(column_a, column_b):
	print(f"util data: {stats.describe(column_a)}")
	print(f"util median: {median(column_a)}")
	print(f"non-util data: {stats.describe(column_b)}")
	print(f"non-util median: {median(column_b)}")
	print(f"Mann-Whitney U (two sided): {stats.mannwhitneyu(column_a, column_b, alternative='two-sided')}")
	print(f"Mann-Whitney U (a<b): {stats.mannwhitneyu(column_a, column_b, alternative='less')}")

print("-- author_switches_per_line: util vs non_util  --")
sw_per_line_util_data = list(map(lambda x: x[AUTHOR_SWITCHES_PER_LINE_INDEX], list(filter(lambda row: row[1]==1, results))))
sw_per_line_non_util_data = list(map(lambda x: x[AUTHOR_SWITCHES_PER_LINE_INDEX], list(filter(lambda row: row[1]==0, results))))
mww_analyze_medians(sw_per_line_util_data, sw_per_line_non_util_data)

print("-- author_switches_total: util vs non_util  --")
sw_util_data = list(map(lambda x: x[AUTHOR_SWITCHES_INDEX], list(filter(lambda row: row[1]==1, results))))
sw_non_util_data = list(map(lambda x: x[AUTHOR_SWITCHES_INDEX], list(filter(lambda row: row[1]==0, results))))
mww_analyze_medians(sw_util_data, sw_non_util_data)

print("-- authors_total: util vs non_util  --")
authors_util_data = list(map(lambda x: x[AUTHORS_INDEX], list(filter(lambda row: row[1]==1, results))))
authors_non_util_data = list(map(lambda x: x[AUTHORS_INDEX], list(filter(lambda row: row[1]==0, results))))
mww_analyze_medians(authors_util_data, authors_non_util_data)

print("-- lines_total: util vs non_util  --")
lines_util_data = list(map(lambda x: x[LINES_INDEX], list(filter(lambda row: row[1]==1, results))))
lines_non_util_data = list(map(lambda x: x[LINES_INDEX], list(filter(lambda row: row[1]==0, results))))
mww_analyze_medians(lines_util_data, lines_non_util_data)



