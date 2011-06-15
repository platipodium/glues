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

# base simulation without fluctuation
$SED -i '/LocalSpread/s/LocalSpread.*$/LocalSpread 1/' $CTL
$SED -i '/flucampl/s/flucampl.*$/flucampl 0.0/' $DAT
$SED -i '/gdd_opt/s/gdd_opt.*$/gdd_opt 0.7/' $PAR
$SED -i '/kappa/s/kappa.*$/kappa 450.0/' $PAR
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.002/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 100/' $OPAR
$SED -i '/climatefile/s/string.*$/string climatefile "regions_npp_11k_685.dat"/' $SCE
$X $SIM && cp $T.nc plasim_k450.nc


# simulation without lower nppstar
$SED -i '/kappa/s/kappa.*$/kappa 400.0/' $PAR
$X $SIM && cp $T.nc plasim_k400.nc

# simulation without higher nppstar
$SED -i '/kappa/s/kappa.*$/kappa 650.0/' $PAR
$X $SIM && cp $T.nc plasim_k650.nc




exit

$SED -i '/climatefile/s/string.*$/string climatefile "plasim_LSG_6999_6000_mean_685_npp.tsv"/' $SCE
$X $SIM && cp $T.nc plasim_LSG_6999_6000_mean_685.nc

$SED -i '/climatefile/s/string.*$/string climatefile "plasim_reconstructedSST_global_6999_6000_mean_685_npp.tsv"/' $SCE
$X $SIM && cp $T.nc plasim_reconstructedSST_global_6999_6000_mean_685.nc

$SED -i '/climatefile/s/string.*$/string climatefile "plasim_reconstructedSST_regional_6999_6000_mean_685_npp.tsv"/' $SCE
$X $SIM && cp $T.nc plasim_reconstructedSST_regional_6999_6000_mean_685.nc

$SED -i '/climatefile/s/string.*$/string climatefile "regions_npp_11k_685.dat"/' $SCE
