#!/bin/bash

#SBATCH -J 1cll-s17c-125.0ns-12ns-run       # Job name
#SBATCH -o 1cll-s17c-125.0ns-12ns-run.o%j   # Name of stdout output file
#SBATCH -e 1cll-s17c-125.0ns-12ns-run.e%j   # Name of stderr error file
#SBATCH -p normal                           # Queue (partition) name
#SBATCH -N 2                                # Total # of nodes
#SBATCH -n 128                              # Total # of mpi tasks (or number of MPI processes)
#SBATCH -t 02:00:00                         # Run time (hh:mm:ss)
#SBATCH --mail-user=jxu@haverford.edu       # E-mail address
#SBATCH --mail-type=all                     # Send email at begin and end of job (none for no emails)
#SBATCH -A Ras                     # Allocation name (req'd if you have more than 1)

# Rosalind J. Xu 18'  June 2018
# This script is part of the ir-md-slurm(stampede2) series. The ir-md series should be run in sequence: run-->trim-->{run-cont, dihedral-sasa, helix, solefp-->ftir}.
# The umbrella sampling scripts are independent from the above procedure but assume the same initial setup as ir-md-run-slurm.sh.
# This script should be used if a md run job crashes because the requested run time is depleted. For example, 30 h is requested in (-t), but the job actually needs 31 h. The job crashes prematurally. Then this script can be used to make the run finish. With -append option, the output is appended to the original output file.

# Job variables
protein=$protein
site=$site
spoint=$spoint
length=$length

# Create $SCRATCH
ORIGDIR=$HOME/gmx/md-charmm-5/$protein/$protein-$site/$protein-$site-$spoint-$length
SCRDIR=$SCRATCH/gmx/md-charmm-5/$protein/$protein-$site/$protein-$site-$spoint-$length
#mkdir -p $SCRDIR

# Start of job: Copy from $ORIGDIR to $SCRDIR
#cp -r $ORIGDIR/* $SCRDIR
cd $SCRDIR

# Job scripts
mkdir temp
cp  $protein-$site-$spoint-$length.cpt temp/$protein-$site-$spoint-$length.cpt
cp  $protein-$site-$spoint-$length.edr temp/$protein-$site-$spoint-$length.edr
cp  $protein-$site-$spoint-$length.log temp/$protein-$site-$spoint-$length.log
cp  $protein-$site-$spoint-$length\_prev.cpt temp/$protein-$site-$spoint-$length_prev.cpt
cp  $protein-$site-$spoint-$length.tpr temp/$protein-$site-$spoint-$length.tpr
cp  $protein-$site-$spoint-$length.trr temp/$protein-$site-$spoint-$length.trr

ibrun mdrun_mpi -v -cpi $protein-$site-$spoint-$length.cpt -s $protein-$site-$spoint-$length.tpr -append -deffnm $protein-$site-$spoint-$length

#cp $protein-$site-$spoint-$length-2.gro $protein-$site-$spoint-$length.gro
#gmx trjcat -f $protein-$site-$spoint-$length-1.trr $protein-$site-$spoint-$length-2.trr -o $protein-$site-$spoint-$length.trr

# End of job: submit ir-md-trim-slurm.sh
cd ~
export protein=$protein
export site=$site
export spoint=$spoint
export length=$length
#sbatch -J $protein-$site-$spoint-$length-trim-%j -o $protein-$site-$spoint-$length-trim.o%j -e $protein-$site-$spoint-$length-trim.e%j ir-md-trim-slurm.sh


