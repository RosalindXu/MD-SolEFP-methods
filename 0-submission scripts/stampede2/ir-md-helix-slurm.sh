#!/bin/bash

#SBATCH -J holo.cam-s17c-n.1-15ns-helix     # Job name
#SBATCH -o holo.cam-s17c-n.1-15ns-helix.o%j # Name of stdout output file
#SBATCH -e holo.cam-s17c-n.1-15ns-helix.e%j # Name of stderr error file
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
# For calculating interhelical angles. You also need to put calc_helix_vector.py and calc_helix_angle.py in the right place (see below for where these two files are needed). These two files can be found in MD-SolEFP-methods/MD/scripts/helix.

# Job variables
protein=$protein
site=$site
spoint=$spoint
length=$length
interval=10 ;ps. interval at which helix angles will be evaluated

# Create $SCRATCH
ORIGDIR=$HOME/gmx/md-charmm-5/$protein/$protein-$site/$protein-$site-$spoint-$length
SCRDIR=$SCRATCH/gmx/md-charmm-5/$protein/$protein-$site/$protein-$site-$spoint-$length
#mkdir -p $SCRDIR
cd $SCRDIR

# Job scripts
cp $HOME/gmx/scripts/calc_helix_vector.py $SCRDIR
cp $HOME/gmx/scripts/calc_helix_angle.py $SCRDIR
(echo 0;) | gmx trjconv -f $protein-$site-$spoint-$length-nojumpwholeatomwhole.xtc -s $protein-$site-$spoint-$length-solefp.gro -o $protein-$site-$spoint-$length-interval.xtc -dt $interval
python calc_helix_vector.py $protein-$site-$spoint-$length-solefp.gro $protein-$site-$spoint-$length-interval.xtc $protein-$site-$spoint-$length
python calc_helix_angle.py $protein-$site-$spoint-$length

# End of job
cp $protein-$site-$spoint-$length-helix_angle-*.dat $ORIGDIR
cd ~
