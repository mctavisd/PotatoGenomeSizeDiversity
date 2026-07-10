#!/bin/bash
#SBATCH --account=def-gagnoned
#SBATCH --job-name=iqTree_%j
#SBATCH --nodes=1
#SBATCH --mail-user=mctavisd@uoguelph.ca
#SBATCH --error=iqTree_%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --time=7-00:00:00
#SBATCH --mem=10G

module load apptainer
apptainer run ../../plastEnv/plastImage.sif iqtree3 -s ./FinalIQFast.fasta -b 1000
