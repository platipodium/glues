#!/bin/bash

# this script runs the scenarios for lowered delta values for all traits

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

# base simulation
$SED -i '/LocalSpread/s/LocalSpread.*$/LocalSpread 1/' $CTL
$SED -i '/flucampl/s/flucampl.*$/flucampl 0.4/' $DAT
$SED -i '/gdd_opt/s/gdd_opt.*$/gdd_opt 0.7/' $PAR
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.002/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 100/' $OPAR
$SED -i '/deltan/s/deltan.*$/deltan 1.0/' $OPAR
$SED -i '/deltaq/s/deltaq.*$/deltaq 1.0/' $OPAR
$SED -i '/deltat/s/deltat.*$/deltat 0.15/' $OPAR
$SED -i '/gammab/s/gammab.*$/gammab 0.0040/' $PAR

V=base
LOG=lowdelta_${V}.log
NC=lowdelta_${V}.nc
#$X $SIM 2> ${LOG} && mv test.nc $NC

V=q10
$SED -i '/deltat/s/deltat.*$/deltat 0.15/' $OPAR
$SED -i '/deltan/s/deltan.*$/deltan 0.1/' $OPAR
$SED -i '/deltat/s/deltaq.*$/deltaq 0.1/' $OPAR
$SED -i '/gammab/s/gammab.*$/gammab 0.01/' $PAR
LOG=lowdelta_${V}.log
NC=lowdelta_${V}.nc
$X $SIM 2> ${LOG} && mv test.nc $NC

# base simulation
$SED -i '/LocalSpread/s/LocalSpread.*$/LocalSpread 1/' $CTL
$SED -i '/flucampl/s/flucampl.*$/flucampl 0.4/' $DAT
$SED -i '/gdd_opt/s/gdd_opt.*$/gdd_opt 0.7/' $PAR
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.002/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 100/' $OPAR
$SED -i '/deltan/s/deltan.*$/deltan 1.0/' $OPAR
$SED -i '/deltaq/s/deltaq.*$/deltaq 1.0/' $OPAR
$SED -i '/deltat/s/deltat.*$/deltat 0.15/' $OPAR
$SED -i '/gammab/s/gammab.*$/gammab 0.0040/' $PAR
