#!/usr/bin/env python
#*-* coding: utf-8 *-*
"""
 ---------------------------------------------------------------------------------------------------------
                                             SLV-MD
 ---------------------------------------------------------------------------------------------------------

This file was modified by Rosalind Xu 10/17 and 01/18 for SolEFP-IR of MeSCN in solvents.
(Originally named: slv_md-run_nopp)

 Calculate the frequency shifts from MD trajectory file.
 Formats currently supported:
   o DCD           (CHARMM, NAMD)
   o XTC           (GROMACS)
   o MDCRD, NETCDF (AMBER)
 
 Usage:
 
 ./md.py [nframes] [ccut,pcut,ecut] [mode] [mdinput] [top] [traj] [report_name] [write_debug_file]
  -n [nframes] --ccut [ccut] --pcut [pcut] --ecut [ecut] (or --cut [ccut,pcut,ecut]) 
  -m [mode] -i [mdinput] -t [top] -x [traj] -o [report_name] --debug [(switcher)write_debug_file]

  With the modified version (by RX), do:
  ./run_small.py -i [mdinput] -t [top] -x [traj] -o [report] --debug [(switcher)write_debug_file]
  --remove_clashes [(switcher)] --rcl_algorithm [additive or remove_by_name] --include_ions [(switcher)] --include_polar[(switcher)]

  Set --remove_clashes, --include_ions, --include_polar, and set --rcl_algorithm to remove_by_name
  (for MeSCN in polar solvent calculations, many-body polarizations can be important; but clashes between fragments can still occur)  
 ---------------------------------------------------------------------------------------------------------

 Options:

   -i     [inp]             SolEFP input
   -t     [top]             Topology file
   -x     [trj]             Trajectory file
   -o     [out]             Output file 
   -m     [mode]            Normal mode ID (descending order of frequencies, normal numbers)
   -n     [nframes]         Number of frames to read
   -d     [dnframes]        Stride in reading frames (NOT IMPLEMENTED YET)
   --cut  [a,b,c]           Cutoffs (in Bohr). a,b,c are Coul, Pol and Rep cutoffs
   --ccut [a]               Coulomb cutoff (Bohr)
   --pcut [b]               Polarization cutoff (Bohr)
   --ecut [c]               Exchange-repulsion cutoff (Bohr)
   --rcl_algorithm          Clash removal algorithm (additive or remove_by_name. Use remove_by_name.)


 Switchers:

   --no-elect               Switch off Coulomb shifts
   --no-polar               Switch off induction shifts
   --no-repul               Switch off exchange-repulsion shifts
   --no-disp                Switch off dispersion shifts
   --no-correc              Switch off Coulomb correction shifts
   --no-ea (-E)             Switch off electronic anharmonicity 
   --save-avec              Save solvatochromic induced dipoles and electric fields
   --debug                  Write SolEFP fragment debug file
   --remove_clashes         Remove polarization clashes between fragments (needed if fragmentation occurs)
   --include_ions           Include ionic fragments in the polarization layer (set to True if --remove_clashes)
   --include_polar          Include polar fragments in the polarization layer (set to True if --remove_clashes)

 ---------------------------------------------------------------------------------------------------------
                                                                               Last Revision: 3 Dec 2015
"""

from sys import argv, stdout, exit
from getopt import getopt, GetoptError

# ----------------------------------------------------------------------------------------------------
__title__           = " SLV-MD program" 
__authors__         = " Bartosz Błasiak (email: blasiak.bartosz@gmai.com)"
__version__         = " Version: 1.0.1"
# ----------------------------------------------------------------------------------------------------

def Usage():
    print __doc__
    exit()

def Info():
    print
    print __title__
    print __authors__
    print __version__
    print " Use -h to see help\n"
    exit()

