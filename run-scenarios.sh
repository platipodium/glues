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

# reduce overall spread
gsed -i '/spreadv/s/0\.07/0.007/' $PAR
$X $SIM
cp ${R}.out ${R}_spreadv007.out
gsed -i '/spreadv/s/0\.007/0.0/' $PAR
$X $SIM
cp ${R}.out ${R}_spreadv000.out
gsed -i '/spreadv/s/0\.0/0.7/' $PAR
$X $SIM
cp ${R}.out ${R}_spreadv700.out
gsed -i '/spreadv/s/0\.7/0.03/' $PAR
$X $SIM
cp ${R}.out ${R}_spreadv030.out
gsed -i '/spreadv/s/0\.03/0.07/' $PAR


# Reduce only trait spread, keep migration constant
gsed -i '/spreadm/s/1\.0/0.0/' $OPAR
$X $SIM
cp ${R}.out ${R}_spreadm000.out
gsed -i '/spreadm/s/0\.0/0.05/' $OPAR
$X $SIM
cp ${R}.out ${R}_spreadm005.out
gsed -i '/spreadm/s/0\.05/0.1/' $OPAR
$X $SIM
cp ${R}.out ${R}_spreadm010.out
gsed -i '/spreadm/s/0\.1/0.66/' $OPAR
$X $SIM
cp ${R}.out ${R}_spreadm066.out
gsed -i '/spreadm/s/0\.66/1.33/' $OPAR
$X $SIM
cp ${R}.out ${R}_spreadm133.out
gsed -i '/spreadm/s/33/0/' $OPAR

# Reduce only migration, keep trait spread constant
gsed -i '/spreadm/s/1\.0/2.0/' $OPAR
gsed -i '/spreadv/s/0\.07/0.035/' $PAR
$X $SIM
cp ${R}.out ${R}_spreadv200m0035.out
gsed -i '/spreadm/s/2\.0/7.0/' $OPAR
gsed -i '/spreadv/s/0\.035/0.01/' $PAR
$X $SIM
cp ${R}.out ${R}_spreadv700m001.out
gsed -i '/spreadm/s/7\.0/1000.0/' $OPAR
gsed -i '/spreadv/s/0\.01/0.00007/' $PAR
$X $SIM
cp ${R}.out ${R}_spreadvInfmZero.out
gsed -i '/spreadm/s/1000/1/' $OPAR
gsed -i '/spreadv/s/00007/07/' $PAR


gsed -i '/spreadm/s/0\.0/0.05/' $OPAR
$X $SIM
cp ${R}.out ${R}_spreadm005.out
gsed -i '/spreadm/s/0\.05/0.1/' $OPAR
$X $SIM
cp ${R}.out ${R}_spreadm010.out
gsed -i '/spreadm/s/0\.1/0.66/' $OPAR
$X $SIM
cp ${R}.out ${R}_spreadm066.out
gsed -i '/spreadm/s/0\.66/1.33/' $OPAR
$X $SIM
cp ${R}.out ${R}_spreadm133.out
gsed -i '/spreadm/s/33/0/' $OPAR




# base simulation
$X $SIM
cp $R.out ${R}_base.out

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


