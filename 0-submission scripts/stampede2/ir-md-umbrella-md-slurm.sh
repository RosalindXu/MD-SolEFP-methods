#!/bin/bash

#SBATCH -J holo.cam-s17c-n.1-15ns-umbrella     # Job name
#SBATCH -o holo.cam-s17c-n.1-15ns-umbrella.o%j # Name of stdout output file
#SBATCH -e holo.cam-s17c-n.1-15ns-umbrella.e%j # Name of stderr error file
#SBATCH -p skx-normal                       # Queue (partition) name
#SBATCH -N 9                                # Total # of nodes
#SBATCH -n 432                              # Total # of mpi tasks (or number of MPI processes)
#SBATCH -t 10:00:00                         # Run time (hh:mm:ss)
#SBATCH --mail-user=jxu@haverford.edu       # E-mail address
#SBATCH --mail-type=all                     # Send email at begin and end of job (none for no emails)
#SBATCH -A TG-MCB180055	                    # Allocation name (req'd if you have more than 1)

# Rosalind J. Xu 18'  June 2018
# This script is part of the ir-md-slurm(stampede2) series. The ir-md series should be run in sequence: run-->trim-->{run-cont, dihedral-sasa, helix, solefp-->ftir}.
# The umbrella sampling scripts are independent from the above procedure but assume the same initial setup as ir-md-run-slurm.sh.
# The umbrella sampling scripts should be run in the following sequence: umbrella-setup --> umbrella-md.
# This script submits umbrella-md jobs. Since each trajectory is only 250 ps long, the most efficient way is actually to allocate each trajectory to one processor on one skx-normal node, instead of running parallel.
# This script utlizes launcher to submit multiple serial jobs onto the same node, trim the trajectory, and output the CA-CB-SD-CE and N-CA-CB-SD dihedral angles. The output files can then be processed using the Grossfield lab WHAM program: http://membrane.urmc.rochester.edu/content/wham to yield Bolzman-weighted probabilities of dihedral combinations.

# Job variables
protein=$protein
sitelist=$sitelist     #format for sitelist: "s17c v35c m72c", for exp.
spointlist=$spointlist #format for spointlist: "n.1 n.2 n.3", for exp.
length=$length
b=50                   #begin time for sampling

# Create $SCRATCH; Copy from $ORIGDIR to $SCRDIR
ORIGDIR=$HOME/gmx/md-charmm-5/$protein
SCRDIR=$SCRATCH/gmx/md-charmm-5/$protein
for site in $sitelist; do
for spoint in $spointlist; do
    mkdir -p $SCRDIR/$protein-$site/$protein-$site-$spoint-$length
    cp -r $ORIGDIR/$protein-$site/$protein-$site-$spoint-$length/* $SCRDIR/$protein-$site/$protein-$site-$spoint-$length
done
done
cd $SCRDIR

# Write job scripts in launcher input file
jobfile=$protein-${sitelist:0:3}-${spointlist:0:3}-$length-md.launcher
rm $jobfile  #Clear previous jobfile

for site in $sitelist; do
for spoint in $spointlist; do
    for center1 in $(seq 0 30 331); do
    for center2 in $(seq 0 30 331); do
        echo "cd $SCRDIR/$protein-$site/$protein-$site-$spoint-$length/$protein-$site-$spoint-$length-$center1-$center2 && gmx mdrun -v -deffnm $protein-$site-$spoint-$length-$center1-$center2-md -nt 1 && (echo 24;) | gmx angle -type dihedral -f $protein-$site-$spoint-$length-$center1-$center2-md.trr -n $protein-$site-dihedral1.ndx -od $protein-$site-$spoint-$length-$center1-$center2-md-dihedralDist1.xvg -ov $protein-$site-$spoint-$length-$center1-$center2-md-dihedralTime1.xvg -dt 1 -b $b && (echo 24;) | gmx angle -type dihedral -f $protein-$site-$spoint-$length-$center1-$center2-md.trr -n $protein-$site-dihedral2.ndx -od $protein-$site-$spoint-$length-$center1-$center2-md-dihedralDist2.xvg -ov $protein-$site-$spoint-$length-$center1-$center2-md-dihedralTime2.xvg -dt 1 -b $b && (echo 1; echo 0;) | gmx trjconv -f $protein-$site-$spoint-$length-$center1-$center2-md.trr -s $protein-$site-$spoint-$length-$center1-$center2-md.tpr -pbc mol -ur compact -center -o $protein-$site-$spoint-$length-$center1-$center2-md-temp.pdb -dt 1 && (echo 1; echo 1;) | gmx trjconv -f $protein-$site-$spoint-$length-$center1-$center2-md-temp.pdb -s $protein-$site-$spoint-$length-$center1-$center2-md.tpr -o $protein-$site-$spoint-$length-$center1-$center2-md.pdb -fit rot+trans -dt 1 && rm $protein-$site-$spoint-$length-$center1-$center2-md-temp.pdb && cp *dihedral*xvg $ORIGDIR/$protein-$site/$protein-$site-$spoint-$length/$protein-$site-$spoint-$length-$center1-$center2 && cp $protein-$site-$spoint-$length-$center1-$center2-*.pdb $ORIGDIR/$protein-$site/$protein-$site-$spoint-$length/$protein-$site-$spoint-$length-$center1-$center2 && cd $SCRDIR" >> $jobfile
    done
    done
done
done

#------------------------------------------------------
# Launcher variables
export LAUNCHER_PLUGIN_DIR=$LAUNCHER_DIR/plugins
export LAUNCHER_RMI=SLURM
export LAUNCHER_JOB_FILE=$jobfile                       # Job scripts
export LAUNCHER_WORKDIR=$SCRDIR                         # Directory launcher will execute
export LAUNCHER_SCHED=dynamic                           # Default - each task k executes first available unclaimed line
#------------------------------------------------------

# Launch launcher
$LAUNCHER_DIR/paramrun

# End of job
cd ~

