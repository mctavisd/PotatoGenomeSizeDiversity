#!/bin/bash
#SBATCH --account=def-gagnoned
#SBATCH --job-name=respect
#SBATCH --nodes=1
#SBATCH --mail-user=mctavisd@uoguelph.ca
#SBATCH --error=respect_%j.err
#SBATCH --output=respect_%j.out
#SBATCH --mail-type=END,FAIL
#SBATCH --time=0-06:00:00
#SBATCH --mem=30G
#SBATCH --array=96,105,110,113,289-295

gunzip /home/mctavisd/scratch/KrakenRoughs/MayBGI/MayBGI-kraken2-$SLURM_ARRAY_TASK_ID/$SLURM_ARRAY_TASK_ID-unclassSeqs_1.fastq.gz
#respect -i /home/mctavisd/scratch/KrakenRoughs/MayBGI/MayBGI-kraken2-$SLURM_ARRAY_TASK_ID/$SLURM_ARRAY_TASK_ID-unclassSeqs_1.fastq -o /home/mctavisd/projects/def-gagnoned/mctavisd/MayBGIRespect/$SLURM_ARRAY_TASK_ID
gzip /home/mctavisd/scratch/KrakenRoughs/MayBGI/MayBGI-kraken2-$SLURM_ARRAY_TASK_ID/$SLURM_ARRAY_TASK_ID-unclassSeqs_1.fastq