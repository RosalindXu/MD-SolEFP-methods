# Rosalind J. Xu 18' June 2018
# For converting an AMBER99sb .pdb file to a CHARMM36 .pdb file (by renaming some of the hydrogens)
# See cyanylation / gromacs input processing protocols for usage
# if you wish to keep the Hs from PDB file while there are name mismatches (etc., H2 in place of H1), use this program (with modifications)
# enter file name
read -p "input .pdb file name: " inFile

awk '{

if ($4=="SER"){
	sub(/HG1/,"HG ");
	print
	}
	else{
	if($4=="HSD"){
		sub(/HSD/,"HID")
		print
		}
	else{
	if($4=="CAL"){
		gsub(/CAL/,"CA ")
		print
		}
	else{
			print
		}
		}
	}	
}' $inFile > $inFile-test.pdb