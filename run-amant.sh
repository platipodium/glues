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
$SED -i '/flucampl/s/flucampl.*$/flucampl 0.4/' $DAT
$SED -i '/gdd_opt/s/gdd_opt.*$/gdd_opt 0.7/' $PAR
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.002/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 100/' $OPAR

LOG=amant_base.log
NC=amant_base.nc
$X $SIM 2> ${LOG} && mv test.nc $NC
test -f ${LOG} && $SED -i '/[A-d]/d' ${LOG}
ncap2 -A -s 'landuse[time,region]=population_density[time,region]*sqrt(technology)/subsistence_intensity;cropfraction[time,region]=landuse/0.1*0.02*farming;cropfraction_static[time,region]=0.02*population_density*farming' $NC $NC &

# Remove climate disruptions
$SED -i '/flucampl/s/flucampl.*$/flucampl 0.0/' $DAT
LOG=amant_nofluc.log
NC=amant_nofluc.nc
$X $SIM 2> ${LOG} && mv test.nc $NC
test -f ${LOG} && $SED -i '/[A-d]/d' ${LOG}
ncap2 -A -s 'landuse[time,region]=population_density[time,region]*sqrt(technology)/subsistence_intensity;cropfraction[time,region]=landuse/0.1*0.02*farming;cropfraction_static[time,region]=0.02*population_density*farming' $NC $NC &


# Too seasonal simulation
# $SED -i '/gdd_opt/s/0\.7/0.4/' $PAR
# $X $SIM
# cp $R.out ${R}_subpolar.out
# cp $T.nc amant_subpolar.nc

# Too tropical simulation
# $SED -i '/gdd_opt/s/0\.4/1.0/' $PAR
# $X $SIM
# cp $R.out ${R}_tropical.out
# cp $T.nc amant_tropical.nc
# $SED -i '/gdd_opt/s/1\.0/0.7/' $PAR

# Remove spread
$SED -i '/LocalSpread/s/LocalSpread.*$/LocalSpread 0/' $CTL
LOG=amant_nospread.log
NC=amant_nospread.nc
$X $SIM 2> ${LOG} && mv test.nc $NC
test -f ${LOG} && $SED -i '/[A-d]/d' ${LOG}
ncap2 -A -s 'landuse[time,region]=population_density[time,region]*sqrt(technology)/subsistence_intensity;cropfraction[time,region]=landuse/0.1*0.02*farming;cropfraction_static[time,region]=0.02*population_density*farming' $NC $NC &

# return to base setup
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.002/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 100/' $OPAR
$SED -i '/LocalSpread/s/LocalSpread.*$/LocalSpread 1/' $CTL
$SED -i '/flucampl/s/flucampl.*$/flucampl 0.4/' $DAT
$SED -i '/gdd_opt/s/gdd_opt.*$/gdd_opt 0.7/' $PAR


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
 
 



