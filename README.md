# Summer 2026: Delaney McTavish-McHugh, Master's Thesis in Integrative Biology, University of Guelph

## "Is genome size diversity in the Pinnatifida clade (Solanum L.): associated with climate?"

### NOTE: This is unfinished; all required scripts are present, but input files are required and some scripts requiree adjustment to different directories. Steps 5-7 are complete and reproducible.

### FILE INDEX:

- analyses: R scripts used for analyses of genome size and climate.
  - ancReconstruction.R: Script for estimation of phylogenetic signal and ancestral reconstruction of genome size.
  - PGLS.R: Script for running Phylogenetic Generalized Least Squares analyses.
  - seqEstimatesComp.R: Script for comparing sequence-based genome size estimates to flow cytometry.

- climScripts: Scripts used to clean occurrence data and assign and/or calculate climatic variables.
  - 01_occCleaning.R: Removes uncertain or duplicate occurrence records from occurrence dataset and performs spatial filtering.
  - 02_climateAssignment.R: Assigns values for climatic variables to the clean occurrence dataset and calculates species-level means for each variable.
  - 03_climateMeansPCA.R: Performs Principal Component Analysis on species-level mean climatic variables, to examine correlations and prune extraneous variables.
  - 04_Niche_Assign.R: Assign niche breadth values to the variables kept after trimming extraneous ones.
  - 05_nicheCorr.R. Calculates Pearson's correlation coefficients between each mine and niche variable.

- GSEstimation: Files used for sequence-based genome size estimation.
  - kraken2: Script for building the required Kraken2 library, krakenBuild.sh.
  - krakenRuns: Script files for running Kraken2 on required files.
  - BGIKrakenRun.sh: Filters BGI sequences.
    - mayExtraKrakenRun.sh: Filters extra  BGI sequences for comparison to flow cytometry.
    - tepeKrakenRun.sh: Filters sequences sourced from Eric Tepe.
  - LocoGSE: Scripts for generating genome size estimates vie LocoGSE.
    - inputLists: Files containing batches of jobs to run.
    - Output: Outputs of completed jobs.
  - Respect: Scripts for generating genome size estimates via RESPECT.
	- BGIRespect.sh: Generates RESPECT estimates for BGI files.
	- extrasRespect.sh: Generates RESPECT estimates for extra  BGI sequences for comparison to flow cytometry.
    - tepeRespect.sh: Generates RESPECT estimates for sequences sourced from Eric Tepe.
  - respectENV: The virtual environment required to run RESPECT. Put this in your HOME directory.
	
