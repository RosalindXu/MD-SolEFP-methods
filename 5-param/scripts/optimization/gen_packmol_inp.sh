#!/bin/bash

echo "This program generates input for Packmol, which then packs a regular grid of molecules for pure liquid simulation."

read -p "input .pdb file name: " pdb
read -p "number of molecules on x dimension of grid: " xdim
read -p "number of molecules on y dimension of grid: " ydim
read -p "number of molecules on z dimension of grid: " zdim
read -p "grid spacing (ang) (to represent experimental liquid density, or large enough to represent gas phase): " spacing

echo "#" >> ${pdb%%".pdb"}-packed.inp
echo "# A packed box of $xdim * $ydim * $zdim ${pdb%%".pdb"} to represent experimental density." >> ${pdb%%".pdb"}-packed.inp
echo "#" >> ${pdb%%".pdb"}-packed.inp
echo "" >> ${pdb%%".pdb"}-packed.inp

echo "tolerance 2.0" >> ${pdb%%".pdb"}-packed.inp
echo "filetype pdb" >> ${pdb%%".pdb"}-packed.inp
echo "output ${pdb%%".pdb"}-packed.pdb " >> ${pdb%%".pdb"}-packed.inp
echo "" >> ${pdb%%".pdb"}-packed.inp

for i in $(seq 1 $xdim); do
	for j in $(seq 1 $ydim); do
		for k in $(seq 1 $zdim); do
			echo "structure $pdb" >> ${pdb%%".pdb"}-packed.inp
			echo "  number 1" >> ${pdb%%".pdb"}-packed.inp
			echo "  center" >> ${pdb%%".pdb"}-packed.inp
			icoord=$(bc <<< "($i-1)*$spacing")
			jcoord=$(bc <<< "($j-1)*$spacing")
			kcoord=$(bc <<< "($k-1)*$spacing")
			printf "  %s %6.3f %6.3f %6.3f %2.1f %2.1f %2.1f\n" "fixed" $icoord $jcoord $kcoord 0. 0. 0. >> ${pdb%%".pdb"}-packed.inp
			echo "end structure" >> ${pdb%%".pdb"}-packed.inp
			echo "" >> ${pdb%%".pdb"}-packed.inp
		done
	done
done
