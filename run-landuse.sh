#!/bin/bash

# this script runs the scenarios for the GRL land use paper,
# corresponding routines for visualisation is do_landuse.m

SED=sed
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
O=landuse

# base simulation
$SED -i '/LocalSpread/s/LocalSpread.*$/LocalSpread 1/' $CTL
$SED -i '/flucampl/s/flucampl.*$/flucampl 0.4/' $DAT
$SED -i '/gdd_opt/s/gdd_opt.*$/gdd_opt 0.7/' $PAR
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.002/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 100/' $OPAR
$X $SIM
cp $T.nc ${O}_fluc04.nc
ncap2 -A -s 'landuse[time,region]=population_density[time,region]*sqrt(technology)/subsistence_intensity;cropfraction[time,region]=landuse/0.1*0.02*farming;cropfraction_static[time,region]=0.02*population_density*farming' ${O}_fluc04.nc ${O}_fluc04.nc &


# Lessen climate disruptions
$SED -i '/flucampl/s/0\.4/0.1/' $DAT
$X $SIM
cp $T.nc ${O}_fluc01.nc
ncap2 -A -s 'landuse[time,region]=population_density[time,region]*sqrt(technology)/subsistence_intensity;cropfraction[time,region]=landuse/0.1*0.02*farming;cropfraction_static[time,region]=0.02*population_density*farming' ${O}_fluc01.nc ${O}_fluc01.nc &

# Increase climate disruptions
$SED -i '/flucampl/s/0\.1/0.9/' $DAT
$X $SIM
cp $T.nc ${O}_fluc09.nc
ncap2 -A -s 'landuse[time,region]=population_density[time,region]*sqrt(technology)/subsistence_intensity;cropfraction[time,region]=landuse/0.1*0.02*farming;cropfraction_static[time,region]=0.02*population_density*farming' ${O}_fluc09.nc ${O}_fluc09.nc &

# Remove climate disruptions
$SED -i '/flucampl/s/0\.9/0.0/' $DAT
$X $SIM
cp $T.nc ${O}_fluc00.nc
ncap2 -A -s 'landuse[time,region]=population_density[time,region]*sqrt(technology)/subsistence_intensity;cropfraction[time,region]=landuse/0.1*0.02*farming;cropfraction_static[time,region]=0.02*population_density*farming' ${O}_fluc00.nc ${O}_fluc00.nc &

# return to base setup
$SED -i '/flucampl/s/flucampl.*$/flucampl 0.4/' $DAT

exit

# Plots for land use

export D=visual/plots/variable
export P=`find $D -name 'trajectory_landuse_*[0-9]*[0-9]_*.png'`
P+=" `find $D -name 'trajectory_technology_22_*.png'`"
P+=" `find $D -name 'trajectory_population_density_22_*.png'`"
P+=" `find $D -name 'trajectory_subsistence_intensity_22_*.png'`"
P+=" `find $D -name '*cropfraction_*[0-9]*[0-9]_[a-z]*.png'`"
P+=" `find visual/matlab -name 'landuse_glues_*_*_*png'`"

test -d tmp || mkdir tmp
cp $P tmp
cd tmp; zip landuse.zip *png; cd ..
 
 



