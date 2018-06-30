### Calculates angles between two helices in a MD trajectory

from sys import argv
if len(argv)==1: 
   print __doc__
   exit()

from numpy import dot,arccos
from numpy.linalg import norm
from math import pi

# Helix Segments
helix_parts = ['A','B','C','D','E','F','G','H'];
helix_parts_N = ['A','B','C','D'];
helix_parts_C = ['E','F','G','H'];

# file name stem
name_stem = argv[1]

# Import helix vectors
helix = [0]*len(helix_parts)
for i in range(len(helix_parts)):
   with open(name_stem + '-helix_vectors-' + helix_parts[i] + '.dat','r') as vectors:
      helix[i] = [map(float,line.split()) for line in vectors]


# Function for calculating angle between vectors u,v
def vectorAngleDegree(u,v):
   return arccos(dot(u,v)/(norm(u)*norm(v))) / pi * 180

# Function for calculating and writing interhelical angles (takes helix indexes as input)
def calcInterhelicalAngle(i,j):
   assert len(helix[i]) == len(helix[j])
   out = open(name_stem + '-helix_angle-' + helix_parts[i] + helix_parts[j] + '.dat','w')
   nFrames = len(helix[i])
   for n in range(nFrames):
      out.write('%5i %6.3f\n' % (n+1, vectorAngleDegree(helix[i][n],helix[j][n])))               
   out.close
   return
                

# Calculate interhelical angles and write output file
for i in range(len(helix_parts_N)):
   for j in range(i+1,len(helix_parts_N)):
      calcInterhelicalAngle(i,j)

for i in range(len(helix_parts_N),len(helix_parts_N)+len(helix_parts_C)):
   for j in range(i+1,len(helix_parts_N)+len(helix_parts_C)):
      calcInterhelicalAngle(i,j)
      
      
                
