#!/bin/bash                                                                                                     
#PBS -N MeSCN-solvent
#PBS -l nodes=n1:ppn=12                                                                                         
#PBS -j oe                                                                                                      
#PBS -k oe                                                                                                      
#PBS -V                                                                                                         
#PBS -M jxu@haverford.edu                                                                                       
#PBS -m bae   

solvent=water
dsplit=6.0 #ps

cd MeSCN/MeSCN-$solvent
#md run
gmx_mpi mdrun -v -deffnm MeSCN-$solvent

#trajectory trimming
(echo 2; echo 0;)|gmx_mpi trjconv -f MeSCN-$solvent.trr -s MeSCN-$solvent.tpr -o MeSCN-$solvent-nojump.xtc -pbc nojump -center
(echo 2; echo 0;)|gmx_mpi trjconv -f MeSCN-$solvent-nojump.xtc -s MeSCN-$solvent.tpr -o MeSCN-$solvent-nojumpatom.xtc  -pbc atom -ur compact -center
(echo 2; echo 0;)|gmx_mpi trjconv -f MeSCN-$solvent-nojumpatom.xtc -s MeSCN-$solvent.tpr -o MeSCN-$solvent-nojumpatomwhole.xtc  -pbc whole -center
(echo 0;) | gmx_mpi trjconv -f MeSCN-$solvent-nojumpatomwhole.xtc -s MeSCN-$solvent.tpr -o MeSCN-$solvent-trj.pdb -dt 100

#split into smaller trajectories
(echo 0;) | gmx_mpi trjconv -f MeSCN-$solvent-nojumpatomwhole.xtc -s MeSCN-$solvent.tpr -split 6 -o MeSCN-$solvent-.xtc



