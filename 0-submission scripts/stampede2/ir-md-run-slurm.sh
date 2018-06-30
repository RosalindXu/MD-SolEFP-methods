#!/bin/bash

#SBATCH -J holo.cam-s17c-n.1-15ns-run       # Job name
#SBATCH -o holo.cam-s17c-n.1-15ns-run.o%j   # Name of stdout output file
#SBATCH -e holo.cam-s17c-n.1-15ns-run.e%j   # Name of stderr error file
#SBATCH -p normal                           # Queue (partition) name
#SBATCH -N 2                                # Total # of nodes
#SBATCH -n 128                              # Total # of mpi tasks (or number of MPI processes)
#SBATCH -t 40:00:00                         # Run time (hh:mm:ss)
#SBATCH --mail-user=jxu@haverford.edu       # E-mail address
#SBATCH --mail-type=all                     # Send email at begin and end of job (none for no emails)
#SBATCH -A TG-MCB180055                     # Allocation name (req'd if you have more than 1)

# Rosalind J. Xu 18' June 2018
# This script is part of the ir-md-slurm(stampede2) series. The ir-md series should be run in sequence: run-->trim-->{run-cont, dihedral-sasa, helix, solefp-->ftir}.
# The umbrella sampling scripts are independent from the above procedure but assume the same initial setup as ir-md-run-slurm.sh.
# This script starts from a run .tpr file and does md run.
# It is easy to modify this file. Simply add in the command lines you want in the Job Scripts section.
# Stampede2 has $WORK, $SCRATCH, and $HOME directory. All jobs should be run in $SCRATCH, and results should be stored in either $HOME or $WORK. Please refer to my Stampede2 guide!
# The $protein-$site-$spoint-$length is the file name stem -- you can set this stem to whatever you want.
# Note that on Stampede2, gmx mdrun is called mdrun_mpi and should be called with ibrun. All other gmx utilities are called gmx. 

# Job variables
protein=$protein
site=$site
spoint=$spoint
length=$length

# Create $SCRATCH
ORIGDIR=$HOME/gmx/md-charmm-5/$protein/$protein-$site/$protein-$site-$spoint-$length
SCRDIR=$SCRATCH/gmx/md-charmm-5/$protein/$protein-$site/$protein-$site-$spoint-$length
mkdir -p $SCRDIR

# Start of job: Copy from $ORIGDIR to $SCRDIR
cp -r $ORIGDIR/* $SCRDIR
cd $SCRDIR

# Job scripts
ibrun mdrun_mpi -v -deffnm $protein-$site-$spoint-$length

# End of job
cd ~
