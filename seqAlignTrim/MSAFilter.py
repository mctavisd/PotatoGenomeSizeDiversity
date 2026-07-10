#What this does:
#1. Take in FASTA alignment file
#2. Count total length of each sequence in the FASTA, without gaps
#3. Calculate avg length of sequence
#4. Remove any sequence shorter than 25% of average length of sequence
#5. If fewer than 56 (1/2 of sample list) sequences recovered, consider removing sequence from final dataset

#Then, run output through trimAl to remove columns with >75% gaps

import sys
import pathlib
import os

def lengthFilter(inputName):
    fastaSeq ={} #Dict containing fasta sequences
    fastaName = [] #List containing fasta titles
    seqLength = {} #Dict containing lengths of fastas
    inLength = 0
    outLength=0
    average = 0

    with open(inputName,'r') as file:
        Name = str(inputName)
        #inputFile = open (sys.argv[1])
        #print("Input file: "+name.replace('Input/',''))

        for line in file: #For each line from the FASTA file:
            if(line.startswith(">")):
                fastaName.append(line.rstrip())
                fastaSeq[fastaName[inLength]]=""
                inLength=inLength+1    
            else: #Assume all other lines are parts of the DNA sequence:
                fastaSeq[fastaName[inLength-1]] = fastaSeq[fastaName[inLength-1]]+line.rstrip() #Adds the DNA sequence to variable 'sequence' without the ending newline character
        file.close()

    #print(fastaName[0])
    #print(fastaSeq[fastaName[0]])
    #print(fastaName[-1])
    #print(fastaSeq[fastaName[-1]])

    for name in fastaName:
        seqLength[name] = sum(map(fastaSeq[name].count, ['A','T','G','C']))
    #   print(seqLength[name])
	
    average = sum(seqLength.values())/len(seqLength)
    #print("Average length is " + str(average) + " bp")

    file = open (Name.replace('fasta','_out.fasta'),"w")

    for name in fastaName:
        if seqLength[name] >= average/4:
            file.write(name+"\n"+fastaSeq[name]+"\n")
            outLength=outLength+1

    #print(str(outLength))
    file.close()
    return Name, average, outLength

#MAIN:

averages = {}
outSeqCount = {}
name={}

sequenceDir = pathlib.Path (sys.argv[1])

summary = open("filterStats.txt","w")
summary.write("Region\tavg_length\t#_sequences_post_filter\n")

for file in sequenceDir.iterdir():
    if file.is_file():
        if file.name.startswith('.'):
            continue
        #print(file)
        name[file],averages[file],outSeqCount[file]=lengthFilter(file)
        summary.write(name[file].replace('Input/','')+"\t"+str(averages[file])+"\t"+str(outSeqCount[file])+"\n")

summary.close()