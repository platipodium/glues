#!/bin/bash

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


# trade const and migration var, kee0p spreadv*spreadm=0.2
gsed -i '/spreadv/s/spreadv.*$/spreadv 0.0000002/' $PAR
gsed -i '/spreadm/s/spreadm.*$/spreadm 1000000/' $OPAR
$X $SIM
cp ${R}.out ${R}_s7.out
gsed -i '/spreadv/s/spreadv.*$/spreadv 0.000002/' $PAR
gsed -i '/spreadm/s/spreadm.*$/spreadm 100000/' $OPAR
$X $SIM
cp ${R}.out ${R}_s6.out
gsed -i '/spreadv/s/spreadv.*$/spreadv 0.00002/' $PAR
gsed -i '/spreadm/s/spreadm.*$/spreadm 10000/' $OPAR
$X $SIM
cp ${R}.out ${R}_s5.out
gsed -i '/spreadv/s/spreadv.*$/spreadv 0.0002/' $PAR
gsed -i '/spreadm/s/spreadm.*$/spreadm 1000/' $OPAR
$X $SIM
cp ${R}.out ${R}_s4.out
gsed -i '/spreadv/s/spreadv.*$/spreadv 0.002/' $PAR
gsed -i '/spreadm/s/spreadm.*$/spreadm 100/' $OPAR
$X $SIM
cp ${R}.out ${R}_s3.out
gsed -i '/spreadv/s/spreadv.*$/spreadv 0.02/' $PAR
gsed -i '/spreadm/s/spreadm.*$/spreadm 10/' $OPAR
$X $SIM
cp ${R}.out ${R}_s2.out
gsed -i '/spreadv/s/spreadv.*$/spreadv 0.2/' $PAR
gsed -i '/spreadm/s/spreadm.*$/spreadm 1/' $OPAR
$X $SIM
cp ${R}.out ${R}_s1.out
gsed -i '/spreadv/s/spreadv.*$/spreadv 2/' $PAR
gsed -i '/spreadm/s/spreadm.*$/spreadm 0.1/' $OPAR
$X $SIM
cp ${R}.out ${R}_s0.out

# only trade variation, migration const
gsed -i '/spreadv/s/spreadv.*$/spreadv 0.002/' $PAR
gsed -i '/spreadm/s/spreadm.*$/spreadm 0/' $OPAR
$X $SIM
cp ${R}.out ${R}_v3m0.out
gsed -i '/spreadm/s/spreadm.*$/spreadm 0.01/' $OPAR
$X $SIM
cp ${R}.out ${R}_v3m1.out
gsed -i '/spreadm/s/spreadm.*$/spreadm 0.1/' $OPAR
$X $SIM
cp ${R}.out ${R}_v3m2.out
gsed -i '/spreadm/s/spreadm.*$/spreadm 1/' $OPAR
$X $SIM
cp ${R}.out ${R}_v3m3.out
gsed -i '/spreadm/s/spreadm.*$/spreadm 3.3333/' $OPAR
$X $SIM
cp ${R}.out ${R}_v3m4.out
gsed -i '/spreadm/s/spreadm.*$/spreadm 10/' $OPAR
$X $SIM
cp ${R}.out ${R}_v3m5.out
gsed -i '/spreadm/s/spreadm.*$/spreadm 33/' $OPAR
$X $SIM
cp ${R}.out ${R}_v3m6.out
gsed -i '/spreadm/s/spreadm.*$/spreadm 100/' $OPAR
$X $SIM
cp ${R}.out ${R}_v3m7.out
gsed -i '/spreadm/s/spreadm.*$/spreadm 333/' $OPAR
$X $SIM
cp ${R}.out ${R}_v3m8.out
gsed -i '/spreadm/s/spreadm.*$/spreadm 1000/' $OPAR
$X $SIM
cp ${R}.out ${R}_v3m9.out





# only migration
gsed -i '/spreadm/s/spreadm.*$/spreadm 0/' $OPAR
gsed -i '/spreadv/s/spreadv.*$/spreadv 0/' $PAR
$X $SIM
cp ${R}.out ${R}_v0m0.out
gsed -i '/spreadv/s/spreadv.*$/spreadv 0.000001/' $PAR
$X $SIM
cp ${R}.out ${R}_v1m0.out
gsed -i '/spreadv/s/spreadv.*$/spreadv 0.00001/' $PAR
$X $SIM
cp ${R}.out ${R}_v2m0.out
gsed -i '/spreadv/s/spreadv.*$/spreadv 0.001/' $PAR
$X $SIM
cp ${R}.out ${R}_v3m0.out
gsed -i '/spreadv/s/spreadv.*$/spreadv 0.00333/' $PAR
$X $SIM
cp ${R}.out ${R}_v4m0.out
gsed -i '/spreadv/s/spreadv.*$/spreadv 0.01/' $PAR
$X $SIM
cp ${R}.out ${R}_v5m0.out
gsed -i '/spreadv/s/spreadv.*$/spreadv 0.033333/' $PAR
$X $SIM
cp ${R}.out ${R}_v6m0.out
gsed -i '/spreadv/s/spreadv.*$/spreadv 0.1/' $PAR
$X $SIM
cp ${R}.out ${R}_v7m0.out
gsed -i '/spreadv/s/spreadv.*$/spreadv 0.333333/' $PAR
$X $SIM
cp ${R}.out ${R}_v8m0.out
gsed -i '/spreadv/s/spreadv.*$/spreadv 1.0/' $PAR
$X $SIM
cp ${R}.out ${R}_v9m0.out