def Main(argv):
    # defaults
    save_avec      = False                                             # whether to store avec and flds or not
    no_elect       = False                                             # whether to turn off Coulomb shifts or not
    no_polar       = False                                             # whether to turn off induction shifts or not
    no_repul       = False                                             # whether to turn off exchange-repulsion shifts or not
    no_disp        = False                                             # whether to turn off dispersion shifts or not
    no_correc      = False                                             # whether to turn off Coulomb correction shifts or not
    no_ea          = False                                             # whether to turn off electronic anharmonicity or not
    solinp, traj, top, out = None, None, None, None
    mode = 4
    nframes = 500000
    cuts = None
    ccut = 45.0 
    pcut = 16.0
    ecut = 13.0
    debug = 0
    remove_clashes = False
    rcl_algorithm = 'remove_by_name'
    include_ions = False
    include_polar = False
    
    #
    try:
       opts, args = getopt(argv, "hi:x:t:o:m:n:AC:X:X:X:EXXXXX:X:X:X:X:X" , ["help" , "inp=", "traj=", "top=", "out="
                                                                   "mode=", "nframes=", "save-avec",
                                                                   "cut=", "ccut=", "pcut=", "ecut=" , "no-ea",
                                                                   "no-elect", "no-polar", "no-repul", "no-disp", "no-correc", "debug", "remove_clashes", "rcl_algorithm=", "include_ions", "include_polar"])
    except GetoptError, error:
        print "\n Invalid option. Please refer to the usage below:" 
        Usage()
    if not opts: Info()
    if ("-h",'') in opts or ("--help",'') in opts: Usage()
    for opt, arg in opts:
        if opt in ("-h", "--help"       ): Usage()
        if opt in ("-i", "--inp"        ): solinp    = arg
        if opt in ("-x", "--traj"       ): traj      = arg
        if opt in ("-t", "--top"        ): top       = arg
        if opt in ("-o", "--out"        ): out       = arg
        if opt in ("-m", "--mode"       ): mode      = int(arg)
        if opt in ("-n", "--nframes"    ): nframes   = int(arg)
        if opt in ("-A", "--save-avec"  ): save_avec = True
        if opt in ("-E", "--no-ea"      ): no_ea     = True
        if opt in (      "--no-elect",  ): no_elect  = True
        if opt in (      "--no-polar",  ): no_polar  = True
        if opt in (      "--no-repul",  ): no_repul  = True
        if opt in (      "--no-disp" ,  ): no_disp   = True
        if opt in (      "--no-correc", ): no_correc = True
        if opt in ("-C", "--cut"        ): ccut, pcut, ecut = map(float, arg.split(','))
        if opt in (      "--ccut"    ,  ): ccut = float(arg) 
        if opt in (      "--pcut"    ,  ): pcut = float(arg) 
        if opt in (      "--ecut"    ,  ): ecut = float(arg)
        if opt in (      "--debug"   ,  ): debug   = 2 # = solvshift.solefp.eval.lwrite; debug file will be printed if lwrite > 1
        if opt in ( "--remove_clashes", ): remove_clashes = True
        if opt in (  "--rcl_algorithm", ): rcl_algorithm = arg
        if opt in (   "--include_ions", ): include_ions = True
        if opt in (  "--include_polar", ): include_polar = True
 
    cuts = (ccut, pcut, ecut)
    run(solinp, traj, top, out, mode, nframes, cuts, no_elect, no_polar, no_repul, no_disp, no_correc, no_ea, save_avec, debug, remove_clashes, rcl_algorithm, include_ions, include_polar)
    return

