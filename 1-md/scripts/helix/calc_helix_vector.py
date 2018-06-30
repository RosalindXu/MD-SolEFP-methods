### Modified from functions provided by Annie Westerlund
### Rosalind J.Xu 18' June 2018 (takes md trajectory and topology files as input)
### Calculates helix vectors
### There is a size limit to how large a trajectory can be loaded -- if getting memory errors, try and reduce the number of frames (10 ps spacing between frames is sufficient)

from sys import argv
if len(argv)==1: 
   print __doc__
   exit()
   
import mdtraj as md
import argparse
import numpy as np
from sklearn.decomposition import PCA

# Name of topology file
top_name = argv[1]
# Name of trajectory
traj_name = argv[2]
# Output file name stem
out_stem = argv[3]


# Import trajectory
traj = md.load_xtc(traj_name,top_name)


# Define helix indexes
print('Computing helix direction');
helix_inds = [0,0,0,0,0,0,0,0];
helix_inds[0] = traj.topology.select('residue 13 to 18'); # 13 to 18 for holo, 6 to 18 for apo
helix_inds[1] = traj.topology.select('residue 29 to 38');
helix_inds[2] = traj.topology.select('residue 45 to 54');
helix_inds[3] = traj.topology.select('residue 65 to 74');
helix_inds[4] = traj.topology.select('residue 83 to 91');
helix_inds[5] = traj.topology.select('residue 102 to 111');
helix_inds[6] = traj.topology.select('residue 118 to 127');
helix_inds[7] = traj.topology.select('residue 139 to 145');

helix_parts = ['A','B','C','D','E','F','G','H'];

# Main function from helix_geometry.py
def computeHelixDirection(traj, part):
        print "Computing helix direction for helix " + part
	# Computes the direction of the helix (traj) as the principal eigenvector.
	# Get the atoms to use in PCA
	# The backbone atoms CA, N, C are all called C_alpha
	C_alpha_indices = traj.topology.select("protein and (name CA or name N or name C)");
	CA_points = traj.atom_slice(C_alpha_indices).xyz;
	nFrames = int(traj.n_frames);		
		
	xy_coeff = np.zeros((nFrames,2));
	xz_coeff = np.zeros((nFrames,2));
		
	helix_direction = np.zeros((nFrames,3));
		
		
	for i in range(0,nFrames):
		data = CA_points[i,::,::];
			
		# Subtract centroid
		mu = data.mean(axis=0);
		data = data - mu;
		pca = PCA();	
		pca.fit(data);
		eigenvector = pca.components_[0,::];

		# Pick eigenvector that points in the direction of the atom sequence
		ref_line = data[-1,::]-data[0,::];			
		ref_line_pi_deg = data[0,::]-data[-1,::];
			
		# Normalize the vectors
		norm_ = (ref_line[0]**2 + ref_line[1]**2 + ref_line[2]**2);
		ref_line = ref_line/norm_;
		ref_line_pi_deg = ref_line_pi_deg/norm_;

		# Compute distance between eigenvector and reference lines
		diff1 = (ref_line[0]-eigenvector[0])**2+(ref_line[1]-eigenvector[1])**2+(ref_line[2]-eigenvector[2])**2;
		diff2 = (ref_line_pi_deg[0]-eigenvector[0])**2+(ref_line_pi_deg[1]-eigenvector[1])**2+(ref_line_pi_deg[2]-eigenvector[2])**2;
		
		# If the eigenvector is more similar to diff2, we flip it
		ch_dir = False;
		if diff1 > diff2:
			old_ev = eigenvector;
			eigenvector = -eigenvector;
			diff1 = (ref_line[0]-eigenvector[0])**2+(ref_line[1]-eigenvector[1])**2+(ref_line[2]-eigenvector[2])**2;
			diff2 = (ref_line_pi_deg[0]-eigenvector[0])**2+(ref_line_pi_deg[1]-eigenvector[1])**2+(ref_line_pi_deg[2]-eigenvector[2])**2;
				
				
		# Reset data
		data = data + mu;

		# Store helix vector
		helix_direction[i,::] = eigenvector;
		

        return helix_direction
      

# Calculate helix vectors and write output file
helix_vectors=[0,0,0,0,0,0,0,0]
nFrames = int(traj.n_frames);

for i in range(len(helix_parts)):
    if len(helix_inds[i]) > 0:
        helix_vectors[i]=computeHelixDirection(traj.atom_slice(helix_inds[i]), helix_parts[i]);
        out = open(out_stem + '-helix_vectors-' + helix_parts[i] + '.dat','w')
        for j in range(nFrames):
                out.write('%12.8f %12.8f %12.8f\n' % (helix_vectors[i][j][0], helix_vectors[i][j][1], helix_vectors[i][j][2]))
        out.close
