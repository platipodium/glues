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
$SED -i '/deltat/s/deltat.*$/deltat 0.0/' $PAR
$SED -i '/InitTech/s/InitTech.*$/InitTechnology 0.5/' $INIT
$SED -i '/InitQfarm/s/InitQfarm.*$/InitQfarm 0.00/' $INIT
$SED -i '/InitDens/s/InitDens.*$/InitDensity 0.0003/' $INIT
$SED -i '/InitNDom/s/InitNDom.*$/InitNDomast 0.0001/' $INIT
$SED -i '/TimeStart/s/Time.*$/TimeStart -30000/' $SIM
$SED -i '/TimeEnd/s/Time.*$/TimeEnd -10000/' $SIM
$SED -i '/TimeStep/s/Time.*$/TimeStep 5.0/' $SIM
$SED -i '/OutputStep/s/Out.*$/OutputStep 200.0/' $SIM
$SED -i '/flucampl/s/flucampl.*$/flucampl 0.0/' $DAT

SCE=lgm
LOG=${B}_${SCE}.log 
NC=${LOG%%.log}.nc
echo File output: $NC >> $L
$X $SIM 2> ${LOG} && mv test.nc $NC
test -f ${LOG} && $SED -i '/[A-d]/d' ${LOG}

# go back to base setup
$SED -i '/flucampl/s/flucampl.*$/flucampl 0.4/' $DAT
$SED -i '/InitQfarm/s/InitQfarm.*$/InitQfarm 0.04/' $INIT
$SED -i '/deltaq/s/deltaq.*$/deltaq 1.0/' $OPAR
$SED -i '/deltat/s/deltat.*$/deltat 0.15/' $PAR
$SED -i '/InitTech/s/InitTech.*$/InitTechnology 1.0/' $INIT
$SED -i '/InitDens/s/InitDens.*$/InitDensity 0.03/' $INIT
$SED -i '/InitNDom/s/InitNDom.*$/InitNDomast 0.25/' $INIT
$SED -i '/TimeStart/s/Time.*$/TimeStart -9500/' $SIM
$SED -i '/TimeEnd/s/Time.*$/TimeEnd 1000/' $SIM
$SED -i '/TimeStep/s/Time.*$/TimeStep 5.0/' $SIM
$SED -i '/OutputStep/s/Out.*$/OutputStep 20.0/' $OPAR
exit

