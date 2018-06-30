#!/bin/bash

# This program converts .xyz PES scan trajectory, made from *.property.txt from Orca output, to a .gro file for MM input.

echo "Before use, please open trj_to_gro.awk and modify the list of residue names and atomic names in the BEGIN block" 
echo "Parsing .xyz files can be tricky. Currently, this program used a completely blank line as the record separator."
echo "However, if this is giving any trouble, please go back to your .xyz trajectory and make sure that there is a completely blank line between each entry."
echo "(that a line appears blank in text editor does not necessarily mean it is blank...instead, delete the whole line to make sure." 
echo "Or you can change the record separator." 

read -p ".xyz filename: " xyz
read -p "name of the dimer orientation: " ort
read -p "total number of atoms: " natoms
read -p "number of frames in .xyz: " nframes

for i in $(seq 1 $nframes); do

awk -v i=$i 'BEGIN{RS="\n\n+"} NR==i{print}' $xyz | 

awk -v natoms=$natoms 'BEGIN{
res[1]="1MeSCN";
res[2]="1MeSCN";
res[3]="1MeSCN";
res[4]="1MeSCN";
res[5]="1MeSCN";
res[6]="1MeSCN";
res[7]="1MeSCN";
res[8]="2SOL";
res[9]="2SOL";
res[10]="2SOL";

atom[1]="C";
atom[2]="H";
atom[3]="H";
atom[4]="H";
atom[5]="S";
atom[6]="C";
atom[7]="N";
atom[8]="OW";
atom[9]="HW1";
atom[10]="HW2";

printf("%s\n", "MM PES scan");
printf("  %d\n", natoms);
}

NR==3,NR==(2+natoms){
printf("  %-6s%5s%5d%8.3f%8.3f%8.3f\n",res[NR-2], atom[NR-2], 1, $2/10, $3/10, $4/10)
}

END{
printf("%-10.5f%-10.5f%-10.5f\n", 10, 10, 10)
}' >> $ort-scan.gro

done
