#!/bin/bash

# this script runs the setup with npp from plasim

SED=gsed
X=src/glues
P=examples/simulations/plasim/plasim
S=examples/setup/plasim

SIM=$P.sim
CTL=$P.ctl
SCE=$P.sce
DAT=$P.dat
OPAR=$P.opar
R=$S/results
PAR=$P.par
T=test

# base simulation
$SED -i '/LocalSpread/s/LocalSpread.*$/LocalSpread 1/' $CTL
$SED -i '/flucampl/s/flucampl.*$/flucampl 0.4/' $DAT
$SED -i '/gdd_opt/s/gdd_opt.*$/gdd_opt 0.7/' $PAR
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.002/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 100/' $OPAR
$X $SIM
cp $R.out ${R}_base.out
cp $T.nc plasim_base.nc
