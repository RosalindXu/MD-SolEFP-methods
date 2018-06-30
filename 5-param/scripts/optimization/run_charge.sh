#!/bin/bash

echo "Before running this script, change the orientation and initial scan distance list."
read -p "Working directory (full path name; do not type "."!): " dir
read -p "Trial No.: "  tr
read -p "Number of charge combinations to be tested: " nComb
echo "Before you continue, place mescn-1.itp to mescn-$nComb.itp in $dir/itp."
echo "In addition, place all QM .xyz trajectories in $dir/trj."
read -p "Name of compound: " compound
read -p "total number of atoms in dimer: " natoms
read -p "number of frames in PES scan trajectory: " nframes
read -p "QM PES scan increment: " incre

#Change the list of orientations(ort) and initial scan distances(initD) here
water_ort=( KNwater1 KNwater2 KCwater3 KSwater1 KSwater2 )
water_initD=( 2.50 2.50 2.50 2.50 2.50 )
nOrt=5
#Gas phase tip3p water energy
waterE=0.000873

cd $dir

# folder structure: dimer (i) - LJcomb (j) - orientation (k)
# preparing .tpr file for each dimer and LJcomb
for i in water gas ; do
	mkdir $compound-$i/trial-$tr

	for j in $(seq 1 $nComb); do
		subdir=$compound-$i/trial-$tr/LJcomb-$j
		mkdir $subdir
		cp $compound-$i/$compound-$i.gro $subdir
		cp $compound-$i/$compound-$i.top $subdir
		cp $compound-$i/em.mdp $subdir
		cp itp/mescn-$j.itp $subdir/mescn.itp
		if [[ $i != gas ]]; then
			cp $compound-$i/tip3p.itp $subdir
		fi
		
		cd $subdir 
		gmx grompp -f em.mdp -c $compound-$i.gro -p $compound-$i.top -o $compound-$i-$j.tpr
			
		if [[ $i == "water" ]]; then
			for k in $(seq 1 $nOrt); do
				subsubdir=${water_ort[$((k-1))]}-$j
				mkdir $subsubdir
				cp $compound-$i-$j.tpr $subsubdir/${water_ort[$((k-1))]}-$j.tpr
			done	
			rm $compound-$i-$j.tpr
		fi
	    cd $dir		
	done
done

# folder structure: dimer (i) - LJcomb (j) - orientation (k)
# preparing .gro trajectory for each dimer and orientation
cd $dir/trj
for i in water; do
    for k in ${water_ort[*]}; do
        (echo "$k-scan.xyz"; echo $k ; echo $natoms; echo $nframes;) | $dir/xyz_to_gro-charge.awk
        for j in $(seq 1 $nComb); do
            cp $k-scan.gro $dir/$compound-$i/trial-$tr/LJcomb-$j/$k-$j
        done
	done
done
rm *.gro
cd $dir

# folder structure: dimer (i) - LJcomb (j) - orientation (k)
# Obtain MM PES
for i in gas water; do
    for j in $(seq 1 $nComb); do
    if [[ $i == gas ]]; then
        cd $compound-$i/trial-$tr/LJcomb-$j
        gmx mdrun -v -deffnm $compound-$i-$j
        echo "11 0" | gmx energy -f $compound-$i-$j.edr -o $compound-$i-$j-ener.xvg
        grep -v "^@" $compound-$i-$j-ener.xvg | grep -v "^#" > temp.dat
        gasE[$j]=$( awk '{print $2}' temp.dat )
        rm temp.dat
        cd $dir

    elif [[ $i == "water" ]]; then
    mkdir MeSCN-$i/trial-$tr/PES
        for k in $(seq 1 $nOrt); do
            cd $compound-$i/trial-$tr/LJcomb-$j/${water_ort[$((k-1))]}-$j
            gmx mdrun -v -deffnm ${water_ort[$((k-1))]}-$j -rerun ${water_ort[$((k-1))]}-scan.gro
            echo "11 0" | gmx energy -f ${water_ort[$((k-1))]}-$j.edr -o ${water_ort[$((k-1))]}-$j-ener.xvg
            grep -v "^@" ${water_ort[$((k-1))]}-$j-ener.xvg | grep -v "^#" |
            awk -v gasE=${gasE[$j]} -v nframes=$nframes -v initD=${water_initD[$((k-1))]} -v incre=$incre -v waterE=$waterE 'NR==1,NR==$nframes{printf("%3.2f %f\n", initD+(NR-1)*incre, $2-gasE-waterE)}' > ${water_ort[$((k-1))]}-$j-MM-PES.dat
            cp ${water_ort[$((k-1))]}-$j-MM-PES.dat $dir/MeSCN-$i/trial-$tr/PES
            cd $dir
        done
    fi
    done
done

# folder structure: dimer (i) - LJcomb (j) - orientation (k)
# find minimum interaction energies and distances
for i in water; do
    cd $dir/MeSCN-$i/trial-$tr/PES
    for k in $(seq 1 $nOrt); do
        for j in $(seq 1 $nComb); do
            (echo "MM"; echo ${water_ort[$((k-1))]}; echo $j;) | $dir/find_min.awk >> $dir/MeSCN-$i/trial-$tr/MeSCN-$i-MM-trial-$tr-summary.dat
        done
    done
    cd $dir
done



