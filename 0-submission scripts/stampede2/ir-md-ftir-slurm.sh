#!/bin/bash

#SBATCH -J holo.cam-n-ftir                  # Job name
#SBATCH -o holo.cam-n-ftir.o%j              # Name of stdout output file
#SBATCH -e holo.cam-n-ftir.e%j              # Name of stderr error file
#SBATCH -p skx-normal                       # Queue (partition) name
#SBATCH -N 1                                # Total # of nodes
#SBATCH -n 1                                # Total # of mpi tasks (or number of MPI processes)
#SBATCH -t 02:00:00                         # Run time (hh:mm:ss)
#SBATCH --mail-user=jxu@haverford.edu       # E-mail address
#SBATCH --mail-type=all                     # Send email at begin and end of job (none for no emails)
#SBATCH -A Ras                     # Allocation name (req'd if you have more than 1)

# Rosalind J. Xu 18'  June 2018
# This script is part of the ir-md-slurm(stampede2) series. The ir-md series should be run in sequence: run-->trim-->{run-cont, dihedral-sasa, helix, solefp-->ftir}.
# The umbrella sampling scripts are independent from the above procedure but assume the same initial setup as ir-md-run-slurm.sh.
# This script calls rewrite_time.awk. Make sure the latter is put in the right place. slv_calc-expres can only function properly if the time sequence (column 1) is numbered from 0 at the correct spacing interval, in units of ps.
# For calculating IR Jct and lineshapes. Visualize results in xmgrace.

# Job variables
protein=holo.cam
term=n
lengthfull=15ns #full length of each trajectory
num=18 #total number of trajectories
# for each site-spoint-length combination, list in order
sitelist=(s17c s17c v35c s17c s17c v35c m72c m72c s17c s17c v35c s17c v35c m72c m72c s17c v35c m72c)
spointlist=(n.1 n.1 n.1 n.2 n.2 n.2 n.2 n.2 n.3 n.3 n.3 n.4 n.4 n.4 n.5 n.6 n.6 n.6)
lengthlist=(0_1ns 4_5ns 1_6ns 0_3ns 7_11ns 0_7ns 0_2ns 6_15ns 1_5ns 13_15ns 0_7ns 7_12ns 1_2ns 0_15ns 11_15ns 1_15ns 1_15ns 0_15ns) #in the format of [b]_[e]ns
dsample=100 #fs; sample interval in frequency trajectory

dlist=(100fs)  #data spacing for lineshape  
maxdelay=16ps  #maximum delay time for Jct
delaylist=(4ps 8ps 12ps 16ps)  #Fourier transform for a list of Jct delay times (<maxdelay)

c=20 #column of frequency data in frequency file
# list central frequencies in order of $site-$spoint-$length
w=(2164.43 2163.76 2157.68 2161.18 2149.36 2158.31 2159.64 2155.09 2164.86 2155.21 2165.33 2163.62 2161.96 2154.67 2151.64 2156.86 2155.63 2150.21) #cm^-1;
T1=50.0 #ps; vibrational lifetime for SCN
wmax=3000.0 #cm^-1; maximum integration window
wmin=1500.0 #cm^-1; minimum integration window

# Create $SCRDIR
ORIGDIR=$HOME/lineshape/lineshape-charmm-5/$protein/$protein-sites-$term-$lengthfull
SCRDIR=$SCRATCH/lineshape/lineshape-charmm-5/$protein/$protein-sites-$term-$lengthfull
mkdir -p $SCRDIR
cp $ORIGDIR/* $SCRDIR
cp lineshape/scripts/rewrite_time.awk $SCRDIR
cd $SCRDIR

# Job scripts
for i in $(seq 0 $((num-1))); do
    site=${sitelist[$i]}
    spoint=${spointlist[$i]}
    length=${lengthlist[$i]}
    bgn=$(cut -d'_' -f1 <<< ${length%"ns"})
    end=$(cut -d'_' -f2 <<< ${length%"ns"})
    awk 'NR==1{print}' $protein-$site-$spoint-$lengthfull-remove_by_name-chonhme-processed.dat > $protein-$site-$spoint-$length-remove_by_name-chonhme.dat
    awk -v bgn=$bgn -v end=$end 'NR==bgn*10000+2,NR==end*10000+2{print}' $protein-$site-$spoint-$lengthfull-remove_by_name-chonhme-processed.dat >> $protein-$site-$spoint-$length-remove_by_name-chonhme.dat
    (echo $protein-$site-$spoint-$length-remove_by_name-chonhme.dat; echo 1; echo 0.000; echo 0.100; echo 1;) | ./rewrite_time.awk    

    w0=${w[$i]}
    for d in ${dlist[*]}; do
        awk 'NR==1{print}' $protein-$site-$spoint-$length-remove_by_name-chonhme-processed.dat > $protein-$site-$spoint-$length-$d-lineshape.dat
        awk -v d=$((${d%fs}/dsample)) 'BEGIN{count=0} NR>1{count+=1; if(count % d == 0){print}}' $protein-$site-$spoint-$length-remove_by_name-chonhme-processed.dat >> $protein-$site-$spoint-$length-$d-lineshape.dat
        slv_calc-expres -i $protein-$site-$spoint-$length-$d-lineshape.dat -n $((${maxdelay%ps}*1000/${d%fs})) -d ${d%fs} -c $c -o $protein-$site-$spoint-$length-$d-$maxdelay-Jct.dat
        for delay in ${delaylist[*]}; do
            if [ $delay != $maxdelay ]; then
                nrecords=$((${delay%ps}*1000/${d%fs}+1))
                awk -v nrecords=$nrecords 'NR==1,NR==nrecords+1{print}' $protein-$site-$spoint-$length-$d-$maxdelay-Jct.dat > $protein-$site-$spoint-$length-$d-$delay-Jct.dat
            fi
            slv_calc-ftir -m classical -i $protein-$site-$spoint-$length-$d-$delay-Jct.dat -n $((${delay%ps}*1000/${d%fs})) -w $w0 -d ${d%fs} -T $T1 --w-max $wmax --w-min $wmin -o $protein-$site-$spoint-$length-$d-$delay-ftir.dat
        done
    done

done

# End of job: sync $ORIGDIR with $SCRDIR
mkdir $ORIGDIR/$protein-$term-lineshape
cp $SCRDIR/*Jct* $ORIGDIR/$protein-$term-lineshape
cp $SCRDIR/*ftir* $ORIGDIR/$protein-$term-lineshape
cd ~
