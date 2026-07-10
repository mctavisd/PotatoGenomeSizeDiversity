#Delaney McTavish-McHugh, 2026 May 27
#trimSort: call python script to remove sequences shorter than 25% of the average sequence length from an alignment
# Then, trimAl command removes columns that are at least 75% gaps. 

#NOTE: folder containing sequence alignments must be named "Input". Rename "Output" folder after completion.
#Input folder should contain each alignment to be trimmed in a separate file.

echo "Please provide name of folder containing alignments to process in alignsInput..."
read folderName
echo "Please provide a name for a new output folder for this run (this will be created automatically):"
read newFolder

echo "Checking for MSAFilter.py, trimming short sequences..."
python3 MSAFilter.py ./alignsInput/$folderName

mkdir ./alignsWork/$newFolder

mv ./alignsInput/$folderName/*out.fasta ./alignsWork/$newFolder
mv ./filterStats.txt ./alignsWork/$newFolder

cd ./alignsWork/$newFolder

mkdir ../../cleanAligns/$newFolder
mv ./filterStats.txt ../../cleanAligns/$newFolder

for file in *; do
    if [ -f "$file" ]; then
        trimal -gt 0.25 -in "$file" -out ../../cleanAligns/$newFolder/"${file%.*}_clean.fasta" 
    fi
done

echo "Cleaned alignments located in cleanAligns/$newFolder."