#!/bin/sh

#SBATCH --job-name=git-gc-chromium	# Name for your job
#SBATCH --comment="running git gc on chromium repo"

#SBATCH --account=vhp
#SBATCH --partition=tier3		# change to tier3 when ready, usually debug

#SBATCH --output=/home/axmvse/logs/%x_%j.out		# Output file
#SBATCH --error=/home/axmvse/logs/%x_%j.err		# Error file

#SBATCH --mail-user=slack:@axmvse	# Slack username to notify
#SBATCH --mail-type=END			# Type of slack notifications to send

#SBATCH --time=0-18:00:00		# DD-HH:MM:SS

#SBATCH --nodes=1			       # How many nodes to run on
#SBATCH --ntasks-per-node=4	 # How many tasks per node - make this roughly the number of CPUs (~36)
#SBATCH --cpus-per-task=1		 # Number of CPUs per task
#SBATCH --mem=50gb		           # Enough for the entire repo

echo "Script running!"
date

hostname				# Run the command hostname

spack env activate ~/vhp_env

echo "Spack env activated"
date

cd ~/chromium

srun --nodes=1 --ntasks=1 --cpus-per-task=1 git gc
