#!/bin/bash

#SBATCH -J holo.cam-s17c-n.1-15ns-solefp     # Job name
#SBATCH -o holo.cam-s17c-n.1-15ns-solefp.o%j # Name of stdout output file
#SBATCH -e holo.cam-s17c-n.1-15ns-solefp.e%j # Name of stderr error file
#SBATCH -p skx-normal                       # Queue (partition) name
#SBATCH -N 1                                # Total # of nodes
#SBATCH -n 48                               # Total # of mpi tasks (or number of MPI processes)
#SBATCH -t 40:00:00                         # Run time (hh:mm:ss)
#SBATCH --mail-user=jxu@haverford.edu       # E-mail address
#SBATCH --mail-type=all                     # Send email at begin and end of job (none for no emails)
#SBATCH -A TG-MCB180055	                    # Allocation name (req'd if you have more than 1)

# Rosalind J. Xu 18'  June 2018
# This script is part of the ir-md-slurm(stampede2) series. The ir-md series should be run in sequence: run-->trim-->{run-cont, dihedral-sasa, helix, solefp-->ftir}.
# The umbrella sampling scripts are independent from the above procedure but assume the same initial setup as ir-md-run-slurm.sh.
# This script does solefp calculations. You also need to put solefp-files-charmm or solefp-files-amber in the right place (see below for where either directory is needed). The two directorys can be found in MD-SolEFP-methods/SolEFP.
# You may not have $protein-$site-$spoint-$length-solefp.gro, depending on your setup procedure. If you do not have $protein-$site-$spoint-$length-solefp.gro, use the .gro output from the latest md run instead (should be called $protein-$site-$spoint-$length.gro).

# Job variables
protein=$protein
site=$site
spoint=$spoint
length=$length
npart=48      #number of trajectory partitions
rcl_algorithm=remove_by_name    # choice for rcl_algorithm: additive and remove_by_name. remove_by_name is recommended.
conh=chonhme    # choice for conh: chonhme and comenh2. chonhme is recommended.

# Create $SCRATCH
ORIGDIR=$HOME/solefp/solefp-charmm-5/$protein/$protein-$site/$protein-$site-$spoint-$length
SCRDIR=$SCRATCH/solefp/solefp-charmm-5/$protein/$protein-$site/$protein-$site-$spoint-$length
MDDIR=$SCRATCH/gmx/md-charmm-5/$protein/$protein-$site/$protein-$site-$spoint-$length
mkdir -p $ORIGDIR
mkdir -p $SCRDIR
cd $SCRDIR
jobfile=$protein-$site-$spoint-$length-solefp.launcher
rm $jobfile  #Clear previous jobfile
for j in $(seq 0 $((npart-1))); do
    echo "mkdir $protein-$site-$spoint-$length-$j && cp $HOME/solefp/solefp-files-charmm/probe-charmm.tc $protein-$site-$spoint-$length-$j && cp $HOME/solefp/solefp-files-charmm/gmx-charmm.tc $protein-$site-$spoint-$length-$j && cp $HOME/solefp/solefp-files-charmm/run_biomol.py $protein-$site-$spoint-$length-$j && cp $MDDIR/$protein-$site-$spoint-$length-solefp.gro $protein-$site-$spoint-$length-$j && mv $MDDIR/$protein-$site-$spoint-$length-$j.xtc $protein-$site-$spoint-$length-$j && cd $protein-$site-$spoint-$length-$j && python run_biomol.py $protein-$site-$spoint-$length-solefp.gro $protein-$site-$spoint-$length-$j.xtc $protein-$site-$spoint-$length-${rcl_algorithm}-$conh-$j.dat ${rcl_algorithm} $conh > $protein-$site-$spoint-$length-${rcl_algorithm}-$conh-$j.out && cd .." >> $jobfile
done

#------------------------------------------------------
# Launcher variables
export LAUNCHER_PLUGIN_DIR=$LAUNCHER_DIR/plugins
export LAUNCHER_RMI=SLURM
export LAUNCHER_JOB_FILE=$jobfile                       # Job scripts
export LAUNCHER_WORKDIR=$SCRDIR                         # Directory launcher will execute
export LAUNCHER_SCHED=dynamic                           # Default - each task k executes first available unclaimed line
#------------------------------------------------------

# Job scripts
$LAUNCHER_DIR/paramrun

# End of job: copy .dat file to $ORIGDIR
cd $SCRDIR
awk 'NR==1{print}' $protein-$site-$spoint-$length-0/$protein-$site-$spoint-$length-${rcl_algorithm}-$conh-0.dat > $protein-$site-$spoint-$length-${rcl_algorithm}-$conh.dat
for j in $(seq 0 $((npart-1))); do
    awk 'NR>1{print}' $protein-$site-$spoint-$length-$j/$protein-$site-$spoint-$length-${rcl_algorithm}-$conh-$j.dat >> $protein-$site-$spoint-$length-${rcl_algorithm}-$conh.dat
done
cp $SCRDIR/$jobfile $ORIGDIR
cp $SCRDIR/$protein-$site-$spoint-$length-${rcl_algorithm}-$conh.dat $ORIGDIR
cd ~

