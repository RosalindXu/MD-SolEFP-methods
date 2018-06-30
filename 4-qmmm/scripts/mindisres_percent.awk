#!/bin/bash

# This file processes *-mindisres.xvg (minimum at each time point; that is, with -respertime option) 
# and calculates the percentage of times a residue is within cutoff from the probe

read -p ".xvg file name: " xvg
read -p "line number of first data entry (that is, if the .xvg heading has 23 lines, then enter 24 here): " first
read -p "cutoff (in angstrom): " cutoff

# count number of residues
numRes=$( awk -v xvg=$xvg -v first=$first 'BEGIN{} NR==first{print NF-1} END{}' $xvg )
# count number of records
numRec=$( awk -v xvg=$xvg 'BEGIN{} END{print FNR}' $xvg )
# number of time steps
numStep=$((numRec-first))

awk -v xvg=$xvg -v numRes=$numRes -v numRec=$numRec -v numStep=$numStep -v first=$first -v cutoff=$cutoff 'BEGIN{
# initializes array for res. names and counts
for (m=0; m<numRes; m++){
	resList[m]=0
	countList[m]=0
}
}

# array for res names
NR==first{
for (i=0; i<numRes; i++) {
	resList[i]=$(i+2)
}
}

# array for counts of time points within cutoff
NR==(first+1),NR==numRec{
for (j=0; j<numRes; j++) {
	if ($(j+2) < cutoff/10){
		countList[j]+=1
	}
}
}

END{
for (n=0; n<numRes; n++) {
	percentList[n]=countList[n]/numStep
	split(resList[n], resTemp, /[0-9]+/)
	printf("%s%s %s\n", (n+1), resTemp[1], percentList[n])
}
}' $xvg > mindisres_percent.dat

echo " "
echo "Run mindisres_percent.dat in mindisres_cutoff.awk to generate a list of residues that come close to the probe for higher than a certain percentage of times." 
echo " "

