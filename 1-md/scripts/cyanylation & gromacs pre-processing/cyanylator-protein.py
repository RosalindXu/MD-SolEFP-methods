# Adapted from Dan 16' code#
# Rosalind J. Xu 18', Fall 2016
# Cyanylate a protein from PDB code
# If needs to change torsion, please do so in graphic interface.

import os
import chimera
import re
from chimera.molEdit import addAtom, addBond
from chimera import Element, Point, Bond
from chimera import runCommand as rc
from chimera import replyobj
from chimera import openModels, Molecule, Element, Coord
from math import radians, sin, cos


os.chdir("/Users/Sherina/Desktop/trial MD/")              ###change here for working directory###
protein = "2BBM"                                                             ###change here for name of protein###
residue_numbers = [":4.B",":8.B",":12.B",":16.B",":20.B",":23.B"]            #### change here to choose sites to cynaylate#####

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


for res in residue_numbers:
        fn = protein+”_”+res[1:]
        os.mkdir(fn)
	replyobj.status("Processing " + fn) 		# print current file 
	createCN()	# creates CN "residue"
	
	rc("open " + protein) 
	rc("swapaa cys " + res)
	rc("show:cys")
	rc("~ribbon")
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

	rc("write format pdb #2 " + fn+"/"+fn+".pdb")		
        rc("close all")