- inputs: Input files.
  - chelsa: CHELSA BIOCLIM+ climate variable maps, plus Wilson & Jetz's mean and SD cloud cover maps.
  - filterFiles: Lists used to rename species or samples during data processing and analyses.
	- clades.csv: List of subclades to which each species in the dataset belongs. Chromosome numbers for each represented species are listed. Petota subclasses (1+2, 3, 4 North, and 4 South) are also listed for Petota species.
	- cytotypes.csv: List of Petota species with or without multiple cytotypes. Known policy levels (2 = diploid, 3 = triploid, etc.) are listed.
  	- FCM.csv: Mean, minimum, maximum and standard deviation of flow cytometry-based genome size estimates organized by species (or cytotype, if available).
	- keepOutl.csv: Species with small or sporadic ranges, for which trimming outliers removed likely valid occurrences.
  	- LocoGSE.csv: Mean, minimum, maximum and standard deviation of genome size estimates produced by LocoGSE, organized by species.
   	- occsToRemove.csv: Extra occurrences to remove that weren't caught by the coded filter functions. Reasons for cutting each occurrence are listed.
    - speciesList.csv: List of species for which genome size estimates are available.
  - inputClean: Intermediary files between raw inputs and outputs.
    - cleanData_xoutl.csv: Cleaned occurrence data with outliers removed.
  	- cleanData.csv: Cleaned occurrence data with outliers included.
    - cleanDataPreSpatial.csv: Cleaned occurrence data with occurrences removed for all but the species in keepOutl.csv. This is the dataset used for spatial filtering.
    - climateOccs.csv: Occurrences with climate values assigned.
    - climateOccsWithSpecies.csv: Occurrences with climate values and species-level sample sizes assigned.
    - DF_results_all_spatial_filtering.csv: Clean occurrence data post-spatial filtering.
    - nicheMeansSummary.csv: Completed climate dataset with mean per-cpecies climate values and niche breadths. Dataset used for PGLS.
    - summaryClimValues.csv: Per-species mean climate values. Used for Principal Component Analysis.
  - inputRaw: Raw input files.
    - BEAST2.tree: Bayesian phylogenetic tree constructed using BEAST2, with branch support.
    - IQ3.fasta.contree: Maximum likelihood phylogenetic tree constructed using IQTREE-3, with branch support.
    - locoRespectCheck.csv: Genome size dataset used for linear regression analysis. Includes estimates from LocoGSE, RESPECT, and flow cytometry.
    - locoRespectGSE.csv: Genome size estimates from LocoGSE and RESPECT, used for making boxplots.
    - mergeOcc.csv: CSV file containing raw occurrence points from Särkinen (CITE) and Gagnon 2022.
  - labels: More readable labels for the phylogenetic trees.
  	- newTipLabels.csv: New tree tip labels for tree trimmed to only required tips for full-dataset PGLS models.
   	- newTipLabelsDiploids.csv: New tree tip labels for tree trimmed to only required tips for diploid-only PGLS models.
    - newTipLabelsFull.csv: New tree tip labels for the full Bayesian tree.
    - newTipLabelsFullIQ.csv:  New tree tip labels for the full maximum likelihood tree.

