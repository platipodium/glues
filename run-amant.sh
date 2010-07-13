#!/bin/bash

# this script runs the scenarios for the American Antiquity paper,
# corresponding routines for visualisation is do_amant.m

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
$SED -i '/flucampl/s/flucampl.*$/flucampl 0.0/' $DAT
$SED -i '/gdd_opt/s/gdd_opt.*$/gdd_opt 0.7/' $PAR
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.002/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 100/' $OPAR
$X $SIM
cp $R.out ${R}_base.out
cp $T.nc amant_base.nc

# Too seasonal simulation
$SED -i '/gdd_opt/s/0\.7/0.4/' $PAR
$X $SIM
cp $R.out ${R}_subpolar.out
cp $T.nc amant_subpolar.nc

# Too tropical simulation
$SED -i '/gdd_opt/s/0\.4/1.0/' $PAR
$X $SIM
cp $R.out ${R}_tropical.out
cp $T.nc amant_tropical.nc
$SED -i '/gdd_opt/s/1\.0/0.7/' $PAR

# Remove spread
$SED -i '/LocalSpread/s/1/0/' $CTL
$X $SIM
cp $R.out ${R}_nospread.out
cp $T.nc amant_nospread.nc
$SED -i '/LocalSpread/s/0/1/' $CTL

# Add climate disruptions
$SED -i '/flucampl/s/0\.0/0.4/' $DAT
$X $SIM
cp $R.out ${R}_events.out
cp $T.nc amant_events.nc
$SED -i '/flucampl/s/0\.4/0.0/' $DAT

# return to base setup
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.002/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 100/' $OPAR
$SED -i '/LocalSpread/s/LocalSpread.*$/LocalSpread 1/' $CTL
$SED -i '/flucampl/s/flucampl.*$/flucampl 0.0/' $DAT
$SED -i '/gdd_opt/s/gdd_opt.*$/gdd_opt 0.7/' $PAR
