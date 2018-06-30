# Adapted from Dan 16' code#
# Rosalind J. Xu 18', Spring 2018
#if needs to change torsion, please do so in graphic interface.

import os
import chimera
import re
from chimera.molEdit import addAtom, addBond
from chimera import Element, Point, Bond
from chimera import runCommand as rc
from chimera import replyobj
from chimera import openModels, Molecule, Element, Coord
from math import radians, sin, cos

###working directory###
workdir = "/Users/Sherina/Desktop/"                                          
os.chdir(workdir)
###name of protein###
protein = "holo.cam"
###residue numbers (chimera index) and corresponding names of the sites to cyanylate###
residue_numbers = [":17.A",":35.A",":72.A"]
sites = ["s17c","v35c","m72c"] 
###name of .pdb files and corresponding spoints###
pdbs = ["reps_nterm_4cal1.pdb-test.pdb","reps_nterm_4cal2.pdb-test.pdb",
        "reps_nterm_4cal3.pdb-test.pdb","reps_nterm_4cal4.pdb-test.pdb",
        "reps_nterm_4cal5.pdb-test.pdb","reps_nterm_4cal6.pdb-test.pdb"]
spoints = ["n.1","n.2","n.3","n.4","n.5","n.6"]                                              
###water/ion residue specifiers in .pdb files###
water_ion_names = [":SOD", ":CLA", ":HOH"]
###length specification###
length = "15ns"                                                              


#define the "CN residue"
def createCN(): 						
		cn= Molecule() 					# create an instance of a molecule

		# r = cn.newResidue(residue type, chain identifier, sequence number, insertion code)
		r = cn.newResidue("cn", " ", 1, " ")

		atomC = cn.newAtom("CE", Element("C")) 				# now create the atoms of the residue. 
		atomN = cn.newAtom("NF", Element("N"))

		bondLength_cn = 1.156
		
		atomC.setCoord(Coord(0, 0, 0))
		atomN.setCoord(Coord(bondLength_cn, 0, 0))
		
		r.addAtom(atomC)
		r.addAtom(atomN)

		cn.newBond(atomC, atomN)
		openModels.add([cn])

assert len(residue_numbers) == len(sites)
assert len(pdbs) == len(spoints)

for i in range(len(residue_numbers)):
    res = residue_numbers[i]
    site = sites[i]
    for j in range(len(pdbs)):
        pdb = pdbs[j]
        spoint = spoints[j]
        
        fn = protein+"-"+site+"-"+spoint+"-"+length
        replyobj.status("Processing " + fn) 		# print current file 
        createCN()	# creates CN "residue"
            
        rc("open " + workdir + pdb)
        rc("select " + res)
        for ion in water_ion_names:
            rc("~select " + ion)
        rc("swapaa cys selected criteria chp")
     	rc("select #0#1")
        rc("combine selected close true")
        rc("bond #2:cn@CE#2:CYS@SG")
        rc("adjust length 1.688 #2:CYS@SG#2:cn@CE")
        rc("adjust angle 100.6 #2:cn@CE#2:CYS@SG#2:CYS@CB")
        rc("adjust angle 177.80 #2:cn@NF#2:cn@CE#2:CYS@SG")
        #Caution in adjust angle: if you want atom A to be moved and atom B to be fixed,
        # list atom A before atom B. And always check structure in graphic interface!
        #if needs to change torsion, please do so in graphical interface of pymol. 
    
        rc("select #2:CYS@SG")
        cys = chimera.selection.currentResidues()[0]
        rc("select #2:cn@CE")
        cn = chimera.selection.currentResidues()[0]
        for a in cn.atoms:
	    cn.removeAtom(a)
	    cys.addAtom(a)
        cys.type = "MSCN"
        cn.molecule.deleteResidue(cn)
        s = cys.findAtom("SG")
        cys.removeAtom(s)
        s.name = "SD"
        cys.addAtom(s)
        rc("ribbon")
        rc("focus #2:MSCN")

        rc("write format pdb #2 "+fn+"-initial.pdb")		
        rc("close all")