- outputs: Output files.
  - ancRec: Ancestral reconstruction outputs.
  - diploid2C.CIs.csv: 95% confidence intervals of ancestral reconstruction of diploid-only holoploid dataset.
  - diploid2CEstimates.csv: Mean genome size estimates of ancestral reconstruction of diploid-only holoploid dataset.
  - diploidTreeNodeMap.pdf: Map of internal nodes for diploid-only dataset tree.
  - Full1Cx.CIs.csv: 95% confidence intervals of ancestral reconstruction of full monoploid dataset.
  - Full1CxEstimates.csv: Mean genome size estimates of ancestral reconstruction of full monoploid dataset.
  - Full2C.CIs.csv: 95% confidence intervals of ancestral reconstruction of full holoploid dataset.
  - Full2CEstimates.csv: Mean genome size estimates of ancestral reconstruction of full holoploid dataset.
  - fullTreeNodeMap.pdf: Map of internal nodes for full dataset tree.
  - lambdaDiploid2C.rds: Results of calculation of Pagel's lambda for diploid-only holoploid dataset.
  - lambdaFull1Cx.rds: Results of calculation of Pagel's lambda for full monoploid dataset.
  - lambdaFull2C.rds: Results of calculation of Pagel's lambda for full holoploid dataset.
  - BEASToutputsBackup: Results of the BEAST2 runs used for the final Bayesian tree.
    - 1
	- 2
  - climate: Results of calculations of climatic variables.
    - climateCorrs.csv: Pearson's correlation coefficients for all climatic variables.
    - climateCorrs.xlsx: Cleaned Pearson's correlation coefficients for all climatic variables; kept variables are in green, while extraneous variables are red.
    - GSAssigned.csv: Occurrence data with genome sizes and niches assigned.
    - niche_ranges.csv: Species-level niche breadth variables.
    - nicheMeanCorrs.csv: Pearsons' correlation coefficients of niche breadth and mean values.
    - noOccsPerSpecies.csv: Final sample sizes of occurrences per species.
  - figures:
    - 1Cx_occMap.pdf: Map of occurrences, coloured by monoploid genome size.
    - 2C_occMap.pdf: Map of occurrences, coloured by monoploid genome size.
    - ancRecFigure.pdf: Ancestral reconstructions, from left to right: holoploid genome size of full dataset, monoploid genome size of full dataset, holoploid genome size of diploid only dataset.
    - BayesianTreeFull.pdf: Full BEAST2 plastome tree.
    - climateBoxes: Occurrence data boxplots of the 5 climate values organized phylogenetically by species.
    - genomeSizesBoxplot.pdf: Boxplots of species-level holoploid and monoploid genome sizes.
    - locoRespectBoxPlots.pdf: Species-level holoploid genome size estimates produced by LocoGSE (upper) and RESPECT (lower).
    - locoRespectCompLines.pdf: Linear models comparing LocoGSE and RESPECT to flow cytometry, for full datasets (top) and diploid only datasets (bottom).
    - IQTreeFull.pdf: Full BEAST2 plastome tree.
  - flags: Lists of occurrences flagged and removed by each step of CoordinateCleaner.
    - Solanum_cap_flag.csv/pdf: Occurrences in or near capitals.
    - Solanum_cen_flag.csv/pdf: Occurrences in country centroids.
    - Solanum_dupl_flag.csv/pdf: Duplicate occurrences.
    - Solanum_inst_flag.csv/pdf: Occurrences in or near institutions.
    - Solanum_outl_flag.csv/pdf: Outlier occurrences.
  - IQoutputsBackup: Backup of the IQTREE3 run used for the final maximum likelihood tree.
  - locoRespectComp: Results of linear regression analyses of comparisons between LocoGSE/RESPECT and flow cytometry.
  - occCleaning: Results of occurrence cleaning.
    - occBySpecies: Species-level occurrences.
    - data: Occurrence data csv files.
    - maps: Species-level occurrence maps.
    - preSpatialFilterOccs: species-level occurrence datasets before the spatial filtering step.
      - spatial_filtering_results.csv: Printed console output of spatial filtering.
  - PGLS: Results of Phylogenetic Generalized Least Squares analyses.
    - PGLSDiploid2Ccombo.rds: Results of PGLS on diploid-only holoploid dataset, with combined niche breadth.
    - PGLSDiploid2Cind.rds: Results of PGLS on diploid-only holoploid dataset, with individual niche breadths.
    - PGLSFull1Cxcombo.rds: Results of PGLS on full monoploid dataset, with combined niche breadth.
    - PGLSFull1Cxind.rds: Results of PGLS on full monoploid dataset, with individual niche breadths.
    - PGLSFull2Ccombo.rds: Results of PGLS on full holoploid dataset, with combined niche breadth.
    - PGLSFull2Cind.rds: Results of PGLS on full holoploid dataset, with individual niche breadths.

- phyloBuild: Scripts for phylogenetic reconstruction.
  - Bayesian: BEAST2 Files, for Bayesian phylogeny.
    - 1: Storage for 1st run.
    - 2: Storage for 2nd run.
	- beast2.sh: Shell script used to execute the two runs.
	- inputAligns: Alignments of coding sequences, intergenic sequences, and introns used in the BEAST2 xml input file.
  - ML: IQTREE3 files, for maximum likelihood phylogeny.
  	- FinalIQ.fasta: Input FASTA file used for IQTREE3. Contains full-plastome alignment sequence.
    - iqtree.sh: File for executing the IQTREE3 run.

- plastEnv: Stores files required to create an apptainer image for running ptGAUL, GetOrganelle, and IQTREE3.
  - plastEnv.yml: Environment file.
  - plastImage.def: Image definition file.
	
- plastomeAssembly: Files used for plastome assembly.
  - fastPlast: Scripts for running Fast-Plast analyses, and a copy of Fast-Plast files.
  - getOrganelle: Scripts for running GetOrganelle jobs.
  - ptGAUL: Script for running ptGAUL jobs
  - reference: The reference plastome, Solanum dulcamara ().

