#!/bin/bash

# write small molecule SolEFP input file (with fragmentation)
# the first residue is always MeSCN (already in small.inp)

# reading inputs
read -p 'name of small molecule: ' res
read -p 'number of fragments: ' Nfrag
for i in $(seq 1 $Nfrag); do
    read -p "name of fragment # $i: " frag[$i]
    read -p "reorder list for fragment # $i: " reorder[$i]
    read -p "supl list for fragment # $i: " supl[$i]
done
read -p 'number of atoms in small molecule: ' Natoms
read -p 'number of small molecules: ' Nmol

#counter for solvent atoms
counter=8

for j in $(seq 1 $Nmol); do
    for i in $(seq 1 $Nfrag); do
		printf "\n\n# $res $((j+1))" >> small.inp
		printf "\n\$Frag" >> small.inp
		printf "\n$res \t\t ${frag[$i]}" >> small.inp
		printf "\nreorder \t ${reorder[$i]}" >> small.inp
		printf "\nsupl \t\t ${supl[$i]}" >> small.inp
		printf "\natoms \t\t " >> small.inp
        for k in $(seq $counter $((counter+Natoms-2))); do
			printf "$k" >> small.inp
			printf "," >> small.inp
		done
		printf "$((counter+Natoms-1))" >> small.inp
		printf "\t\t 1" >> small.inp
		printf "\n\$endFrag" >> small.inp
	done
    counter=$((counter+Natoms))
done

