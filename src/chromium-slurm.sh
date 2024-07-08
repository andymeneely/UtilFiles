#!/bin/sh

#SBATCH --job-name=chromium-blames	# Name for your job
#SBATCH --comment="Calculating git blames"

#SBATCH --account=vhp
#SBATCH --partition=debug		# change to tier3 when ready, usually debug

#SBATCH --output=/home/axmvse/logs/%x_%j.out		# Output file
#SBATCH --error=/home/axmvse/logs/%x_%j.err		# Error file

#SBATCH --mail-user=slack:@axmvse	# Slack username to notify
#SBATCH --mail-type=END			# Type of slack notifications to send

#SBATCH --time=0-1:00:00		# DD-HH:MM:SS

#SBATCH --nodes=1			       # How many nodes to run on
#SBATCH --ntasks-per-node=36	 # How many tasks per node - make this roughly the number of CPUs (~36)
#SBATCH --cpus-per-task=1		 # Number of CPUs per task
#SBATCH --mem=40gb		           # Enough for the entire repo

echo "Script running!"
date

hostname				# Run the command hostname

spack env activate ~/vhp_env

echo "Spack env activated"
date

REPO=~/chromium
LOGS_DIR=/home/axmvse/logs

echo "Blame dumping..."
date

FILES=./static_file_lists/chromium_files.txt

# FILE_COUNT=$(cat $FILES | wc -l)
FILE_COUNT=100 # for timing a few runs

for i in $(seq 0 50 $FILE_COUNT); do
  echo "Starting task $i"
  padded_i=$(printf "%05d" $i)
  srun --nodes=1 --ntasks=1 --cpus-per-task=1 --exclusive \
         --output="$LOGS_DIR/$SLURM_JOB_NAME-$SLURM_JOB_ID-$padded_i.out" \
         --output="$LOGS_DIR/$SLURM_JOB_NAME-$SLURM_JOB_ID-$padded_i.err" \
      sqlite3 ~/blames/blame-$SLURM_JOB_NAME-$SLURM_JOB_ID-$padded_i.sqlite \
      ".param set :repo $REPO" \
      ".param set :offset $i" \
      ".read src/create_filepaths.sql" \
      ".import $FILES filepaths" \
      ".read src/blame-dump.sql" &

done

wait
