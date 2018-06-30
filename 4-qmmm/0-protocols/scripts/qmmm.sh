#!/bin/bash

#PBS -N QMMM
#PBS -j oe                                                                                                      
#PBS -k oe                                                                                                      
#PBS -V                                                                                                         
#PBS -M jxu@haverford.edu                                                                                       
#PBS -m n

dir=$HOME/QMMM/$protein\_$site/$protein-$site-$proc-$spoint/$protein-$site-$proc-$spoint-$j
mkdir $dir

cd $HOME/QMMM/$protein\_$site/$protein-$site-$proc-$spoint
cp oPM3_combined $dir/
cp pm3.prm $dir/
cp input $dir/
cp conf.gro $dir/
cp topol.top $dir/
mv ~/$protein\_$site/$protein-$site-$proc-$spoint/$protein-$site-$proc-$spoint-$j.xtc $dir/traj.xtc
cd $dir

./oPM3_combined

