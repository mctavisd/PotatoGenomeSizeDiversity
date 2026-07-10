#!/bin/bash
#SBATCH --account=def-gagnoned
#SBATCH --job-name=kraken2
#SBATCH --nodes=1
#SBATCH --mail-user=mctavisd@uoguelph.ca
#SBATCH --error=kraken2_%j.err
#SBATCH --output=kraken2_%j.out
#SBATCH --mail-type=END,FAIL
#SBATCH --time=0-03:00:00
#SBATCH --mem=200G
#SBATCH --array=1-6,8-10,12-14,16-21,23-30

module load kraken2
module load scipy-stack
mkdir BGI-kraken-$SLURM_ARRAY_TASK_ID
cd BGI-kraken-$SLURM_ARRAY_TASK_ID

kraken2 --db ../../Kraken2 --report BGI-$SLURM_ARRAY_TASK_ID-Report --paired --classified-out BGI-$SLURM_ARRAY_TASK_ID-classSeqs#.fastq --output BGI-$SLURM_ARRAY_TASK_ID.out --unclassified-out BGI-$SLURM_ARRAY_TASK_ID-unclassSeqs#.fastq $HOME/projects/def-gagnoned/mctavisd/BGI_Delaney/For_Assembly/$SLURM_ARRAY_TASK_ID/*_1.fq $HOME/projects/def-gagnoned/mctavisd/BGI_Delaney/For_Assembly/$SLURM_ARRAY_TASK_ID/*_2.fq
cat BGI-$SLURM_ARRAY_TASK_ID-classSeqs_1.fastq BGI-$SLURM_ARRAY_TASK_ID-unclassSeqs_1.fastq > BGI-$SLURM_ARRAY_TASK_ID-1.fastq
cat BGI-$SLURM_ARRAY_TASK_ID-classSeqs_2.fastq BGI-$SLURM_ARRAY_TASK_ID-unclassSeqs_2.fastq > BGI-$SLURM_ARRAY_TASK_ID-2.fastq
#../../KrakenTools/extract_kraken_reads.py -k Tepe-$SLURM_ARRAY_TASK_ID.out -r Tepe-$SLURM_ARRAY_TASK_ID-Report --include-children -t 9046 2 4751 2157 10239 --exclude -s1 Tepe-$SLURM_ARRAY_TASK_ID-1.fastq -s2 Tepe-$SLURM_ARRAY_TASK_ID-1.fastq -o Tepe-F2-$SLURM_ARRAY_TASK_ID-1.fastq -o2 Tepe-F2-$SLURM_ARRAY_TASK_ID-2.fastq
