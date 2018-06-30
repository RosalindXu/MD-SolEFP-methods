# Rosalind J. Xu 18' June 2018
# For CHARMM36 forcefield
# See cyanylation / gromacs input processing protocols for usage
# if you wish to keep the Hs from PDB file while there are name mismatches (etc., H2 in place of H1), use this program (with modifications)
# enter file name
read -p "input .pdb file name: " inFile

awk '{if($4=="MSCNB"){sub(/HETATM/,"ATOM  ");print;}
else{if($4=="ASP" || $4=="PHE" || $4=="ASN" || $4=="TYR"|| $4=="LEU"|| $4=="TRP"){
	sub(/HB2/,"HB1");
	sub(/HB3/,"HB2");
	print}
	else{
    if($4=="GLU" || $4=="GLN" || $4=="MET"){
        sub(/HG2/,"HG1");
        sub(/HG3/,"HG2");
        sub(/HB2/,"HB1");
        sub(/HB3/,"HB2");
        print
        }
    else{
        if($4=="LYS"|| $4=="ARG"|| $4=="PRO"){
        	sub(/HB2/,"HB1");
        	sub(/HB3/,"HB2");
        	sub(/HG2/,"HG1");
        	sub(/HG3/,"HG2");
        	sub(/HD2/,"HD1");
        	sub(/HD3/,"HD2");
        	sub(/HE2/,"HE1");
        	sub(/HE3/,"HE2");
        	print
        	}
         else{
             if($4=="ILE"){
                 sub(/HG12/,"HG11");
                 sub(/HG13/,"HG12");
                 print
                 }
             else{
                 if($4=="GLY"){
                     sub(/HA2/,"HA1");
                     sub(/HA3/,"HA2");
                     print
                     }
                 else{
                     if($4=="HSD"){
                         sub(/HB2/,"HB1");
                         sub(/HB3/,"HB2");
                         print
                         }
                     else{
                        if($4=="SER"){
                           sub(/HB2/,"HB1");
	                       sub(/HB3/,"HB2");
	                       sub(/HG /,"HG1");
	                       print
                           }
                        else{
                            if($4=="HOH" || $3=="HOH"){
                              sub(/O /,"OW");
                              sub(/H1 /,"HW1");
                              sub(/H2 /,"HW2");
                              print
                            }
                            else{
                                  print
                                  }
                             }     
                           }
                        }
                     }
                 }
             }
        }
    }
}' $inFile > $inFile-test.pdb