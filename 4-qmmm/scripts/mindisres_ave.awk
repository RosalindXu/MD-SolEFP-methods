#!/bin/bash

# This file processes *-mindisres.xvg (minimum at each time point; that is, with -respertime option) 
# and calculates the average of minimum distances on a per-residue basis.

read -p ".xvg file name: " xvg
read -p "line number of first data entry (that is, if the .xvg heading has 23 lines, then enter 24 here): " first

# count number of residues
numRes=$( awk -v xvg=$xvg -v first=$first 'BEGIN{} NR==first{print NF-1} END{}' $xvg )
# count number of records
numRec=$( awk -v xvg=$xvg 'BEGIN{} END{print FNR}' $xvg )
# number of time steps
numStep=$((numRec-first))

awk -v xvg=$xvg -v numRes=$numRes -v numRec=$numRec -v numStep=$numStep -v first=$first 'BEGIN{
# initializes array for res. names and sums
for (m=0; m<numRes; m++){
	resList[m]=0
	sumList[m]=0
}
}

# array for res names
NR==first{
for (i=0; i<numRes; i++) {
	resList[i]=$(i+2)
}
}

# array for sums of min. distances
NR==(first+1),NR==numRec{
for (j=0; j<numRes; j++) {
	sumList[j]+=$(j+2)
}
}

END{
for (n=0; n<numRes; n++) {
	aveList[n]=sumList[n]/numStep
	split(resList[n], resTemp, /[0-9]+/)
	printf("%s%s %s\n", (n+1), resTemp[1], aveList[n])
}
}' $xvg > mindisres_ave.dat

echo " "
echo "Run mindisres_ave.dat in mindisres_cutoff.awk to generate a list of residues whose average distances from the probe comes within a cutoff value." 
echo " "