#!/bin/bash

# This program rewrites the time points for either a SolEFP or QMMM output data file. 

#Input
read -p "QMMMM or SolEFP data file: " dat
read -p "Number of records in data file heading: " heading
read -p "Initial time point (in ps): " initial
read -p "Step size (in ps): " step
read -p "Decimal point in current time?(1=yes,0=no): " dec

awk -v dat=$dat -v heading=$heading -v initial=$initial -v step=$step -v dec=$dec 'BEGIN{}


NR==1,NR==heading{

if (heading > 0) {print}

}

NR>heading{

t=initial+step*(NR-(heading+1))


#/[0-9]+/ is the regular expression for the string of any number of natural number. 
#sub() command only substitutes the first occurrence
#$0 is the full line 
if (dec == "0") {sub(/[0-9]+/, t, $0)} # for integers
else {if (dec == "1") {sub(/[0-9]+\.[0-9]+/, t, $0)}} # for floating point numbers  

print $0

}

END{}' $dat > ${dat%.dat}-processed.dat




