#!/bin/bash
#SBATCH --account=def-gagnoned
#SBATCH --job-name=BGIArray_%j
#SBATCH --nodes=1
#SBATCH --mail-user=mctavisd@uoguelph.ca
#SBATCH --error=BGICheck_%j.err
#SBATCH --output=BGICheck_%j.out
#SBATCH --mail-type=END,FAIL
#SBATCH --time=0-07:00:00
#SBATCH --mem=75G
#SBATCH --array=6,8,18,19

# Batch program: runs assembly of plastomes from all reads obtained by BGI simultaneously. Put the directory containing this file in the "Fast-Plast" directory after installing Fast-Plast. Prints outputs into the directory containing this file.

../fast-plast.pl -1 $HOME/projects/def-gagnoned/mctavisd/BGI_Delaney/For_Assembly/$SLURM_ARRAY_TASK_ID/*_1.fq -2 $HOME/projects/def-gagnoned/mctavisd/BGI_Delaney/For_Assembly/$SLURM_ARRAY_TASK_ID/*_2.fq --name FP_Dec15_BGI_$SLURM_ARRAY_TASK_ID --bowtie_index Solanales --coverage_analysis --skip trim
