#!/bin/bash

BLAMES_SQLITES=~/blames/good/ffmpeg
ROLLUP_DB=blame_results/ffmpeg.sqlite

sqlite3 $ROLLUP_DB ".read src/create_rollup_schema.sql"

for db_sqlite in $BLAMES_SQLITES/*.sqlite
do
	echo "Loading: $db_sqlite"
	sqlite3 $ROLLUP_DB \
		"ATTACH DATABASE '$db_sqlite' AS 'blame_data_db'; " \
		".read ./src/authorship-spread.sql" \
		"DETACH DATABASE 'blame_data_db'; "
done

sqlite3 $ROLLUP_DB \
	".echo on" \
    "SELECT COUNT(*) FROM filepath_results"