def eval_parall(efp, idx, args, frame, frame_idx, save_avec, debug, remove_clashes, rcl_algorithm, include_ions, include_polar):
    """evaluator for parallel run"""
    import libbbg.dma
    # eval
    efp.set(frame[idx], *args)
    efp.eval(lwrite=debug, remove_clashes=remove_clashes, rcl_algorithm=rcl_algorithm, include_ions=include_ions, include_polar=include_polar)
    # extract superimposition RMS
    rms_c = efp.get_rms()
    rms_s = efp.get_rms_sol()
    rms_a = efp.get_rms_ave()

    # extract shifts
    shifts = efp.get_shifts()
    SHIFTS = [ shifts[x] for x in ['solcamm','ele_mea','ele_ea','cor_mea','cor_ea',
                                   'pol_mea','pol_ea','rep_mea','rep_ea',
                                   'dis_mea','dis_ea','dis_mea_iso','total'] ]
    # extract solvatochromic induced dipoles and electric fields
    if save_avec:
       flds, rpol   = efp.get_fields()                              
       avec, rpol   = efp.get_avec()
       flds   = efp.transform_vec_to_bsm_orientation(flds, t=False)
       avec   = efp.transform_vec_to_bsm_orientation(avec, t=False)
       rpol   = efp.transform_vec_to_bsm_orientation(rpol, t=True)
       # write the output dma with solvatochromic induced dipoles
       dma = libbbg.dma.DMA(nfrag=len(avec))
       dma.set_moments(dipoles=avec)
       dma.set_structure(rpol, equal=True)
       dma.write('avec-%08i.dma' % frame_idx) 
       dma.set_moments(dipoles=flds)
       dma.write('flds-%08i.dma' % frame_idx)
       # sum the dipoles          
       avec   = avec.sum(axis=0) 
    # line of output frequencies and misc data
    log = "%8d" % frame_idx
    log+= len(SHIFTS) * " %10.2f" % tuple(SHIFTS)
    log+= " %10.5f %10.5f %10.5f" % (rms_c,rms_s,rms_a)
    if save_avec: log+= "%10.5f %10.5f %10.5f" % tuple(avec)
    log+='\n'
    return log


# main routine
def run(solinp, traj, top, out, mode, nframes, cuts, 
        no_elect, no_polar, no_repul, no_disp, no_correc, no_ea, save_avec, debug, remove_clashes, rcl_algorithm, include_ions, include_polar):
    report = out
    ccut, pcut, ecut = cuts
    #print no_elect, no_polar, no_repul, no_disp, no_correc, no_ea, save_avec

    # [0] import necessary modules
    from solvshift.md import MDInput
    from solvshift.solefp import EFP
    from MDAnalysis import Universe
    from libbbg.units import UNITS
    from numpy import array, zeros, arange, float64, float32
    stdout.flush()

    # [1] read the input
    input = MDInput(solinp)
    args, idx = input.get()
    
    # [2] initialize EFP object
    efp = EFP(elect=not no_elect, pol=not no_polar, rep=not no_repul, disp=not no_disp, corr=not no_correc,
              ccut=ccut, pcut=pcut, ecut=ecut,
              freq=True, cunit=True, mode=mode, ea=not no_ea)
    
    out = open(report, 'w')
    t = '%8s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s' % (\
                             '# Frame'.ljust(8),  'EL-CAMM'.rjust(10),
                             'EL-MEA' .rjust(10), 'EL-EA'  .rjust(10), 'CORR-MEA'.rjust(10),
                             'CORR-EA'.rjust(10), 'POL-MEA'.rjust(10),  'POL-EA' .rjust(10),
                             'REP-MEA'.rjust(10), 'REP-EA' .rjust(10), 'DISP-MEA'.rjust(10),
                            'DISP-EA' .rjust(10),'DISP-ISO'.rjust(10),  'TOTAL'  .rjust(10), 'RMS-C'   .rjust(10),
                            'RMS-S'   .rjust(10), 'RMS-AVE'.rjust(10))
    out.write(t+'\n')
    out.flush()
    
    # [3] read the trajectory file and initialize the frame of coordinates
    md     = Universe(top, traj)
    system = md.selectAtoms('all')
    
    # [4] iterate over frames and evaluate frequency shifts
    print
    print " SLV SolEFP calculations:"
    print " %10s %20s" % ('File'.rjust(10)  , traj.rjust(10))
    print " %10s %20d" % ('Frames'.rjust(10), nframes             ) 
    print
    for ts in md.trajectory:
        frame_no = ts.frame
        print " * Reading frame %10i" % frame_no           
        frame = system.atoms.coordinates() * UNITS.AngstromToBohr
        log = eval_parall(efp, idx, args, frame, frame_no, save_avec, debug, remove_clashes, rcl_algorithm, include_ions, include_polar)
        out.write(log)
        out.flush()
        if frame_no==nframes: break

# RUN SLV-MD
if __name__=='__main__': Main(argv[1:])
