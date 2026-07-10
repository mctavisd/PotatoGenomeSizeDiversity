#!/bin/bash
#SBATCH --account=def-gagnoned
#SBATCH --job-name=respect
#SBATCH --nodes=1
#SBATCH --mail-user=mctavisd@uoguelph.ca
#SBATCH --error=respect_%j.err
#SBATCH --output=respect_%j.out
#SBATCH --mail-type=END,FAIL
#SBATCH --time=0-01:00:00
#SBATCH --mem=30G
#SBATCH --array=87-95,97,99,101,103,106,108,111,112,117,279-281

#gunzip /home/mctavisd/scratch/Kraken2_Work/Extras/Fresh-kraken2-$SLURM_ARRAY_TASK_ID/Extra-*-unclassSeqs_1.fastq.gz
#respect -i /home/mctavisd/scratch/Kraken2_Work/Extras/Fresh-kraken2-$SLURM_ARRAY_TASK_ID/Extra-*-unclassSeqs_1.fastq -o /home/mctavisd/projects/def-gagnoned/mctavisd/RespectExtrasOut/$SLURM_ARRAY_TASK_ID
#gzip /home/mctavisd/scratch/Kraken2_Work/Extras/Fresh-kraken2-$SLURM_ARRAY_TASK_ID/Extra-*-unclassSeqs_1.fastq