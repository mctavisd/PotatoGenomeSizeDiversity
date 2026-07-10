#!/bin/bash
#SBATCH --account=def-gagnoned
#SBATCH --job-name=tepeArray_%j
#SBATCH --nodes=1
#SBATCH --mail-user=mctavisd@uoguelph.ca
#SBATCH --error=tepeCheck_%j.err
#SBATCH --output=tepeCheck_%j.out
#SBATCH --mail-type=END,FAIL
#SBATCH --time=1-00:00:00
#SBATCH --mem=60G
#SBATCH --array=1-15

module load apptainer

#INITIAL RUN,default
#apptainer run -B /scratch $HOME/scratch/plastomeAssembly/plastImage.sif get_organelle_from_reads.py -1 $HOME/projects/def-gagnoned/mctavisd/Tepe_ZIPs/For_Assembly/$SLURM_ARRAY_TASK_ID/*R1.fastq -2 $HOME/projects/def-gagnoned/mctavisd/Tepe_ZIPs/For_Assembly/$SLURM_ARRAY_TASK_ID/*R2.fastq -s $HOME/scratch/plastomeAssembly/reference/dulcamaraRef_KY863443.fasta -o GO_$SLURM_ARRAY_TASK_ID -k 21,45,65,85,105 -F embplant_pt

#Jan 8th:
apptainer run -B /scratch $HOME/scratch/plastAssemble/ptGAUL_Packs/image.sif get_organelle_from_reads.py -1 $HOME/projects/def-gagnoned/mctavisd/Tepe_ZIPs/For_Assembly/$SLURM_ARRAY_TASK_ID/*_R1.fastq -2 $HOME/projects/def-gagnoned/mctavisd/Tepe_ZIPs/For_Assembly/$SLURM_ARRAY_TASK_ID/*_R2.fastq -s $HOME/scratch/plastAssemble/ptGAUL_Packs/Ref/dulcamaraRef_KY863443.fasta -o GO_Jan9_$SLURM_ARRAY_TASK_ID -k 21,35,45,55,65,75,85,95,105 -F embplant_pt -R 30 --disentangle-time-limit 10000 -J 1 -M 1
