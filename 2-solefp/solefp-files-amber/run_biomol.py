#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
 SolEFP/EFP2 fragmentation model of biomolecule. 
 Development script.

 Usage: [pdb (MD snapshot)] [traj] [report]

"""
from sys import argv
if len(argv)==1: 
   print __doc__
   exit()

import solvshift.biomol
import sys

if __name__=='__main__':
     res    = 'gmx-charmm.tc'
     probe  = 'probe-charmm.tc'
     mode   =  4
     top    = sys.argv[1]
#gromacs .gro file with no redundant indexes (from multiple chains or other species): this is usually OK if the
#.gro file comes from after the production run
     traj   = sys.argv[2]
# the fully fixed version .xtc file
     report = sys.argv[3]
# this is the output file, in .dat format
     rcl_algorithm = sys.argv[4]
# additive or "remove_by_name" approach to polarization: we are most typically using "remove_by_name"
     conh = sys.argv[5]
# choice for amide bond model: usually "chonhme" but could be "comenh2" or "comenhme" ish
     solefp = solvshift.biomol.BiomoleculeFragmentation(\
                       res, probe, mode, solcamm=None, ccut=45.0, pcut=16.0, ecut=13.0,
                       repul=True,
                       lprint=False, write_solefp_input=False, write_debug_file=False,
                       report=report,
                       rcl_algorithm=rcl_algorithm, include_ions=True, include_polar=True)
# #cut specifies cutoffs for electronic, polarization, and exchange repulsion in that order, in Bohr radii;
# these are already pretty good, don't change
# then the T/F variables turn on or turn off different files: all three should be true or false at same time (all true
# for debugging
# the last two options include multi-body polarization and should always be true

     solefp.run(top, traj, dframes=1, nframes=25000, conh=conh, out_inp='biomolecule.inp')
