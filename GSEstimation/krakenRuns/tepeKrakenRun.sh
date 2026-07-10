#!/bin/bash
#SBATCH --account=def-gagnoned
#SBATCH --job-name=kraken2
#SBATCH --nodes=1
#SBATCH --mail-user=mctavisd@uoguelph.ca
#SBATCH --error=kraken2_%j.err
#SBATCH --output=kraken2_%j.out
#SBATCH --mail-type=END,FAIL
#SBATCH --time=0-01:00:00
#SBATCH --mem=150G
#SBATCH --array=1-15

module load kraken2
module load scipy-stack
mkdir Tepe-kraken-$SLURM_ARRAY_TASK_ID
cd Tepe-kraken-$SLURM_ARRAY_TASK_ID

kraken2 --db ../../Kraken2 --report Tepe-$SLURM_ARRAY_TASK_ID-Report --use-msa-style --paired --classified-out Tepe-$SLURM_ARRAY_TASK_ID-classSeqs#.fastq --output Tepe-$SLURM_ARRAY_TASK_ID.out --unclassified-out Tepe-$SLURM_ARRAY_TASK_ID-unclassSeqs#.fastq $HOME/projects/def-gagnoned/mctavisd/Tepe_ZIPs/For_Assembly/$SLURM_ARRAY_TASK_ID/*_R1.fastq $HOME/projects/def-gagnoned/mctavisd/Tepe_ZIPs/For_Assembly/$SLURM_ARRAY_TASK_ID/*_R2.fastq
cat Tepe-$SLURM_ARRAY_TASK_ID-classSeqs_1.fastq Tepe-$SLURM_ARRAY_TASK_ID-unclassSeqs_1.fastq > Tepe-$SLURM_ARRAY_TASK_ID-1.fastq
cat Tepe-$SLURM_ARRAY_TASK_ID-classSeqs_2.fastq Tepe-$SLURM_ARRAY_TASK_ID-unclassSeqs_2.fastq > Tepe-$SLURM_ARRAY_TASK_ID-2.fastq
#../../KrakenTools/extract_kraken_reads.py -k Tepe-$SLURM_ARRAY_TASK_ID.out -r Tepe-$SLURM_ARRAY_TASK_ID-Report --include-children -t 9046 2 4751 2157 10239 --exclude -s1 Tepe-$SLURM_ARRAY_TASK_ID-1.fastq -s2 Tepe-$SLURM_ARRAY_TASK_ID-1.fastq -o Tepe-F2-$SLURM_ARRAY_TASK_ID-1.fastq -o2 Tepe-F2-$SLURM_ARRAY_TASK_ID-2.fastq
