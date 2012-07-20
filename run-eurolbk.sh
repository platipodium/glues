#!/bin/bash

V=eurolbk
B=eurolbk
L=${0%%.sh}.log

for SED in gsed sed; do  
  SED=$(which $SED)
  test -x ${SED} && break
done

date > $L
pwd >> $L
echo $0 >> $L
echo $SED >> $L
echo Setup: $V >> $L
echo Scenario base: $B >> $L

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

echo Simulation: $SIM >> $L
echo Results: $R >> $L

# Make sure we start from base setup (with spread, no fluc)
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.002/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 100/' $OPAR
$SED -i '/LocalSpread/s/LocalSpread.*$/LocalSpread 1/' $CTL
$SED -i '/MaxCivNum/s/MaxCivNum.*$/MaxCivNum 1000/' $CTL
$SED -i '/flucampl/s/flucampl.*$/flucampl 0.0/' $DAT
$SED -i '/deltan/s/deltan.*$/deltan 1.0/' $OPAR
$SED -i '/deltaq/s/deltaq.*$/deltaq 1.0/' $OPAR
$SED -i '/deltat/s/deltat.*$/deltat 0.15/' $OPAR
$SED -i '/gammab/s/gammab.*$/gammab 0.0040/' $PAR

# Four selected scenarios
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.002/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 100/' $OPAR

# Base scenario
SCE=base
LOG=${B}_${SCE}.log 
NCIN=${SIM%%.sim}.nc
NC=${LOG%%.log}.nc
echo Running: $X $SIM 
echo File output: $NCIN ' -> '$NC >> $L
$X $SIM 2> ${LOG} && mv ${NCIN} ${NC}
test -f ${LOG} && $SED -i '/[A-d]/d' ${LOG}


# Cultural diffusion scenario
SCE=cultural
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.0000002/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 1500000/' $OPAR
LOG=${B}_${SCE}.log 
NCIN=${SIM%%.sim}.nc
NC=${LOG%%.log}.nc
echo Running: $X $SIM 
echo File output: $NCIN ' -> '$NC >> $L
$X $SIM 2> ${LOG} && \
  ncks -O -v time,region_neighbour,population_density,technology,economies,farming,region,latitude,longitude,area,farming_spread_by_people ${NCIN} ${NC}
test -f ${LOG} && $SED -i '/[A-d]/d' ${LOG}

# Demic diffusion scenario
SCE=demic
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.008/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 0/' $OPAR
LOG=${B}_${SCE}.log 
NCIN=${SIM%%.sim}.nc
NC=${LOG%%.log}.nc
echo Running: $X $SIM 
echo File output: $NCIN ' -> '$NC >> $L
$X $SIM 2> ${LOG} && \
  ncks -O -v time,region_neighbour,population_density,technology,economies,farming,region,latitude,longitude,area,farming_spread_by_people ${NCIN} ${NC}
test -f ${LOG} && $SED -i '/[A-d]/d' ${LOG}

# Indigenous scenario (no spread)
SCE=nospread
$SED -i '/spreadv/s/spreadv.*$/spreadv 0/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 0/' $OPAR
LOG=${B}_${SCE}.log 
NCIN=${SIM%%.sim}.nc
NC=${LOG%%.log}.nc
echo Running: $X $SIM 
echo File output: $NCIN ' -> '$NC >> $L
$X $SIM 2> ${LOG} && \
  ncks -O -v time,region_neighbour,population_density,technology,economies,farming,region,latitude,longitude,area,farming_spread_by_people ${NCIN} ${NC}
test -f ${LOG} && $SED -i '/[A-d]/d' ${LOG}

# Events scenario (otherwise base setup)
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.002/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 100/' $OPAR
$SED -i '/flucampl/s/flucampl.*$/flucampl 0.4/' $DAT
LOG=${B}_${SCE}.log 
NCIN=${SIM%%.sim}.nc
NC=${LOG%%.log}.nc
echo Running: $X $SIM 
echo File output: $NCIN ' -> '$NC >> $L
$X $SIM 2> ${LOG} && \
  ncks -O -v time,region_neighbour,population_density,technology,economies,farming,region,latitude,longitude,area,farming_spread_by_people ${NCIN} ${NC}
test -f ${LOG} && $SED -i '/[A-d]/d' ${LOG}

# Return to base setup
$SED -i '/flucampl/s/flucampl.*$/flucampl 0.0/' $DAT


exit