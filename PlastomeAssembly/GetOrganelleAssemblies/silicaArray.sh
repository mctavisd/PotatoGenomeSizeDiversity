#!/bin/bash
#SBATCH --account=def-gagnoned
#SBATCH --job-name=silicaArray_%j
#SBATCH --nodes=1
#SBATCH --mail-user=mctavisd@uoguelph.ca
#SBATCH --error=silCheck_%j.err
#SBATCH --output=silCheck_%j.out
#SBATCH --mail-type=END,FAIL
#SBATCH --time=0-72:00:00
#SBATCH --mem=50G
#SBATCH --array=1,2,3,4,5,6,7,8,9,10

module load apptainer

#INITIAL RUN,default
apptainer run -B /scratch $HOME/scratch/plastAssemble/ptGAUL_Packs/image.sif get_organelle_from_reads.py -u $HOME/projects/def-gagnoned/mctavisd/freshReads/combined/tSilica/$SLURM_ARRAY_TASK_ID/*.fastq -s $HOME/scratch/plastAssemble/ptGAUL_Packs/Ref/dulcamaraRef_KY863443.fasta -o GO_Nov11_$SLURM_ARRAY_TASK_ID -k 21,45,65,85,105 -F embplant_pt

#FINE-TUNING for initially incomplete runs (0, 4-8): 
#apptainer run -B /scratch $HOME/scratch/plastAssemble/ptGAUL_Packs/image.sif get_organelle_from_reads.py -u $HOME/projects/def-gagnoned/mctavisd/freshReads/combined/tSilica/$SLURM_ARRAY_TASK_ID/*.fastq -s $HOME/scratch/plastAssemble/ptGAUL_Packs/Ref/dulcamaraRef_KY863443.fasta -o GO_Oct22_$SLURM_ARRAY_TASK_ID -k 21,45,65,85,105 -F embplant_pt -R 20

#FASTER Assembly for 9, 10
#apptainer run -B /scratch $HOME/scratch/plastAssemble/ptGAUL_Packs/image.sif get_organelle_from_reads.py -u $HOME/projects/def-gagnoned/mctavisd/freshReads/combined/tSilica/$SLURM_ARRAY_TASK_ID/*.fastq -s $HOME/scratch/plastAssemble/ptGAUL_Packs/Ref/dulcamaraRef_KY863443.fasta -o GO_Oct23_fast_$SLURM_ARRAY_TASK_ID --fast -w 0.68 -k 21,65,105 -F embplant_pt
