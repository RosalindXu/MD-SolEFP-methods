#!/bin/bash

# This script automates the submission of QMMM jobs

protein=2BBM
site=4.B
proc=10ns
spoint=100.0ns

# number of parts
part=48
# number of jobs per node
k=12
# number of first node
n=1

# loop through the fragments
for j in $(seq 0 $((part-1))); do
	m=$((n + (j-(j%k))/k))
	qsub -l nodes=n$m:ppn=1 -v protein=$protein,site=$site,proc=$proc,spoint=$spoint,j=$j QMMM.sh
done
