#!/bin/bash

#PBS -N param
#PBS -l nodes=n13:ppn=12
#PBS -j oe                                                                                                      
#PBS -k oe                                                                                                      
#PBS -V                                                                                                         
#PBS -M jxu@haverford.edu                                                                                       
#PBS -m n

cd MeSCN/MeSCN-gas

for i in $(seq 1 54); do
    mkdir MeSCN-gas-md-$i
    gmx_mpi grompp -f md.mdp -c MeSCN.gro -p MeSCN-gas.top -o MeSCN-gas-md-$i.tpr 
    mv MeSCN-gas-md-$i.tpr MeSCN-gas-md-$i/
    rm *mdout*
    cd MeSCN-gas-md-$i
    gmx_mpi mdrun -v -deffnm MeSCN-gas-md-$i
    cd ..
done

