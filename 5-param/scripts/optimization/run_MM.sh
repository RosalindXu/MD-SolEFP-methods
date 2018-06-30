 #!/bin/bash

echo " "
echo "This program automates the MM calculation of binding energies for the purpose of PES charge fitting. Rosalind J. Xu 07/17"
echo " " 
echo "BEFORE USE, DO: "
echo " "
echo "1. Change GMXRC directory and GMXLIB path "
echo "2. Open trj_to_gro.awk and change the residue and atom lists "
echo " "
echo "3. Prepare a folder (working directory), with subfolders each for each compound-water dimer, as well as one for the gas phase compound;"
echo "	a. Example subfolder name: MeSCN for the compound; KN-water-1 for MeSCN...HOH, configuration 1, etc." 
echo "	b. In the working directory, put: md.mdp (nsteps=1); water.top (.top file for dimer); MeSCN.itp (with a set of charges to be tested); tip3p.itp (from CHARMM36m); trj_to_gro.awk (converts .xyz to .gro)"
echo "	c. In each subfolder for dimers, put: .xyz trajectory of PES scan (.xyz trajectory of the water moving relative to compound)" 
echo "	d. In subfolder for gas phase compound, put: .gro file for its structure; MeSCN.top (.top file for gas-phase compound)"
echo " "
echo "4. You can calculate the MM potential energy of tip3p water separately. The value will be asked for near the end of the program." 
echo " "

# GMXRC and GMXLIB: change here
source /usr/local/gromacs/bin/GMXRC
export GMXLIB=/users/sherina/desktop/forcefields

# Enter trial number and total number of steps, initial distance and increment here: "
read -p "Trial No.:  " No
read -p "Name of compound (also name of the corresponding subdirectory): " compound
read -p "Number of atoms in dimer (compound + water): " natoms
read -p "Number of QM PES scan steps: " nframes
read -p "Initial interaction distance in QM PES scan in angstrom: " initD
read -p "QM PES scan increment: " incre 

read -p "Working directory: " WD 
cd $WD

# Test if $WD/[dimer]/gro already exists; if no, run trj_to_gro.awk. 
for folder in *; do	
	if [[ -d $folder ]] && [[ ! -d $folder/gro ]] && [[ $folder != $compound ]]; then
	    cd $folder
	     
   		(echo "*.xyz"; echo $natoms; echo $nframes)| ../trj_to_gro.awk
   		
   		cd ..
	fi	
done

# Prepare each folder for MD run 
for folder in *; do
    if [[ -d $folder ]]; then
		mkdir $folder/Trial-$No
		
		if [[ $folder != $compound ]]; then
			for i in $(seq 1 $nframes); do
				mkdir $folder/Trial-$No/Step-$i
				cp md.mdp $folder/Trial-$No/Step-$i/
				cp water.top $folder/Trial-$No/Step-$i/
	   	   	    cp $compound.itp $folder/Trial-$No/Step-$i/
	    		cp tip3p.itp $folder/Trial-$No/Step-$i/
	    		cp $folder/gro/step-$i.gro $folder/Trial-$No/Step-$i/
	   		 done
	   		 
	   	else
	   		cp md.mdp $folder/Trial-$No/
	   		cp $compound.itp $folder/Trial-$No/
	   		cp $folder/*.gro $folder/Trial-$No/	
	   		cp $folder/*.top $folder/Trial-$No/
	   		   	
	   	fi	
	fi	   	
done

# Run MD for each dimer or compound; process energies
for folder in *; do
if [[ -d $folder ]]; then
	cd $folder/Trial-$No
	name=${folder//"-"/}
	
	if [[ $name != $compound ]]; then	
		for i in $(seq 1 $nframes); do
			cd Step-$i
				gmx grompp -f md.mdp -c step-$i.gro -p *.top -o $name-$i.tpr
				gmx mdrun -deffnm $name-$i
				rm $name-$i.gro
				rm $name-$i.trr
				# Extract potential energy (Choice #11)
				echo "11 0" | gmx energy -f $name-$i.edr -o $name-$i.xvg
           	    grep -v "^@" $name-$i.xvg | grep -v "^#" > $name-$i.dat	
           	 	awk -v i=$i 'NR==1{print i, $2}' $name-$i.dat >> ../$name-dimer-$No.dat
			cd ..	
		done
		
	else
		gmx grompp -f md.mdp -c *.gro -p *.top -o $name.tpr
		gmx mdrun -deffnm $name
		rm $name.gro
		rm $name.trr
		mv \#$name.gro.1\# $name.gro
		# Extract potential energy (Choice #11)
		echo "11 0" | gmx energy -f $name.edr -o $name.xvg
		grep -v "^@" $name.xvg | grep -v "^#" > $name-gas-$No.dat	
	fi
	
	cd ../..
fi
done

# Calculate MM binding energies
# Energy of compound 
cd $compound/Trial-$No
	compoundE=$(awk 'NR==1{print $2}' $compound-gas-$No.dat)
cd ../..

# Energy of water
read -p "MM energy of tip3p water in kJ/mol: " waterE

# MM binding energy
for folder in *; do
if [[ -d $folder ]] && [[ $folder != $compound ]]; then
	cd $folder/Trial-$No
	name=${folder//"-"/}
	awk -v compoundE=$compoundE -v waterE=$waterE -v nframes=$nframes -v initD=$initD -v incre=$incre 'NR==1,NR==$nframes{printf("%2.1f %f\n", initD+(NR-1)*incre, $2-compoundE-waterE)}' $name-dimer-$No.dat > $name-MM-$No.dat
	rm $name-dimer-$No.dat 
	cd ../..
fi
done

echo "Please find the MM binding energies entered in Trial-$No inside each subdirectory. Plot and compare to QM energies."
