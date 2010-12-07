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
$SED -i '/climatefile/s/string.*$/string climatefile "regions_npp_11k_685.dat"/' $SCE
$X $SIM && cp $T.nc plasim_base.nc

$SED -i '/climatefile/s/string.*$/string climatefile "plasim_LSG_6999_6000_mean_685_npp.tsv"/' $SCE
$X $SIM && cp $T.nc plasim_LSG_6999_6000_mean_685.nc

$SED -i '/climatefile/s/string.*$/string climatefile "plasim_reconstructedSST_global_6999_6000_mean_685_npp.tsv"/' $SCE
$X $SIM && cp $T.nc plasim_reconstructedSST_global_6999_6000_mean_685.nc

$SED -i '/climatefile/s/string.*$/string climatefile "plasim_reconstructedSST_regional_6999_6000_mean_685_npp.tsv"/' $SCE
$X $SIM && cp $T.nc plasim_reconstructedSST_regional_6999_6000_mean_685.nc

$SED -i '/climatefile/s/string.*$/string climatefile "regions_npp_11k_685.dat"/' $SCE
