echo "Please provide name of raw intergenic sequences folder located in alignsInput: "
read folderName
echo "Checking $folderName..."

cd ./alignsInput/$folderName
mkdir ../filteredIntergenic
echo "Trimming ambiguously aligned sequences..."

for file in *; do
    if [ -f "$file" ]; then
        trimal -in "$file" -out "../filteredIntergenic/${file%.*}_filtered.fasta" -strict
    fi
done