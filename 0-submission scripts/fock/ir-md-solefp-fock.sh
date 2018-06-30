
#!/bin/bash                                                                                                     
#PBS -N 1cll-m72c-SolEFP-additive                                                                                                                                         
#PBS -j oe                                                                                                      
#PBS -k oe                                                                                                      
#PBS -V                                                                                                         
#PBS -M jxu@haverford.edu                                                                                       
#PBS -m n

# Rosalind J. Xu 18' June 2018
# This script is part of the ir-md-fock series. This series should be run in sequence: run-trim-->(solefp-sub AND solefp)-->ftir.
# This script should be submitted by ir-md-solefp-sub-fock.sh.

cd $dir
mkdir $protein-$site-$proc-$j

cp probe-charmm.tc $protein-$site-$proc-$j
cp gmx-charmm.tc $protein-$site-$proc-$j
cp run_biomol.py $protein-$site-$proc-$j
cp $protein-$site-$proc.gro $protein-$site-$proc-$j
mv $protein-$site-$proc-$j.xtc $protein-$site-$proc-$j
cd $protein-$site-$proc-$j

python run_biomol.py $protein-$site-$proc.gro $protein-$site-$proc-$j.xtc $protein-$site-$proc-${rcl_algorithm}-$conh-$j.dat ${rcl_algorithm} $conh > $protein-$site-$proc-${rcl_algorithm}-$conh-$j.out
