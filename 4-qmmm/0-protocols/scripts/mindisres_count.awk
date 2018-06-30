#!/bin/bash

# This file processes *-mindisres.xvg (minimum at each time point; that is, with -respertime option) 
# and counts the number of residues within a cutoff distance from the probe at each time point (mindisres_count_step.dat)
# as well as the "total number of residues within cutoff"  "total number of such occurrences" (mindisres_count_tot.dat) 
# -- mainly useful for selecting the number of waters to include in QM region

read -p ".xvg file name: " xvg
read -p "line number of first data entry (that is, if the .xvg heading has 23 lines, then enter 24 here): " first
read -p "cutoff distance (in angstrom): " cutoff

# count number of residues
numRes=$( awk -v xvg=$xvg -v first=$first 'BEGIN{} NR==first{print NF-1} END{}' $xvg )
# count number of records
numRec=$( awk -v xvg=$xvg 'BEGIN{} END{print FNR}' $xvg )
# number of time steps
numStep=$((numRec-first))

awk -v xvg=$xvg -v numRes=$numRes -v numRec=$numRec -v numStep=$numStep -v first=$first -v cutoff=$cutoff 'BEGIN{
# initializes array for number of close residues at each time step
for (m=0; m<numStep; m++){
	countList[m]=0
}
}

# array for number of close residues, the residue names and distances
NR==(first+1),NR==numRec{
for (j=0; j<numRes; j++) {
	if ($(j+2) < cutoff/10) {
		countList[NR-(first+1)]+=1
	}
}

print $1, countList[NR-(first+1)]

}

END{}' $xvg > mindisres_count_step.dat

awk '{

totalList[$2]+=1

}

END{

for (i in totalList) {
	
	print i, totalList[i]

}

}' mindisres_count_step.dat | sort -k 1 > mindisres_count_tot.dat