# only trade
gsed -i '/spreadv/s/spreadv.*$/spreadv 0.000001/' $PAR
gsed -i '/spreadm/s/spreadm.*$/spreadm 0/' $OPAR
$X $SIM
cp ${R}.out ${R}_v1m0.out
gsed -i '/spreadm/s/spreadm.*$/spreadm 1000/' $OPAR
$X $SIM
cp ${R}.out ${R}_v1m1.out
gsed -i '/spreadm/s/spreadm.*$/spreadm 10000/' $OPAR
$X $SIM
cp ${R}.out ${R}_v1m2.out
gsed -i '/spreadm/s/spreadm.*$/spreadm 100000/' $OPAR
$X $SIM
cp ${R}.out ${R}_v1m3.out
gsed -i '/spreadm/s/spreadm.*$/spreadm 333333/' $OPAR
$X $SIM
cp ${R}.out ${R}_v1m4.out
gsed -i '/spreadm/s/spreadm.*$/spreadm 1000000/' $OPAR
$X $SIM
cp ${R}.out ${R}_v1m5.out
gsed -i '/spreadm/s/spreadm.*$/spreadm 3333333/' $OPAR
$X $SIM
cp ${R}.out ${R}_v1m6.out



# base simulation
gsed -i '/spreadv/s/spreadv.*$/spreadv 0.002/' $PAR
gsed -i '/spreadm/s/spreadm.*$/spreadm 100/' $OPAR
$X $SIM
cp $R.out ${R}_base.out


# relative importance of trade ad migration
gsed -i '/spreadv/s/spreadv.*$/spreadv 0.002/' $PAR
gsed -i '/spreadm/s/spreadm.*$/spreadm 100/' $OPAR
$X $SIM
cp $R.out ${R}_t55.out
gsed -i '/spreadv/s/spreadv.*$/spreadv 0.001/' $PAR
gsed -i '/spreadm/s/spreadm.*$/spreadm 400/' $OPAR
$X $SIM
cp $R.out ${R}_t46.out
gsed -i '/spreadv/s/spreadv.*$/spreadv 0.0005/' $PAR
gsed -i '/spreadm/s/spreadm.*$/spreadm 1600/' $OPAR
$X $SIM
cp $R.out ${R}_t37.out
gsed -i '/spreadv/s/spreadv.*$/spreadv 0.0002/' $PAR
gsed -i '/spreadm/s/spreadm.*$/spreadm 100000/' $OPAR
$X $SIM
cp $R.out ${R}_t28.out
gsed -i '/spreadv/s/spreadv.*$/spreadv 0.004/' $PAR
gsed -i '/spreadm/s/spreadm.*$/spreadm 25/' $OPAR
$X $SIM
cp $R.out ${R}_t64.out
gsed -i '/spreadv/s/spreadv.*$/spreadv 0.008/' $PAR
gsed -i '/spreadm/s/spreadm.*$/spreadm 6/' $OPAR
$X $SIM
cp $R.out ${R}_t73.out
gsed -i '/spreadv/s/spreadv.*$/spreadv 0.016/' $PAR
gsed -i '/spreadm/s/spreadm.*$/spreadm 1.6/' $OPAR
$X $SIM
cp $R.out ${R}_t82.out
gsed -i '/spreadv/s/spreadv.*$/spreadv 0.032/' $PAR
gsed -i '/spreadm/s/spreadm.*$/spreadm 0.4/' $OPAR
$X $SIM
cp $R.out ${R}_t91.out




# Remove spread
gsed -i '/LocalSpread/s/1/0/' $CTL
$X $SIM
cp $R.out ${R}_nospread.out
gsed -i '/LocalSpread/s/0/1/' $CTL

# Add climate disruptions
gsed -i '/flucampl/s/0\.0/0.4/' $DAT
$X $SIM
cp $R.out ${R}_events.out
gsed -i '/flucampl/s/0\.4/0.0/' $DAT


# return to base setup
gsed -i '/spreadv/s/spreadv.*$/spreadv 0.002/' $PAR
gsed -i '/spreadm/s/spreadm.*$/spreadm 100/' $OPAR
gsed -i '/LocalSpread/s/LocalSpread.*$/LocalSpread 1/' $CTL
gsed -i '/flucampl/s/flucampl.*$/flucampl 0.0/' $DAT
