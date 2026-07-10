#!/bin/bash
#SBATCH --account=def-gagnoned
#SBATCH --job-name=kraken2_build
#SBATCH --nodes=1
#SBATCH --mail-user=mctavisd@uoguelph.ca
#SBATCH --error=kraken2fullF.err
#SBATCH --output=kraken2fullF.out
#SBATCH --mail-type=END,FAIL
#SBATCH --time=5-00:00:00
#SBATCH --mem=300G

module load kraken2

kraken2-build --download-taxonomy --db Kraken2
kraken2-build --download-library archaea --db Kraken2
kraken2-build --download-library bacteria --db Kraken2
kraken2-build --download-library fungi --db Kraken2
kraken2-build --download-library human --db Kraken2
kraken2-build --download-library plasmid --db Kraken2
kraken2-build --download-library UniVec_Core --db Kraken2
kraken2-build --download-library viral --db Kraken2

kraken2-build --build --db Kraken2
