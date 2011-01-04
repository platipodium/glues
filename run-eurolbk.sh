#!/bin/bash
# TODO why does the regular sed not accept this?

V=eurolbk

test -x sed && SED=$(which sed)
test -x gsed && SED=$(which gsed)
export SED=/opt/local/bin/gsed

X=src/glues
export P=examples/simulations/${V}
S=examples/setup/685

SIM=$P.sim
CTL=$P.ctl
SCE=$P.sce
DAT=$P.dat
OPAR=$P.opar
R=$S/results
export PAR=$P.par

# Make sure we start from base setup (with spread, no fluc)
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.002/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 100/' $OPAR
$SED -i '/LocalSpread/s/LocalSpread.*$/LocalSpread 1/' $CTL
$SED -i '/flucampl/s/flucampl.*$/flucampl 0.0/' $DAT

$X $SIM #2> eurolbk_base.log
mv test.nc ${V}_base.nc
#exit

# Remove spread (used in paper to diagnose indigenous)
$SED -i '/LocalSpread/s/1/0/' $CTL
$X $SIM
cp test.nc ${V}_nospread.nc
$SED -i '/LocalSpread/s/0/1/' $CTL

# Add climate disruptions
$SED -i '/flucampl/s/0\.0/0.4/' $DAT
$X $SIM
cp test.nc ${V}_events.nc
$SED -i '/flucampl/s/0\.4/0.0/' $DAT

# return to base setup
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.002/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 100/' $OPAR
$SED -i '/LocalSpread/s/LocalSpread.*$/LocalSpread 1/' $CTL
$SED -i '/flucampl/s/flucampl.*$/flucampl 0.0/' $DAT




exit








# trade const and migration var, kee0p spreadv*spreadm=0.2
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.0000002/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 1000000/' $OPAR
$X $SIM
cp ${R}.out ${R}_s7.out
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.000002/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 100000/' $OPAR
$X $SIM
cp ${R}.out ${R}_s6.out
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.00002/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 10000/' $OPAR
$X $SIM
cp ${R}.out ${R}_s5.out
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.0002/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 1000/' $OPAR
$X $SIM
cp ${R}.out ${R}_s4.out
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.002/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 100/' $OPAR
$X $SIM
cp ${R}.out ${R}_s3.out
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.02/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 10/' $OPAR
$X $SIM
cp ${R}.out ${R}_s2.out
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.2/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 1/' $OPAR
$X $SIM
cp ${R}.out ${R}_s1.out
$SED -i '/spreadv/s/spreadv.*$/spreadv 2/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 0.1/' $OPAR
$X $SIM
cp ${R}.out ${R}_s0.out

# only trade variation, migration const
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.002/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 0/' $OPAR
$X $SIM
cp ${R}.out ${R}_v3m0.out
$SED -i '/spreadm/s/spreadm.*$/spreadm 0.01/' $OPAR
$X $SIM
cp ${R}.out ${R}_v3m1.out
$SED -i '/spreadm/s/spreadm.*$/spreadm 0.1/' $OPAR
$X $SIM
cp ${R}.out ${R}_v3m2.out
$SED -i '/spreadm/s/spreadm.*$/spreadm 1/' $OPAR
$X $SIM
cp ${R}.out ${R}_v3m3.out
$SED -i '/spreadm/s/spreadm.*$/spreadm 3.3333/' $OPAR
$X $SIM
cp ${R}.out ${R}_v3m4.out
$SED -i '/spreadm/s/spreadm.*$/spreadm 10/' $OPAR
$X $SIM
cp ${R}.out ${R}_v3m5.out
$SED -i '/spreadm/s/spreadm.*$/spreadm 33/' $OPAR
$X $SIM
cp ${R}.out ${R}_v3m6.out
$SED -i '/spreadm/s/spreadm.*$/spreadm 100/' $OPAR
$X $SIM
cp ${R}.out ${R}_v3m7.out
$SED -i '/spreadm/s/spreadm.*$/spreadm 333/' $OPAR
$X $SIM
cp ${R}.out ${R}_v3m8.out
$SED -i '/spreadm/s/spreadm.*$/spreadm 1000/' $OPAR
$X $SIM
cp ${R}.out ${R}_v3m9.out


