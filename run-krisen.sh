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

# base simulation with events and slight knowledge loss
$SED -i '/flucampl/s/flucampl.*$/flucampl 0.4/' $DAT
$SED -i '/float.*gammab/s/gammab.*$/gammab 0.0040/' $PAR
$SED -i '/float.*KnowledgeLoss/s/KnowledgeLoss.*$/KnowledgeLoss 0.3/' $PAR
$X $SIM
cp $R.out ${R}_base.out
cp $T.nc krisen_base.nc

# Add larger knowledge loss
$SED -i '/float.*KnowledgeLoss/s/0\.3/2.0/' $PAR
$X $SIM
cp $R.out ${R}_loss.out
cp $T.nc krisen_loss.nc

# Remove climate disruptions and knowledge loss
$SED -i '/flucampl/s/0\.4/0.0/' $DAT
$SED -i '/float.*gammab/s/0\.0040/0.0037195/' $PAR 
$SED -i '/float.*KnowledgeLoss/s/2.0/0.0/' $PAR
$X $SIM
cp $R.out ${R}_nofluc.out
cp $T.nc krisen_nofluc.nc

# return to base setup
$SED -i '/flucampl/s/flucampl.*$/flucampl 0.4/' $DAT
$SED -i '/float.*gammab/s/gammab.*$/gammab 0.0040/' $PAR
$SED -i '/float.*KnowledgeLoss/s/KnowledgeLoss.*$/KnowledgeLoss 0.3/' $PAR
