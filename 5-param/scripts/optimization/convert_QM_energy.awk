#!/bin/bash

#This program converts Orca output of HF energy scans to SI units, and scale the energies by 1.16 as recommended. 
#Enter energies calculated at the same level of theory, i.e., HF or MP2.
read -p "theory: " theory

read -p "Name of dimer: " name

read -p "data file for dimer QM energy: " dimer

read -p "$theory energy for model compound: " compound

read -p "$theory energy for TIP3P water: " water

awk -v dimer=$dimer -v compound=$compound -v water=$water -v theory=$theory 'BEGIN{}

{if (theory=="HF"){
	print $1, ($2-compound-water)*27.2113834*23.0605*4.184*1.16
	}
 else{
 	print $1, ($2-compound-water)*27.2113834*23.0605*4.184
 }	
}

END{}' $dimer > $name-$theory-PES.dat