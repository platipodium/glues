#!/bin/bash

V=harappa

test -x sed && SED=$(which sed)
test -x gsed && SED=$(which gsed)
export SED=/opt/local/bin/gsed

X=src/glues
export P=examples/simulations/${V}/${V}
S=examples/setup/685

SIM=$P.sim
CTL=$P.ctl
SCE=$P.sce
DAT=$P.dat
OPAR=$P.opar
R=$S/results
export PAR=$P.par

# move temp output to $HOME/Downloads directory
#V=${HOME}/Downloads/${V}

# Make sure we start from base setup (with spread, fluc=0.3)
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.002/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 100/' $OPAR
$SED -i '/LocalSpread/s/LocalSpread.*$/LocalSpread 1/' $CTL
$SED -i '/flucampl/s/flucampl.*$/flucampl 0.0/' $DAT
$SED -i '/deltan/s/deltan.*$/deltan 1.0/' $OPAR
$SED -i '/deltaq/s/deltaq.*$/deltaq 1.0/' $OPAR
$SED -i '/deltat/s/deltat.*$/deltat 0.15/' $OPAR
$SED -i '/gammab/s/gammab.*$/gammab 0.0040/' $PAR

NC=${V}.nc
LOG=${V}.log

#test -f ${LOG} || 
$X $SIM 2> ${LOG} && \
  ncks -O -v time,natural_fertility,temperature_limitation,population_density,technology,economies,farming,region,latitude,longitude,area test.nc ${NC}

exit