- seqAlignTrim: Scripts for cleaning multiple sequence alignment files used for phylogenetic reconstruction.
  - alignsInput: Input folders for alignment files. Includes raw alginments for coding, intergenic, and intron sequences, and the fintergenic sequences run through ambigFilter.sh (filteredIntergenic).
  - alignsWork: Intermediate files after the first step of trimSort, but before the final trimAL step.
  - ambigFilter.sh: Shell script file for cleaning ambiguously aligned sequences in intergenic sequences.
  - cleanAligns: Cleaned alignments, ready for merging. Outputs of trimSort.sh.
  - MSAFilter.py: Python script called by trimSort.sh; removes sequences shorter than 25% of the average length of theri respective alignments.
  - trimSort.sh: Cleaning script for all alignments. Removes short sequences and columns consisting over 75% of gaps.

### STEPS FOR PROCESSING:
All R Scripts were tested using R Version 4.5.2. Set the working directory to this "GitHub" folder for all R scripts.

1. SEQUENCE-BASED GENOME SIZE ESTIMATION:
	1. CONTAMINATION FILTERING:
		1. Install Kraken2 on HPC.
		2. If no library is created, create a new library: make an expanded library using krakenBuild.sh.
	2. LocoGSE
		*For specimens with over 10% of reads classified as contaminants, use filtered unclassified reads for estimation. Otherwise, unfiltered reads are preferred*\
		1. Install LocoGSE on a local computer (a lab computer with a lot of processing power is best). ~200GB free storage space is recommended for intermediate processing files during estimations. Use WSL if using Windows.
		2. Install micromamba and LocoGSE on local computer:
			1. Run the command " "${SHELL}" <(curl -L https://micro.mamba.pm/install.sh) ", then reboot WSL.
			2. Run the command "git clone https://github.com/institut-de-genomique/LocoGSE.git" to install LocoGSE, then move to the LocoGSE directory.
		3. To activate LocoGSE, run "micromamba activate LocoGSE". 
		4. To run LocoGSE, run the command "LocoGSE --list_fastq <inputFile.txt> --output <outputDirectory> -f Solanaceae --cleaning_output" in the LocoGSE directory. Replace <inputFile.txt> with an input file from inputLists and <outputDirectory> with the desired output. You do not need to create the output directory; LocoGSE will do this for you.
		5. Type "micromamba deactivate" to deactivate the environment when completed.

	3. RESPECT
		*Use filtered reads (unclassified) from Kraken2 for RESPECT*
		1. On HPC, run the following code lines to prepare and activate the RESPECT environment; you will need a Gurobi license for this. You'll need to contact technical support for help with this on Digital Alliance.
			1. module load StdEnv/2020 python/3.8 gurobi/10.0.2 jellyfish scipy-stack/2020b
			2. virtualenv --no-download ~/respectENV
			3. source ~/respectENV/bin/activate
		2. Run all scripts in the RESPECT folder.

