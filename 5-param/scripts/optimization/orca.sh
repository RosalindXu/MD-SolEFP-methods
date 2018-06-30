#!/bin/bash                                                                                                     
#PBS -N LJQM                                                                                         
#PBS -l nodes=n1:ppn=1                                                                                         
#PBS -j oe                                                                                                      
#PBS -k oe                                                                                                      
#PBS -V                                                                                                         
#PBS -M jxu@haverford.edu                                                                                       
#PBS -m n

cd ~/MeSCN/LJ/QM/MeSCN-$rare/$j

$ORCA/orca $j-scan.inp > $j-scan.out

