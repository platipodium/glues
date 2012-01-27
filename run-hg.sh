#!/bin/bash

V=eurolbk # base setup from which to deviate
B=hg
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
INIT=$P.init
SCE=$P.sce
DAT=$P.dat
OPAR=$P.opar
R=$S/results
export PAR=$P.par

# Make sure we start from base setup (with spread, no fluc)
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.002/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 100/' $OPAR
$SED -i '/LocalSpread/s/LocalSpread.*$/LocalSpread 1/' $CTL
$SED -i '/flucampl/s/flucampl.*$/flucampl 0.4/' $DAT
$SED -i '/deltan/s/deltan.*$/deltan 1.0/' $OPAR
$SED -i '/deltaq/s/deltaq.*$/deltaq 1.0/' $OPAR
$SED -i '/deltat/s/deltat.*$/deltat 0.15/' $OPAR
$SED -i '/gammab/s/gammab.*$/gammab 0.0040/' $PAR
$SED -i '/initQfarm/s/InitQfarm.*$/InitQFarm 0.04/' $OPAR

#---------------------------------------------------------------------------
# Now adjust to huntergatherer
$SED -i '/deltaq/s/deltaq.*$/deltaq 0.0/' $OPAR
SCE=dq0
LOG=${B}_${SCE}.log 
NC=${LOG%%.log}.nc
echo File output: $NC >> $L
$X $SIM 2> ${LOG} && mv test.nc $NC
test -f ${LOG} && $SED -i '/[A-d]/d' ${LOG}

# Return to base setup
$SED -i '/deltaq/s/deltaq.*$/deltaq 1.0/' $OPAR

#-------------------------------------------------------------------
# Adust do hunter-gatherer by assuming zero farming

$SED -i '/initQfarm/s/InitQfarm.*$/InitQFarm 0.00/' $OPAR
$SED -i '/deltaq/s/deltaq.*$/deltaq 0.0/' $OPAR
SCE=q0
LOG=${B}_${SCE}.log 
NC=${LOG%%.log}.nc
echo File output: $NC >> $L
$X $SIM 2> ${LOG} && mv test.nc $NC
test -f ${LOG} && $SED -i '/[A-d]/d' ${LOG}

# go back to base setup
$SED -i '/initQfarm/s/InitQfarm.*$/InitQFarm 0.04/' $OPAR
$SED -i '/deltaq/s/deltaq.*$/deltaq 1.0/' $OPAR
kype
exit

