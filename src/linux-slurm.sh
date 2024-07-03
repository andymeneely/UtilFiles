#!/bin/sh

#SBATCH --job-name=linux-blames	# Name for your job
#SBATCH --comment="Calculating git blames"

#SBATCH --account=vhp	
#SBATCH --partition=tier3		# change to tier3 when ready, usually debug

#SBATCH --output=%x_%j.out		# Output file
#SBATCH --error=%x_%j.err		# Error file

#SBATCH --mail-user=slack:@axmvse	# Slack username to notify
#SBATCH --mail-type=END			# Type of slack notifications to send

#SBATCH --time=0-18:00:00		# 0 days, 12 hour time limit

#SBATCH --nodes=5			# How many nodes to run on
#SBATCH --ntasks-per-node=36	 	# How many tasks per node
#SBATCH --cpus-per-task=1		# Number of CPUs per task
#SBATCH --mem-per-cpu=4g		# Memory per CPU

echo "Script running!"
date

hostname				# Run the command hostname

spack env activate ~/vhp_env

echo "Spack env activated"
date

REPO=~/linux
LOGS_DIR=/home/axmvse/logs

echo "Blame dumping..."
date

FILES=./static_file_lists/linux_files.txt

FILE_COUNT=$(cat $FILES | wc -l)

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
