#!/bin/bash
#SBATCH --account=def-gagnoned
#SBATCH --job-name=freshGO_%j
#SBATCH --nodes=1
#SBATCH --mail-user=mctavisd@uoguelph.ca
#SBATCH --error=freshGO_%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --time=0-168:00:00
#SBATCH --mem=150G
#SBATCH --array=87-95,97,99,101,103,106,108,111,112,117,279-281

# array=91,97,99,101,103,106,108,111,279; failed initial runs. Replace sbatch array above with this for the fast run.

module load apptainer

#INITIAL RUN,default
apptainer run -B /scratch $HOME/scratch/plastomeAssembly/plastImage.sif get_organelle_from_reads.py -u $HOME/projects/def-gagnoned/mctavisd/freshReads/combined/$SLURM_ARRAY_TASK_ID/*.fastq -s $HOME/scratch/plastomeAssembly/reference/dulcamaraRef_KY863443.fasta -o GO_$SLURM_ARRAY_TASK_ID -k 21,45,65,85,105 -F embplant_pt

#FAST RUN for initial failures
#apptainer run -B /scratch $HOME/scratch/plastomeAssembly/plastImage.sif get_organelle_from_reads.py -u $HOME/projects/def-gagnoned/mctavisd/freshReads/combined/$SLURM_ARRAY_TASK_ID/*.fastq -s $HOME/scratch/plastomeAssembly/reference/dulcamaraRef_KY863443.fasta -o GO_fast_$SLURM_ARRAY_TASK_ID -k 21,45,65,85,105 --fast -F embplant_pt
