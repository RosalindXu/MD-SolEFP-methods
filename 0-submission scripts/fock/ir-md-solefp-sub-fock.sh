#!/bin/bash

# $protein, $site, $proc, $spoint
# $j, ${rcl_algorithm}, $conh
# $n, $p

# Rosalind J. Xu 18' June 2018
# This script is part of the ir-md-fock series. This series should be run in sequence: run-trim-->(solefp-sub AND solefp)-->ftir.
# This script submits ir-md-solefp-fock.sh. Run this script in command line (./ir-md-solefp-sub-fock.sh) for submitting ir-md-solefp-fock.sh.

protein=1cll
site=l105c
proc=125.0ns-20ns-ls-5ns
dir=$HOME/solefp/1cll-l105c/1cll-l105c-125.0ns-20ns/1cll-l105c-125.0ns-20ns-ls-5ns

# number of the first node
n=10
# number of jobs per node
p=12
# initialize counter for node allocation
c=0
# number of parts
part=84

# choice for rcl_algorithm: additive and remove_by_name. remove_by_name is recommended.
# choice for conh: chonhme and comenh2. chonhme is recommended.

# loop through parameters
for rcl_algorithm in "remove_by_name" ; do
	for conh in "chonhme" ; do
		for j in $(seq 0 $((part-1))); do
        	        m=$((n + (c-(c%p))/p))
			c=$((c+1))
			qsub -l nodes=n$m:ppn=1 -v protein=$protein,site=$site,proc=$proc,j=$j,rcl_algorithm=${rcl_algorithm},conh=$conh,dir=$dir SolEFP_v3.sh
		done
	done
done
