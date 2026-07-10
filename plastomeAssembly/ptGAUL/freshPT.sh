#!/bin/bash
#SBATCH --account=def-gagnoned
#SBATCH --job-name=freshPT_%j
#SBATCH --nodes=1
#SBATCH --mail-user=mctavisd@uoguelph.ca
#SBATCH --error=freshPT_%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --time=0-00:30:00
#SBATCH --mem=10G
#SBATCH --array=87-95,97,99,101,103,106,108,111,112,117,279-281

apptainer run -B /scratch $HOME/scratch/plastomeAssembly/ptGAUL/plastImage.sif ptGAUL.sh -r $HOME/scratch/plastomeAssembly/reference/dulcamaraRef_KY863443.fasta -l $HOME/projects/def-gagnoned/mctavisd/freshReads/combined/$SLURM_ARRAY_TASK_ID/*.fastq -o ./Outputs