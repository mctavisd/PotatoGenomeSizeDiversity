#!/bin/bash
#SBATCH --account=def-gagnoned
#SBATCH --job-name=tepeFP_%j
#SBATCH --nodes=1
#SBATCH --mail-user=mctavisd@uoguelph.ca
#SBATCH --error=tepeFP_%j.err
#SBATCH --output=tepeFP_%j.out
#SBATCH --mail-type=END,FAIL
#SBATCH --time=0-96:00:00
#SBATCH --mem=75G
#SBATCH --array=1-15

# Batch program: runs assembly of plastomes from all of Eric Tepe's reads simultaneously. Put the directory containing this file in the "Fast-Plast" directory after installing Fast-Plast. Prints outputs into the directory containing this file.
../fast-plast.pl -1 $HOME/projects/def-gagnoned/mctavisd/Tepe_ZIPs/For_Assembly/$SLURM_ARRAY_TASK_ID/*R1.fastq -2 $HOME/projects/def-gagnoned/mctavisd/Tepe_ZIPs/For_Assembly/$SLURM_ARRAY_TASK_ID/*R2.fastq --name FP_Jan6_Batch_$SLURM_ARRAY_TASK_ID --bowtie_index Solanales --coverage_analysis --skip trim
