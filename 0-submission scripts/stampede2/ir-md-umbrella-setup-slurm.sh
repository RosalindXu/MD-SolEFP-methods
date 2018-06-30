#!/bin/bash

#SBATCH -J holo.cam-s17c-n.1-15ns-umbrella-setup     # Job name
#SBATCH -o holo.cam-s17c-n.1-15ns-umbrella-setup.o%j # Name of stdout output file
#SBATCH -e holo.cam-s17c-n.1-15ns-umbrella-setup.e%j # Name of stderr error file
#SBATCH -p skx-normal                       # Queue (partition) name
#SBATCH -N 1                                # Total # of nodes
#SBATCH -n 1                                # Total # of mpi tasks (or number of MPI processes)
#SBATCH -t 01:00:00                         # Run time (hh:mm:ss)
#SBATCH --mail-user=jxu@haverford.edu       # E-mail address
#SBATCH --mail-type=all                     # Send email at begin and end of job (none for no emails)
#SBATCH -A TG-MCB180055                     # Allocation name (req'd if you have more than 1)

# Rosalind J. Xu 18'  June 2018
# This script is part of the ir-md-slurm(stampede2) series. The ir-md series should be run in sequence: run-->trim-->{run-cont, dihedral-sasa, helix, solefp-->ftir}.
# The umbrella sampling scripts are independent from the above procedure but assume the same initial setup as ir-md-run-slurm.sh.
# The umbrella sampling scripts should be run in the following sequence: umbrella-setup --> umbrella-md.
# This script prepares input files for umbrella-md
# You will need to change protein names, etc. of course
# Different from other scripts in series, the following script operates directly in the $HOME directory (that is, it does not copy paste back and forth between $HOME and $SCRATCH)
# The following script can also be run in command line. To start an interactive session, type:
#  idev -p skx-normal -A [allocation name] -m [#minutes you request]
#  and copy paste the following scripts into command line after idev initialization finishes

length=250ps-umbrella
lengthold=15ns
for protein in holo.cam; do
for site in s17c v35c m72c l105c m109c m145c; do
for spoint in n.1 n.2 n.3 n.4 n.5 n.6 ; do
    cd $HOME/gmx/md-charmm-5/$protein/$protein-$site
    mkdir $protein-$site-$spoint-$length
    cp $protein-$site-$spoint-$lengthold/* $protein-$site-$spoint-$length
    cp $HOME/gmx/mdpfiles/umbrella-md.mdp $protein-$site-$spoint-$length
    cd $protein-$site-$spoint-$length
    awk '/$protein-$site_Ion_chain_A2.itp/{print "#include \"dihrestraint.itp\""}1' $protein-$site.top > $protein-$site-umbrella.top
    (echo a CA CB SD CE \& r MSCN; echo q;) | gmx make_ndx -f $protein-$site-$spoint-$lengthold-initial.gro -o $protein-$site-dihedral1.ndx
    (echo a N CA CB SD \& r MSCN; echo q;) | gmx make_ndx -f $protein-$site-$spoint-$lengthold-initial.gro -o $protein-$site-dihedral2.ndx
    dihndx1=$(tail -n 1 $protein-$site-dihedral1.ndx)
    dihndx2=$(tail -n 1 $protein-$site-dihedral2.ndx)
    rm $protein-$site.top
    rm 6-md.mdp
    rm *.dat
    rm *.xvg
    rm *.launcher
    rm *trj.pdb
    rm *protein.pdb
    for center1 in $(seq 0 30 331); do
    for center2 in $(seq 0 30 331); do
        mkdir $protein-$site-$spoint-$length-$center1-$center2
        cp *.* $protein-$site-$spoint-$length-$center1-$center2
        cd $protein-$site-$spoint-$length-$center1-$center2
        (echo [ dihedral_restraints ]; echo \; ai  aj  ak  al  type  phi  dphi  kfac; echo \;CA-CB-SD-CE; echo $dihndx1 1 $center1 0 30; echo \;N-CA-CB-SD; echo $dihndx2 1 $center2 0 30;) > dihrestraint.itp
        gmx grompp -f umbrella-md.mdp -c $protein-$site-$spoint-$lengthold-initial.gro -p $protein-$site-umbrella.top -o $protein-$site-$spoint-$length-$center1-$center2-md.tpr -maxwarn 2
        cd ..
    done
    done
    rm *.*
    cd ~
done
done
done
