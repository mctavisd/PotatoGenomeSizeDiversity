#!/bin/bash
#SBATCH --account=def-gagnoned
#SBATCH --job-name=kraken2
#SBATCH --nodes=1
#SBATCH --mail-user=mctavisd@uoguelph.ca
#SBATCH --error=kraken2_%j.err
#SBATCH --output=kraken2_%j.out
#SBATCH --mail-type=END,FAIL
#SBATCH --time=0-06:00:00
#SBATCH --mem=200G
#SBATCH --array=1-30

module load kraken2
module load scipy-stack
mkdir Fresh-kraken2-$SLURM_ARRAY_TASK_ID
cd Fresh-kraken2-$SLURM_ARRAY_TASK_ID

gunzip /home/mctavisd/projects/def-gagnoned/mctavisd/LocoExtras/LocoCheck/$SLURM_ARRAY_TASK_ID/*
kraken2 --db ../../Kraken2 --report Extra-$SLURM_ARRAY_TASK_ID-Report --paired --classified-out Extra-$SLURM_ARRAY_TASK_ID-classSeqs#.fastq --output Extra-$SLURM_ARRAY_TASK_ID.out --unclassified-out Extra-$SLURM_ARRAY_TASK_ID-unclassSeqs#.fastq /home/mctavisd/projects/def-gagnoned/mctavisd/LocoExtras/LocoCheck/$SLURM_ARRAY_TASK_ID/*_1* /home/mctavisd/projects/def-gagnoned/mctavisd/LocoExtras/LocoCheck/$SLURM_ARRAY_TASK_ID/*_2*

gzip ./*unclassSeqs*
gzip /home/mctavisd/projects/def-gagnoned/mctavisd/LocoExtras/LocoCheck/$SLURM_ARRAY_TASK_ID/*
