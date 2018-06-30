#!/bin/bash                                                                                                     
#PBS -N IR-MD
#PBS -l nodes=n2:ppn=12                                                                                         
#PBS -j oe                                                                                                      
#PBS -k oe                                                                                                      
#PBS -V                                                                                                         
#PBS -M jxu@haverford.edu                                                                                       
#PBS -m bae

# Rosalind J. Xu 18' June 2018
# This script is part of the ir-md-fock series. This series should be run in sequence: run-trim-->(solefp-sub AND solefp)-->ftir.
# Sample Fock md run and trim script. This script starts from a run .tpr file and does run-trimming-output processing. The .tpr file should contain a structure that is either equilibrated or a continuation from a MD trajectory. If you need different scripts to live in here (for example, adding in the eqlb part or dihedral / sasa) simply copy paste from the gmx protocol file, gromacs-eqlb-run-trim-process.txt.
# The $protein-$site-6md is the file name stem -- you can set this stem to whatever you want. Another name stem I frequently used was $protein-$site-$spoint-$length.
# Note that on Fock, gmx is called gmx_mpi

protein=2BBM
site=12.B
dtsplit=60 #ps

cd gmx/$protein-$site # working directory

#md run
gmx_mpi mdrun -v -deffnm $protein-$site-6md

#trajectory processing: please follow the trimming steps in order to produce an unbroken trajectory!
#you almost certainly need to change the index group numbers following each "echo": refer to gromacs-eqlb-run-trim-process.txt for which index groups you should select!
(echo 1 \| 13; echo q;) | gmx_mpi make_ndx -f $protein-$site-6md.tpr -o $protein-$site-pdb.ndx
(echo 19; echo 0;)|gmx_mpi trjconv -f $protein-$site-6md.trr -s $protein-$site-1mini.tpr -n $protein-$site-pdb.ndx -o $protein-$site-6md-nojump.xtc -pbc nojump -center
(echo 1; echo 0;)|gmx_mpi trjconv -f $protein-$site-6md-nojump.xtc -s $protein-$site-1mini.tpr -n $protein-$site-pdb.ndx -o $protein-$site-6md-nojumpwhole.xtc -pbc whole -center
(echo 1; echo 0;)|gmx_mpi trjconv -f $protein-$site-6md-nojumpwhole.xtc -s $protein-$site-6md.tpr -n $protein-$site-pdb.ndx -o $protein-$site-6md-nojumpwholeatom.xtc -pbc atom -ur compact -center
(echo 1; echo 0;)|gmx_mpi trjconv -f $protein-$site-6md-nojumpwholeatom.xtc -s $protein-$site-6md.tpr -n $protein-$site-pdb.ndx -o $protein-$site-6md-nojumpwholeatomwhole.xtc -pbc whole -center

# examine the trimmed trajectory -- refer to gromacs-eqlb-run-trim-process.txt for what to look out for!!
(echo 0;)|gmx_mpi trjconv -f $protein-$site-6md-nojumpwholeatomwhole.xtc -s $protein-$site-6md.tpr -n $protein-$site-pdb.ndx -o $protein-$site-6md-trj.pdb -fit rot+trans -dt 20000
(echo 19;)|gmx_mpi trjconv -f $protein-$site-6md-nojumpwholeatomwhole.xtc -s $protein-$site-6md.tpr -n $protein-$site-pdb.ndx -o $protein-$site-6md-protein.pdb -fit rot+trans -dt 100

#rms and gyrate
(echo 19; echo 19;) | gmx_mpi rms -f $protein-$site-6md-nojumpwholeatomwhole.xtc  -s $protein-$site-6md.tpr -n  $protein-$site-pdb.ndx -o $protein-$site-6md-rms.xvg
(echo 19;) | gmx_mpi gyrate -f $protein-$site-6md-nojumpwholeatomwhole.xtc -s $protein-$site-6md.tpr -n  $protein-$site-pdb.ndx -o $protein-$site-6md-gyrate.xvg

#split into $dtsplit ps parts for SolEFP calculations
(echo 0;) | gmx_mpi trjconv -f $protein-$site-6md-nojumpwholeatomwhole.xtc -s $protein-$site-6md.tpr -split $dtsplit -o $protein-$site-6md-.xtc
