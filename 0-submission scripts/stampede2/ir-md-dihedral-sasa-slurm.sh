#!/bin/bash

#SBATCH -J holo.cam-s17c-n.1-15ns-dihedral_sasa      # Job name
#SBATCH -o holo.cam-s17c-n.1-15ns-dihedral_sasa.o%j  # Name of stdout output file
#SBATCH -e holo.cam-s17c-n.1-15ns-dihedral_sasa.e%j  # Name of stderr error file
#SBATCH -p skx-normal                       # Queue (partition) name
#SBATCH -N 1                                # Total # of nodes
#SBATCH -n 1                                # Total # of mpi tasks (or number of MPI processes)
#SBATCH -t 02:00:00                         # Run time (hh:mm:ss)
#SBATCH --mail-user=jxu@haverford.edu       # E-mail address
#SBATCH --mail-type=all                     # Send email at begin and end of job (none for no emails)
#SBATCH -A TG-MCB180055	                    # Allocation name (req'd if you have more than 1)

# Rosalind J. Xu 18'  June 2018
# This script is part of the ir-md-slurm(stampede2) series. The ir-md series should be run in sequence: run-->trim-->{run-cont, dihedral-sasa, helix, solefp-->ftir}.
# The umbrella sampling scripts are independent from the above procedure but assume the same initial setup as ir-md-run-slurm.sh.
# For calculating dihedral and sasa. Visualize results in xmgrace. (with -nxy option)

# Job variables
protein=$protein
site=$site
spoint=$spoint
length=$length

# cd $SCRATCH
ORIGDIR=$HOME/gmx/md-charmm-5/$protein/$protein-$site/$protein-$site-$spoint-$length
SCRDIR=$SCRATCH/gmx/md-charmm-5/$protein/$protein-$site/$protein-$site-$spoint-$length
cd $SCRDIR

# Job scripts
(echo a CA CB SD CE \& r MSCN; echo a N CA CB SD \& r MSCN; echo q;) | gmx make_ndx -f $protein-$site-$spoint-$length.tpr -o dihedral.ndx
(echo 24;) | gmx angle -type dihedral -f $protein-$site-$spoint-$length-nojumpwholeatomwhole.xtc -n dihedral.ndx -ov $protein-$site-$spoint-$length-dihedral1.xvg -dt 10
(echo 25;) | gmx angle -type dihedral -f $protein-$site-$spoint-$length-nojumpwholeatomwhole.xtc -n dihedral.ndx -ov $protein-$site-$spoint-$length-dihedral2.xvg -dt 10
(echo "a NF \& r MSCN"; echo q;) | gmx make_ndx -f $protein-$site-$spoint-$length.tpr -n $protein-$site-pdb.ndx -o sasa-N.ndx
gmx sasa -surface 24 -output 25 -f $protein-$site-$spoint-$length-nojumpwholeatomwhole.xtc -s $protein-$site-$spoint-$length.tpr -n sasa-N.ndx -o $protein-$site-$spoint-$length-sasa-N.xvg -ndots 168 -dt 10

# End of job: copy .xvg, .pdb files to $ORIGDIR
cp $SCRDIR/$protein-$site-$spoint-$length-dihedral1.xvg $ORIGDIR
cp $SCRDIR/$protein-$site-$spoint-$length-dihedral2.xvg $ORIGDIR
cp $SCRDIR/$protein-$site-$spoint-$length-sasa-N.xvg $ORIGDIR
cd ~
