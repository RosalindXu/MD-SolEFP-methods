#!/bin/bash

#SBATCH -J holo.cam-s17c-n.1-15ns-trim      # Job name
#SBATCH -o holo.cam-s17c-n.1-15ns-trim.o%j  # Name of stdout output file
#SBATCH -e holo.cam-s17c-n.1-15ns-trim.e%j  # Name of stderr error file
#SBATCH -p skx-normal                       # Queue (partition) name
#SBATCH -N 1                                # Total # of nodes
#SBATCH -n 1                                # Total # of mpi tasks (or number of MPI processes)
#SBATCH -t 05:00:00                         # Run time (hh:mm:ss)
#SBATCH --mail-user=jxu@haverford.edu       # E-mail address
#SBATCH --mail-type=all                     # Send email at begin and end of job (none for no emails)
#SBATCH -A TG-MCB180055                     # Allocation name (req'd if you have more than 1)

# Rosalind J. Xu 18' June 2018
# This script is part of the ir-md-slurm(stampede2) series. The ir-md series should be run in sequence: run-->trim-->{run-cont, dihedral-sasa, helix, solefp-->ftir}.
# The umbrella sampling scripts are independent from the above procedure but assume the same initial setup as ir-md-run-slurm.sh.
# This script starts from a finished md trajectory and does post-processing.
# It is easy to modify this file. Simply add in the command lines you want in the Job Scripts section.
# Stampede2 has $WORK, $SCRATCH, and $HOME directory. All jobs should be run in $SCRATCH, and results should be stored in either $HOME or $WORK. Please refer to my Stampede2 guide!
# The $protein-$site-$spoint-$length is the file name stem -- you can set this stem to whatever you want.

# Job variables
protein=$protein
site=$site
spoint=$spoint
length=$length
b=0         #ps. Beginning time point for solefp jobs
dt=0.1      #ps. Sampling interval for solefp jobs. Must be interger multiples of the md saving interval.
split=315   #ps. Size of each trajectory chunck for solefp jobs. If using 1 skx-normal node and 48 mpi tasks (one for each core), then split=[total trajectory length] divided by 48, round up to the next integer. split has to be integer multiples of dt.

# Create $SCRATCH
ORIGDIR=$HOME/gmx/md-charmm-5/$protein/$protein-$site/$protein-$site-$spoint-$length
SCRDIR=$SCRATCH/gmx/md-charmm-5/$protein/$protein-$site/$protein-$site-$spoint-$length
#mkdir -p $SCRDIR

# Start of job
cd $SCRDIR

# Job scripts
# You will very likely need to change the index group numbers; refer to gromacs-eqlb-run-trim-process.txt (the MD protocol) for which index groups to select
# trajectory trimming
# index numbers are customized!!
(echo 1 \| 13; echo q;) | gmx make_ndx -f $protein-$site-$spoint-$length.gro -o $protein-$site-pdb.ndx
# this 24 number will change from system to system and needs to be read out from .ndx file
(echo 24; echo 0;) | gmx trjconv -f $protein-$site-$spoint-$length.trr -s $protein-$site-$spoint-$length.tpr -n $protein-$site-pdb.ndx -o $protein-$site-$spoint-$length-nojump.xtc -pbc nojump -center
(echo 1; echo 0;) | gmx trjconv -f $protein-$site-$spoint-$length-nojump.xtc -s $protein-$site-$spoint-$length.tpr -n $protein-$site-pdb.ndx -o $protein-$site-$spoint-$length-nojumpwhole.xtc -pbc whole -center
(echo 1; echo 0;) | gmx trjconv -f $protein-$site-$spoint-$length-nojumpwhole.xtc -s $protein-$site-$spoint-$length.tpr -n $protein-$site-pdb.ndx -o $protein-$site-$spoint-$length-nojumpwholeatom.xtc -pbc atom -ur compact -center
(echo 1; echo 0;) | gmx trjconv -f $protein-$site-$spoint-$length-nojumpwholeatom.xtc -s $protein-$site-$spoint-$length.tpr -n $protein-$site-pdb.ndx -o $protein-$site-$spoint-$length-nojumpwholeatomwhole.xtc -pbc whole -center
mv $protein-$site-$spoint-$length-nojump.xtc $SCRATCH/temp
mv $protein-$site-$spoint-$length-nojumpwhole.xtc $SCRATCH/temp
mv $protein-$site-$spoint-$length-nojumpwholeatom.xtc $SCRATCH/temp

# trajectory and protein .pdb file for visualization
(echo 24; echo 0;) | gmx trjconv -f $protein-$site-$spoint-$length-nojumpwholeatomwhole.xtc -s $protein-$site-$spoint-$length.tpr -n $protein-$site-pdb.ndx -o $protein-$site-$spoint-$length-trj.pdb -fit rot+trans -dt 2000
(echo 24; echo 24;)| gmx trjconv -f $protein-$site-$spoint-$length-nojumpwholeatomwhole.xtc -s $protein-$site-$spoint-$length.tpr -n  $protein-$site-pdb.ndx -o $protein-$site-$spoint-$length-protein.pdb -fit rot+trans -dt 100

# rms and gyrate
(echo 24; echo 24;) | gmx rms -f $protein-$site-$spoint-$length-nojumpwholeatomwhole.xtc -s $protein-$site-$spoint-$length.tpr -n $protein-$site-pdb.ndx  -o $protein-$site-$spoint-$length-rms.xvg
(echo 24;) | gmx gyrate -f $protein-$site-$spoint-$length-nojumpwholeatomwhole.xtc -s $protein-$site-$spoint-$length.tpr -n $protein-$site-pdb.ndx  -o $protein-$site-$spoint-$length-gyrate.xvg

# divide trajectory into chuncks for solefp calculations
(echo 0;) | gmx trjconv -f $protein-$site-$spoint-$length-nojumpwholeatomwhole.xtc -s $protein-$site-$spoint-$length.tpr -o $protein-$site-$spoint-$length-.xtc -b $b -dt $dt -split $split

# End of job: copy .xvg and .pdb files back to $ORIGDIR
cp $protein-$site-$spoint-$length-trj.pdb $ORIGDIR
cp $protein-$site-$spoint-$length-protein.pdb $ORIGDIR
cp $protein-$site-$spoint-$length-rms.xvg $ORIGDIR
cp $protein-$site-$spoint-$length-gyrate.xvg $ORIGDIR
cd ~
