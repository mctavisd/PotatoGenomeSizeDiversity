#!/bin/bash
#SBATCH --account=def-gagnoned
#SBATCH --job-name=BEAST_%j
#SBATCH --mail-user=mctavisd@uoguelph.ca
#SBATCH --error=BEAST_%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --time=2-00:00:00
#SBATCH --mem=5G
#SBATCH --output=BEAST_%j.out
#SBATCH --array=1-2

module load beast/2.7.7

packagemanager -add bModelTest
packagemanager -add ORC
packagemanager -add BEASTLabs

beast ./$SLURM_ARRAY_TASK_ID/May5Deanna.xml
