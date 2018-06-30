#!/bin/bash                                                                                                     
#PBS -N orca                                                                                        
#PBS -l nodes=n1:ppn=12                                                                                         
#PBS -j oe                                                                                                      
#PBS -k oe                                                                                                      
#PBS -V                                                                                                         
#PBS -M jxu@haverford.edu                                                                                       
#PBS -m bae   

# number of jobs per node
k=2
# number of first node
n=1
# initialize counter
c=0

for rare in He Ne; do
	cd MeSCN/LJ/QM/MeSCN-$rare
	for j in *; do
		m=$((n + (c-(c%k))/k))
		qsub -l nodes=n$m:ppn=1 -v rare=$rare,j=$j ~/orca.sh
		c=$((c+1))
	done
	cd ~
done 