# only migration
$SED -i '/spreadm/s/spreadm.*$/spreadm 0/' $OPAR
$SED -i '/spreadv/s/spreadv.*$/spreadv 0/' $PAR
$X $SIM
cp ${R}.out ${R}_v0m0.out
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.000001/' $PAR
$X $SIM
cp ${R}.out ${R}_v1m0.out
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.00001/' $PAR
$X $SIM
cp ${R}.out ${R}_v2m0.out
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.001/' $PAR
$X $SIM
cp ${R}.out ${R}_v3m0.out
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.00333/' $PAR
$X $SIM
cp ${R}.out ${R}_v4m0.out
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.01/' $PAR
$X $SIM
cp ${R}.out ${R}_v5m0.out
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.033333/' $PAR
$X $SIM
cp ${R}.out ${R}_v6m0.out
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.1/' $PAR
$X $SIM
cp ${R}.out ${R}_v7m0.out
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.333333/' $PAR
$X $SIM
cp ${R}.out ${R}_v8m0.out
$SED -i '/spreadv/s/spreadv.*$/spreadv 1.0/' $PAR
$X $SIM
cp ${R}.out ${R}_v9m0.out


# only trade
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.000001/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 0/' $OPAR
$X $SIM
cp ${R}.out ${R}_v1m0.out
$SED -i '/spreadm/s/spreadm.*$/spreadm 1000/' $OPAR
$X $SIM
cp ${R}.out ${R}_v1m1.out
$SED -i '/spreadm/s/spreadm.*$/spreadm 10000/' $OPAR
$X $SIM
cp ${R}.out ${R}_v1m2.out
$SED -i '/spreadm/s/spreadm.*$/spreadm 100000/' $OPAR
$X $SIM
cp ${R}.out ${R}_v1m3.out
$SED -i '/spreadm/s/spreadm.*$/spreadm 333333/' $OPAR
$X $SIM
cp ${R}.out ${R}_v1m4.out
$SED -i '/spreadm/s/spreadm.*$/spreadm 1000000/' $OPAR
$X $SIM
cp ${R}.out ${R}_v1m5.out
$SED -i '/spreadm/s/spreadm.*$/spreadm 3333333/' $OPAR
$X $SIM
cp ${R}.out ${R}_v1m6.out



# base simulation
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.002/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 100/' $OPAR
$X $SIM
cp $R.out ${R}_base.out


# relative importance of trade ad migration
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.002/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 100/' $OPAR
$X $SIM
cp $R.out ${R}_t55.out
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.001/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 400/' $OPAR
$X $SIM
cp $R.out ${R}_t46.out
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.0005/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 1600/' $OPAR
$X $SIM
cp $R.out ${R}_t37.out
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.0002/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 100000/' $OPAR
$X $SIM
cp $R.out ${R}_t28.out
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.004/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 25/' $OPAR
$X $SIM
cp $R.out ${R}_t64.out
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.008/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 6/' $OPAR
$X $SIM
cp $R.out ${R}_t73.out
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.016/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 1.6/' $OPAR
$X $SIM
cp $R.out ${R}_t82.out
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.032/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 0.4/' $OPAR
$X $SIM
cp $R.out ${R}_t91.out




# Remove spread
$SED -i '/LocalSpread/s/1/0/' $CTL
$X $SIM
cp $R.out ${R}_nospread.out
$SED -i '/LocalSpread/s/0/1/' $CTL

# Add climate disruptions
$SED -i '/flucampl/s/0\.0/0.4/' $DAT
$X $SIM
cp $R.out ${R}_events.out
$SED -i '/flucampl/s/0\.4/0.0/' $DAT


# return to base setup
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.002/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 100/' $OPAR
$SED -i '/LocalSpread/s/LocalSpread.*$/LocalSpread 1/' $CTL
$SED -i '/flucampl/s/flucampl.*$/flucampl 0.0/' $DAT
