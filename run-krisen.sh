#!/bin/bash

# this script runs the scenarios for the Umweltkrisen paper,
# corresponding routines for visualisation is do_krisen.m

SED=gsed
X=src/glues
P=examples/simulations/685/lbk
S=examples/setup/685

SIM=$P.sim
CTL=$P.ctl
SCE=$P.sce
DAT=$P.dat
OPAR=$P.opar
R=$S/results
PAR=$P.par
T=test

# base simulation with events
$SED -i '/flucampl/s/flucampl.*$/flucampl 0.4/' $DAT
$SED -i '/float.*gammab/s/gammab.*$/gammab 0.0040/' $PAR

$X $SIM
cp $R.out ${R}_base.out
cp $T.nc krisen_base.nc

# Remove climate disruptions
$SED -i '/flucampl/s/0\.4/0.0/' $DAT
#$SED -i '/float.*gammab/s/0\.0040/0.0037195/' $PAR 
$X $SIM
cp $R.out ${R}_nofluc.out
cp $T.nc krisen_nofluc.nc

# return to base setup
$SED -i '/flucampl/s/flucampl.*$/flucampl 0.4/' $DAT
$SED -i '/float gammab/s/gammab.*$/gammab 0.0040/' $PAR
