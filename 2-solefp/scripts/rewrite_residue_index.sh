#!/bin/bash

# This program converts a gromacs .gro file to a version readable by Josh's QMMM package, by re-indexing the residues. 

#Input
echo "Enter working directory:"
read -p "directory: " directory
cd $directory

echo "Enter input .gro file name: "
read -p "input file: " inFile


#count number of records
numR=$( awk 'END{print FNR}' $inFile )

awk -v inFile=$inFile -v numR=$numR 'BEGIN{ORS=""}
#print first two lines
NR==1,NR==2{print $0 "\n"}

#initialize the first residue name and index, as well as length of the first line
NR==3{
	res=$1
	ires=1
	lline=length($0)
}

#print all residue/atom records; index residues as natural numbers
NR==3,NR==(numR-1){
	if ($1!=res){
        res=$1
        ires++
    }
    sub(/[0-9]+/, ires, $0) 
    #/[0-9]+/ is the regular expression for the string of any number of natural number. 
	#sub() command only substitutes the first occurrence
	#$0 is the full line 
	
	#fix line indents
	diff=length($0)-lline
	
	if (diff > 0) {
		for (i=1; i<=diff; i++){
			sub(/\s/, "", $0) #delete the first blank
		}
	}
	else if (diff < 0) {
		for (i=1; i<=(-diff); i++){
			print " " #print an extra blank
	    }
	}
	
	print $0 "\n"
}

#print the last line
NR==numR{print $0 "\n"}

END{}' $inFile > conf_edited.gro

