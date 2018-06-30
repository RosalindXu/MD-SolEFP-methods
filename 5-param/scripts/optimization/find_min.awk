#!/bin/bash

# This program finds minimum interaction energy and distance along a PES. 

read -p "QM or MM? " mode
read -p "Name of dimer orientation: " ort
read -p "If MM, provide LJcomb index: " j

if [[ $mode == "QM" ]]; then
	awk -v ort=$ort 'BEGIN{minE=1000; minD=0}
	{if ($2 < minE){minE=$2; minD=$1}}
	END{print ort, minD, minE}' $ort-trjact.dat 
fi

if [[ $mode == "MM" ]]; then
	awk -v ort=$ort -v j=$j 'BEGIN{minE=1000; minD=0}
	{if ($2 < minE){minE=$2; minD=$1}}
	END{print ort, j, minD, minE}' $ort-$j-MM-PES.dat 
fi