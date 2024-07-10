#!/bin/sh

#SBATCH --job-name=sloc-scc		# Name for your job
#SBATCH --comment="Count lines of code on many repos"

#SBATCH --account=vhp
#SBATCH --partition=tier3		# change to tier3 when ready, usually debug

#SBATCH --output=/home/axmvse/logs/%x_%j.out		# Output file
#SBATCH --error=/home/axmvse/logs/%x_%j.err		# Error file

#SBATCH --mail-user=slack:@axmvse	# Slack username to notify
#SBATCH --mail-type=END			# Type of slack notifications to send

#SBATCH --time=0-18:00:00		# 0 days, 12 hour time limit

#SBATCH --nodes=1			# How many nodes to run on
#SBATCH --ntasks=1			# How many tasks per node
#SBATCH --cpus-per-task=1		# Number of CPUs per task
#SBATCH --mem=2g			# Memory per node

echo "Script running!"
date

hostname				# Run the command hostname

spack env activate ~/vhp_env

echo "Spack env activated"
date


cat ./github_repos/repo_list.txt | while read repo
do
    echo "Cloning $repo"
    rm -rf ~/github-working/working-dir
    git clone ~/github/$repo.git ~/github-working/working-dir
    echo "scc'ing $repo"
    ~/scc/scc --format sql-insert --by-file --sql-project "$repo" ~/github-working/working-dir | sqlite3 ~/sloc/github-sloc.sqlite
done

wait
