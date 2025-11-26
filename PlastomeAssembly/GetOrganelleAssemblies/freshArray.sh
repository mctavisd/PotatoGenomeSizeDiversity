#!/bin/bash
#SBATCH --account=def-gagnoned
#SBATCH --job-name=freshArray_%j
#SBATCH --nodes=1
#SBATCH --mail-user=mctavisd@uoguelph.ca
#SBATCH --error=freshCheck_%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --time=0-168:00:00
#SBATCH --mem=150G
#SBATCH --array=87,88,89,90,91,92,93,94,95,97,98,99,101,103,106,108,111,112,117,279,280,281

module load apptainer
apptainer run -B /scratch $HOME/scratch/plastAssemble/ptGAUL_Packs/image.sif get_organelle_from_reads.py -u $HOME/projects/def-gagnoned/mctavisd/freshReads/combined/$SLURM_ARRAY_TASK_ID/*.fastq -s $HOME/scratch/plastAssemble/ptGAUL_Packs/Ref/dulcamaraRef_KY863443.fasta -o GO_Nov7_fast_$SLURM_ARRAY_TASK_ID -k 21,45,65,85,105 -F embplant_pt