#!/bin/bash

# This program automates the writing of a batch of .itp files. 

read -p "N charge initial: " NInit
read -p "N charge increment: " NIncre
read -p "N charge steps: " NStep
read -p "C charge initial: " CInit
read -p "C charge increment: " CIncre
read -p "C charge steps: " CStep
read -p "S charge initial: " SInit
read -p "S charge increment: " SIncre
read -p "S charge steps: " SStep
read -p "Working directory: " dir

cd $dir

#counter
c=0

for NS in $(seq 0 $((NStep-1))); do
	for CS in $(seq 0 $((CStep-1))); do
		for SS in $(seq 0 $((SStep-1))); do
            c=$((c+1))
			awk -v NS=$NS -v CS=$CS -v SS=$SS -v NInit=$NInit -v NIncre=$NIncre -v CInit=$CInit -v CIncre=$CIncre -v SInit=$SInit -v SIncre=$SIncre 'BEGIN{}
						
			NR==1,NR==9{print}
			NR==10{print $1, $2, $3, -0.27-((NInit+CInit+SInit) + NS*NIncre + CS*CIncre + SS*SIncre), $5, $6, $7 }
			NR==11{print}
			NR==12{print $1, $2, $3, SInit+SIncre*SS, $5, $6, $7 }
			NR==13{print $1, $2, $3, CInit+CIncre*CS, $5, $6, $7 }
			NR==14{print $1, $2, $3, NInit+NIncre*NS, $5, $6, $7 }
			NR==15,NR==47{print}
			NR==48{print $1, $2, $3, $4, $5, $6, -0.27-((NInit+CInit+SInit) + NS*NIncre + CS*CIncre + SS*SIncre), $8 }
			NR==49,NR==51{print}
			NR==52{print $1, $2, $3, $4, $5, $6, SInit+SIncre*SS, $8}
			NR==53{print $1, $2, $3, $4, $5, $6, CInit+CIncre*CS, $8}
			NR==54{print $1, $2, $3, $4, $5, $6, NInit+NIncre*NS, $8} 
			NR>54{print}' mescn.itp > mescn-$c.itp						
		done
	done
done
	
