#!/bin/bash
# TODO why does the regular sed not accept this?

V=eurolbk
B=euroclim
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
$SED -i '/flucampl/s/flucampl.*$/flucampl 0.0/' $DAT
$SED -i '/deltan/s/deltan.*$/deltan 1.0/' $OPAR
$SED -i '/deltaq/s/deltaq.*$/deltaq 1.0/' $OPAR
$SED -i '/deltat/s/deltat.*$/deltat 0.15/' $OPAR
$SED -i '/gammab/s/gammab.*$/gammab 0.0040/' $PAR
#$SED -i '/SiteRegfile/s/SiteRegfile.*$/SiteRegfile "EventInReg_128_685.tsv"/' $SCE
#$SED -i '/eventfile/s/eventfile.*$/eventfile "EventSeries_128.tsv"/' $SCE
$SED -i '/SiteRegfile/s/SiteRegfile.*$/SiteRegfile "EventInReg.dat"/' $SCE
$SED -i '/eventfile/s/eventfile.*$/eventfile "EvSeries.dat"/' $SCE


# changed from eurolbk
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.002/' $PAR
#$SED -i '/gammab/s/gammab.*$/gammab 0.00418/' $PAR

$SED -i '/KnowledgeLoss/s/KnowledgeLoss.*$/KnowledgeLoss 0.8/' $PAR

# Loop over parameters for this scenario
#for (( i=0 ; i<10; i=i+1 )) ; do
#for (( i=4 ; i<5; i=i+1 )) ; do
for (( i=4 ; i<5; i=i+1 )) ; do
  SCE=0.$i

  $SED -i '/flucampl/s/flucampl.*$/flucampl '$SCE'/' $DAT
  $SED -i '/gammab/s/gammab.*$/gammab 0.00403/' $PAR
  LOG=${B}_${SCE}.log 
  NCIN=${SIM%%.sim}.nc
  NC=${LOG%%.log}.nc
  echo Running: $X $SIM 
  echo File output: $NCIN ' -> '$NC >> $L
  $X $SIM 2> ${LOG} && \
  ncks -O -v time,region_neighbour,natural_fertility,temperature_limitation,population_size,population_density,technology,economies,farming,region,latitude,longitude,area,migration_density ${NCIN} ${NC}
  test -f ${LOG} && $SED -i '/[A-d]/d' ${LOG}
done


# changed from eurolbk
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.002/' $PAR
#$SED -i '/gammab/s/gammab.*$/gammab 0.00372/' $PAR

# Loop over parameters for this scenario
for (( i=0 ; i<1; i=i+1 )) ; do
#for (( i=4 ; i<5; i=i+1 )) ; do
#for (( i=4 ; i<5; i=i+4 )) ; do
  SCE=0.$i
  $SED -i '/flucampl/s/flucampl.*$/flucampl '$SCE'/' $DAT
  $SED -i '/gammab/s/gammab.*$/gammab 0.00400/' $PAR
   LOG=${B}_${SCE}.log 
  NCIN=${SIM%%.sim}.nc
  NC=${LOG%%.log}.nc
  echo Running: $X $SIM 
  echo File output: $NCIN ' -> '$NC >> $L
  $X $SIM 2> ${LOG} && \
  ncks -O -v time,region_neighbour,natural_fertility,temperature_limitation,population_size,population_density,technology,economies,farming,region,latitude,longitude,area,migration_density ${NCIN} ${NC}
  test -f ${LOG} && $SED -i '/[A-d]/d' ${LOG}
done



# Last scenario with most complete information
SCE=1.0
$SED -i '/flucampl/s/flucampl.*$/flucampl '$SCE'/' $DAT
LOG=${B}_${SCE}.log 
  NCIN=${SIM%%.sim}.nc
  NC=${LOG%%.log}.nc
  echo Running: $X $SIM 
  echo File output: $NCIN ' -> '$NC >> $L
#$X $SIM 2> ${LOG} && mv $NCIN  $NC
test -f ${LOG} && $SED -i '/[A-d]/d' ${LOG}

# Return to base setup
#$SED -i '/flucampl/s/flucampl.*$/flucampl 0.0/' $DAT

exit

