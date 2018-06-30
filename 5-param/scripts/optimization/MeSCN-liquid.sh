#!/bin/bash                                                                                                     
#PBS -N liquid                                                                                        
#PBS -l nodes=n6:ppn=1                                                                                         
#PBS -j oe                                                                                                      
#PBS -k oe                                                                                                      
#PBS -V                                                                                                         
#PBS -M jxu@haverford.edu                                                                                       
#PBS -m bae   

i=5
cd MeSCN/MeSCN-liquid/MeSCN-liquid-md-$i
gmx_mpi mdrun -v -deffnm MeSCN-liquid-md-$i
