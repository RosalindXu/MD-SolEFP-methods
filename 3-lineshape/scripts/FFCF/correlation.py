"""
Correlation Functions
Rosalind J. Xu 01/18

"""
from numpy import mean


def Corr(list1, list2, n):
    #precondition: len(list1) == len(list2)
    size = len(list1)
    ave1 = mean(list1)
    ave2 = mean(list2)
    
    tot = 0
    for i in range(size-n):
        tot += (list1[i] - ave1) * (list2[i+n] - ave2)
    
    avecorr = tot / (size-n)
    
    return avecorr 

# Un-normalized correlation function
def CorrUnNorm(list1, list2, N): # N = max delay window
    result = []

    for n in range(N+1):
        result.append([n,Corr(list1,list2,n)])
    
    return result

# Normalized correlation function
def CorrNorm(list1, list2, N): # N = max delay window
    result = []
    covariance = Corr(list1, list2, 0)
    
    for n in range(N+1):
        result.append([n,Corr(list1,list2,n) // covariance])  
        
    return result              
