#!/bin/bash                                                                                                     
#PBS -N ftir                                                                                        
#PBS -l nodes=n1:ppn=1                                                                                         
#PBS -j oe                                                                                                      
#PBS -k oe                                                                                                      
#PBS -V                                                                                                         
#PBS -M jxu@haverford.edu                                                                                       
#PBS -m bae

# Rosalind J. Xu 18' June 2018
# This script is part of the ir-md-fock series. This series should be run in sequence: run-trim-->(solefp-sub AND solefp)-->ftir.

protein=holo.cam
lengthfull=15ns #full length of each trajectory
num=20 #total number of trajectories
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


cd lineshape/lineshape-charmm-5/$protein/holo.cam-sites-n-15ns
for i in $(seq 0 $((num-1))); do
    site=${sitelist[$i]}
    spoint=${spointlist[$i]}
    length=${lengthlist[$i]}
    bgn=$(cut -d'_' -f1 <<< ${length%"ns"})
    end=$(cut -d'_' -f2 <<< ${length%"ns"})
    awk 'NR==1{print}' $protein-$site-$spoint-$lengthfull-remove_by_name-chonhme-processed.dat > $protein-$site-$spoint-$length-remove_by_name-chonhme-processed.dat
    awk -v bgn=$bgn -v end=$end 'NR==bgn*10000+2,NR==end*10000+2{print}' $protein-$site-$spoint-$lengthfull-remove_by_name-chonhme-processed.dat >> $protein-$site-$spoint-$length-remove_by_name-chonhme-processed.dat

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
