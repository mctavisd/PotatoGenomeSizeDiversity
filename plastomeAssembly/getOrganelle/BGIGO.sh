#!/bin/bash
#SBATCH --account=def-gagnoned
#SBATCH --job-name=BGIArray_%j
#SBATCH --nodes=1
#SBATCH --mail-user=mctavisd@uoguelph.ca
#SBATCH --error=BGICheck_%j.err
#SBATCH --output=BGICheck_%j.out
#SBATCH --mail-type=END,FAIL
#SBATCH --time=0-10:00:00
#SBATCH --mem=45G
#SBATCH --array=6,8,18,19

# Inititally failed assemblies: --array=6,8,18,19
module load apptainer

#INITIAL RUN,default
apptainer run -B /scratch $HOME/scratch/plastomeAssembly/plastImage.sif get_organelle_from_reads.py -1 $HOME/projects/def-gagnoned/mctavisd/BGI_Delaney/For_Assembly/$SLURM_ARRAY_TASK_ID/*_1.fq -2 $HOME/projects/def-gagnoned/mctavisd/BGI_Delaney/For_Assembly/$SLURM_ARRAY_TASK_ID/*_2.fq -s $HOME/scratch/plastomeAssembly/reference/dulcamaraRef_KY863443.fasta -o GO_BGI_$SLURM_ARRAY_TASK_ID -k 21,45,65,85,105 -F embplant_pt

#DEEPER RUN, for initially failed assemblies
#apptainer run -B /scratch $HOME/scratch/plastomeAssembly/plastImage.sif get_organelle_from_reads.py -1 $HOME/projects/def-gagnoned/mctavisd/BGI_Delaney/For_Assembly/$SLURM_ARRAY_TASK_ID/*_1.fq -2 $HOME/projects/def-gagnoned/mctavisd/BGI_Delaney/For_Assembly/$SLURM_ARRAY_TASK_ID/*_2.fq -s $HOME/scratch/plastomeAssembly/reference/dulcamaraRef_KY863443.fasta -o GO_BGI_$SLURM_ARRAY_TASK_ID -k 21,35,45,55,65,75,85,95,105,125 -F embplant_pt -R 30  --disentangle-time-limit 10000 -J 1 -M 1