2. PLASTOME ASSEMBLY AND ANNOTATION:
	*Install all assembly programs on HPC. GetOrganelle (https://github.com/kinggerm/getorganelle) and ptGAUL (https://github.com/Bean061/ptgaul) require an apptainer image; instructions for building one that can run both are shown below (step A).
	1. Copy the plastomeAssembly directory to your scratch folder. In the plastomeAssembly directory, run the following commands on HPC: this will build the required Apptainer image plastImage.sif.
		module load apptainer
  		APPTAINER_BIND=' ' apptainer build plastImage.sif plastImage.def
	2. For long-read sequences:
		1. In the getOrganelle directory, run batch script freshGO.sh. Rerun with the "fast run" uncommented for initially failed runs.
		2. In the ptGAUL directory, run batch script freshPT.sh. Rerun with adjusted minimum read lengths for initially unsuccessful runs if necessary.
	3. For short-read sequences:
		1. In the getOrganelle directory, run batch scripts BGIGO.sh and tepeGO.sh.
		2. Install Fast-Plast (https://github.com/mrmckain/Fast-Plast) and getOrganelle on HPC, or use premade Fast-Plast directory, then run BGI_FP.sh and Tepe_FP.sh.
	4. Quality checking:
		1. Download completed plastomes. Annotate each plastome using GeSeq (https://chlorobox.mpimp-golm.mpg.de/geseq.html), setting the reference sequence as Solanum dulcamara (NC_035724.1). load annotated plastome into Geneious Prime. 
		2. Download aligned reads from plastome assembly run and map back onto plastome in Geneious to check for significant gaps. Also check that ssc is in the correct orientation (with the complete ycf1 copy on the right end of the ssc).
		3. For failed assemblies:
			1. Annotate the recovered contigs using GeSeq.
			2. If all regions are recovered, align in Geneious prime, cut out all but one of overlapping sequences, and combine into remaining regions into one sequence.
			3. Perform step 1.C.ii. to check for errors or gaps in assembly coverage.

3. PLASTOME ALIGNMENT AND TRIMMING:
	1. In Geneious, run MAFFT. Check alignment, annotate consensus sequence with each coding region (exons), introns, and intergenic sequences, then transfer those annotations to each sequence. Delete the 2nd copy of the IRR region, keeping the ycf1 gene.
	2. Copy and paste each fragment of the plastome into one of three separate folders (coding regions, introns, intergenic regions). Export each folder separately as a batch of FASTA files. Put these folders in the seqAlignTrim directory.
	3. For intergenic sequences, run the shell script ambigFilter.sh (on Mac, run "zsh ambigFilter.sh" in the terminal in the seqAlignTrim directory). Make sure you have trimAL (https://trimal.readthedocs.io/en/latest/) functioning on your computer beforehand.
	4. For all sequence folders, including the output folder from step C., run trimSort.sh on each folder separately.
	5. Load cleaned alignments back into Geneious. Combine each folder's sequences into one.
	6. Combine the combined sequences from each folder into one, full-plastome sequence.
	7. Export the full-plastome sequence and the intron, coding, and intergenic sequences as fasta files.

4. PHYLOGENETIC RECONSTRUCTIONS:
	1. Maximum Likelihood Tree:
		1. On HPC, run iqTree.sh.
	2. Bayesian Tree:
		1. Download BEAST2 and associated package BEAUTi on local computer.
		2. Create a new .xml file in BEAUTi. After choosing "Import Alignment", load in the 3 FASTA files in Bayesian/inputAligns. Link tree and clock models.
		3. In the Site Model tab, set the site model to BEAST Model Test for all three partitions. Estimate mutation rates for all.
		4. In the Clock model tab, set the clock model to "optimized relaxed clock".
		5. In the Priors tab, set Tree:t:Tree to a Birth Death Model. Add two MRCA priors:
			1. The outgroup prior: set the S. Dulcamara plastome separate from the rest, checking the "monophyletic" box. Set the Prior to Normal, with a mean of 36.03 and a sigma of 5.5.
			2. The Tomato-Etuberosum prior: Sets an estimated ate for the last common ancestor of the Tomato clade (Lycopersicon) and Etuberosum. Set S. palustre and S. pimpinellifolium together (DO NOT set as monophyletic). Set the prior to Normal, with a mean of 14.15 and a sigma of 3.6.
		6. In the MCMC tab, set the chain length to 20 000 000 and the pre burnin to 2000000. Set the trace log, screen log and the tree log to log every 2000 trees.
		7. Upload xml to HPC, putting 2 copies in Bayesian/1 and Bayesian/2. Run BEAST2.sh to start 2 runs simultaneously.
		8. After completion of both runs, download the log and tree files from each run (rename to keep track of which is which). Open both log files in Tracer and check the "Combined" trace file to confirm ESSs are satisfactory.
		9. Use logCombiner to combine the tree files from both runs into one. Set the Burnin to 0; the pre-burnin already removed the burn-in period.
		10. Use treeAnnotator to convert tree file into a consensus tree. Set the Burnin to 0, the target tree type to MAP (CCD0), and node heights to mean heights.

5. COMPARING SEQUENCE-BASED ESTIMATES AND FLOW CYTOMETRY ESTIMATES:
	1. Run seqEstimatesComp.R.

6. CALCULATING CLIMATIC NICHES:
	1. Run all scripts in the climScripts folder in numerical order.

7. PERFORMING FINAL ANALYSES:
	1. Run ancReconstruction.R and PGLS.R (in either order; they are independent of each other).

### REFERENCES:
