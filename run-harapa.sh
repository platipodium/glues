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
V=${HOME}/Downloads/${V}

# Make sure we start from base setup (with spread, fluc=0.3)
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.002/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 100/' $OPAR
$SED -i '/LocalSpread/s/LocalSpread.*$/LocalSpread 1/' $CTL
$SED -i '/flucampl/s/flucampl.*$/flucampl 0.3/' $DAT
$SED -i '/deltan/s/deltan.*$/deltan 1.0/' $OPAR
$SED -i '/deltaq/s/deltaq.*$/deltaq 1.0/' $OPAR
$SED -i '/deltat/s/deltat.*$/deltat 0.15/' $OPAR
$SED -i '/gammab/s/gammab.*$/gammab 0.0040/' $PAR

NC=${V}.nc

#test -f ${LOG} || 
$X $SIM 2> ${LOG} && \
  ncks -O -v time,population_density,technology,economies,farming,region,latitude,longitude,area,farming_spread_by_people test.nc ${NC}

exit

  VEXPR=''"/spreadv/s/spreadv.*$/spreadv ${SVI}.${SVF}"/'' 
  MEXPR=''"/spreadm/s/spreadm.*$/spreadm ${SMI}.${SMF}"/'' 
  $SED -i "$VEXPR" $PAR
  $SED -i "$MEXPR" $OPAR

  test -f ${LOG} && continue
  $X $SIM 2> ${LOG} && ncks -O -v time,population_density,farming,region,latitude,longitude test.nc ${NC}
  test -f ${LOG} && $SED -i '/[A-d]/d' ${LOG}
done

# Trait variation around minimal migration
for (( i=-9; i<=18; i++ )) ; do
  SV=$(echo "scale=7; 0.0000002" | bc )
  SM=$(echo "scale=2; 100*2^$i" | bc )
  SC=$(echo "scale=7; $SM*$SV" | bc )
  
  SVI=0${SV%.*}
  SVF=${SV#*.}
  SV=$(printf "%09.7f\n" "$SVI,$SVF")
  SVI=${SV%,*}
  SVF=${SV#*,}

  SMI=0${SM%.*}
  SMF=${SM#*.}
  SM=$(printf "%010.2f\n" "$SMI,$SMF")
  SMI=${SM%,*}
  SMF=${SM#*,}
  
  
  SCI=0${SC%.*}
  SCF=${SC#*.}
  SC=$(printf "%010.6f\n" "$SCI,$SCF")
  SCI=${SC%,*}
  SCF=${SC#*,}
  

  LOG=${V}_${SVI}.${SVF}_${SMI}.${SMF}_${SCI}.${SCF}_.log 
  NC=${V}_${SVI}.${SVF}_${SMI}.${SMF}_${SCI}.${SCF}_.nc 

  VEXPR=''"/spreadv/s/spreadv.*$/spreadv ${SVI}.${SVF}"/'' 
  MEXPR=''"/spreadm/s/spreadm.*$/spreadm ${SMI}.${SMF}"/'' 
  $SED -i "$VEXPR" $PAR
  $SED -i "$MEXPR" $OPAR

  test -f ${LOG} && continue
  $X $SIM 2> ${LOG} && ncks -O -v time,population_density,farming,region,latitude,longitude test.nc ${NC}
  test -f ${LOG} && $SED -i '/[A-d]/d' ${LOG}
done


# Trait variation around medium migration
for (( i=-10; i<=10; i++ )) ; do
  SV=$(echo "scale=7; 0.002" | bc )
  SM=$(echo "scale=2; 100*2^$i" | bc )
  SC=$(echo "scale=7; $SM*$SV" | bc )
  
  SVI=0${SV%.*}
  SVF=${SV#*.}
  SV=$(printf "%09.7f\n" "$SVI,$SVF")
  SVI=${SV%,*}
  SVF=${SV#*,}

  SMI=0${SM%.*}
  SMF=${SM#*.}
  SM=$(printf "%010.2f\n" "$SMI,$SMF")
  SMI=${SM%,*}
  SMF=${SM#*,}
  
  
  SCI=0${SC%.*}
  SCF=${SC#*.}
  SC=$(printf "%010.6f\n" "$SCI,$SCF")
  SCI=${SC%,*}
  SCF=${SC#*,}
  

  LOG=${V}_${SVI}.${SVF}_${SMI}.${SMF}_${SCI}.${SCF}_.log 
  NC=${V}_${SVI}.${SVF}_${SMI}.${SMF}_${SCI}.${SCF}_.nc 

  VEXPR=''"/spreadv/s/spreadv.*$/spreadv ${SVI}.${SVF}"/'' 
  MEXPR=''"/spreadm/s/spreadm.*$/spreadm ${SMI}.${SMF}"/'' 
  $SED -i "$VEXPR" $PAR
  $SED -i "$MEXPR" $OPAR

  test -f ${LOG} && continue
  $X $SIM 2> ${LOG} && ncks -O -v time,population_density,farming,region,latitude,longitude test.nc ${NC}
  test -f ${LOG} && $SED -i '/[A-d]/d' ${LOG}
done


# return to base setup
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.002/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 100/' $OPAR
$SED -i '/LocalSpread/s/LocalSpread.*$/LocalSpread 1/' $CTL
$SED -i '/flucampl/s/flucampl.*$/flucampl 0.0/' $DAT
