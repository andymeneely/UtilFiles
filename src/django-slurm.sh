#!/bin/sh

#SBATCH --job-name=django-blames	# Name for your job
#SBATCH --comment="Calculating git blames"

#SBATCH --account=vhp	
#SBATCH --partition=tier3		# change to tier3 when ready, usually debug

#SBATCH --output=%x_%j.out		# Output file
#SBATCH --error=%x_%j.err		# Error file

#SBATCH --mail-user=slack:@axmvse	# Slack username to notify
#SBATCH --mail-type=END			# Type of slack notifications to send

#SBATCH --time=0-18:00:00		# 0 days, 12 hour time limit

#SBATCH --nodes=20			# How many nodes to run on
#SBATCH --ntasks=20			# How many tasks per node
#SBATCH --cpus-per-task=1		# Number of CPUs per task
#SBATCH --mem-per-cpu=4g		# Memory per CPU

echo "Script running!"
date

hostname				# Run the command hostname

spack env activate ~/vhp_env

echo "Spack env activated"
date

REPO=~/django

echo "Copying to /dev/shm"

cp -r $REPO /dev/shm

echo "Blame dumping..."
date

FILES=./static_file_lists/django_out_py_only_uniq.txt

FILE_COUNT=$(cat $FILES | wc -l)

for i in $(seq 0 50 $FILE_COUNT); do
  echo "Starting task $i"
  padded_i=$(printf "%02d" $i)
  srun --nodes=1 --ntasks=1 --cpus-per-task=1 --exclusive \
      sqlite3 ~/blames/blame-$SLURM_JOB_NAME-$SLURM_JOB_ID-$padded_i.sqlite \
      ".param set :repo $REPO" \
      ".param set :offset $i" \
      ".read src/create_filepaths.sql" \
      ".import $FILES filepaths" \
      ".read src/blame-dump.sql" & 

done

wait
