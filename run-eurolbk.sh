#!/bin/bash
# TODO why does the regular sed not accept this?

V=eurolbk

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

# Make sure we start from base setup (with spread, no fluc)
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.002/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 100/' $OPAR
$SED -i '/LocalSpread/s/LocalSpread.*$/LocalSpread 1/' $CTL
$SED -i '/flucampl/s/flucampl.*$/flucampl 0.0/' $DAT

# Four selected scenarios
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.002/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 100/' $OPAR
LOG=eurolbk_base.log; NC=eurolbk_base.nc
#test -f ${LOG} || 
$X $SIM 2> ${LOG} && mv test.nc ${NC}
test -f ${LOG} && $SED -i '/[A-d]/d' ${LOG}

$SED -i '/spreadv/s/spreadv.*$/spreadv 0.0000002/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 1500000/' $OPAR
LOG=eurolbk_cultural.log 
NC=eurolbk_cultural.nc
#test -f ${LOG} || 
$X $SIM 2> ${LOG} && \
  ncks -O -v time,population_density,technology,economies,farming,region,latitude,longitude,area test.nc ${NC}
test -f ${LOG} && $SED -i '/[A-d]/d' ${LOG}

$SED -i '/spreadv/s/spreadv.*$/spreadv 0.008/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 0/' $OPAR
LOG=eurolbk_demic.log
NC=eurolbk_demic.nc
#test -f ${LOG} || 
$X $SIM 2> ${LOG} && \
  ncks -O -v time,population_density,technology,economies,farming,region,latitude,longitude,area test.nc ${NC}
test -f ${LOG} && $SED -i '/[A-d]/d' ${LOG}

$SED -i '/spreadv/s/spreadv.*$/spreadv 0/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 0/' $OPAR
LOG=eurolbk_nospread.log
NC=eurolbk_nospread.nc
#test -f ${LOG} || 
$X $SIM 2> ${LOG} && \
  ncks -O -v time,population_density,technology,economies,farming,region,latitude,longitude,area test.nc ${NC}
test -f ${LOG} && $SED -i '/[A-d]/d' ${LOG}


exit








# No trade, no migration
  SV=$(echo "scale=10; 0." | bc )
  SM=$(echo "scale=10; 0" | bc )
  SC=$(echo "scale=10; $SM*$SV" | bc )
  
  
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

test -f ${LOG} ||   $X $SIM 2> ${LOG} && ncks -O -v time,population_density,farming,region,latitude,longitude test.nc ${NC}
test -f ${LOG} && $SED -i '/[A-d]/d' ${LOG}


exit
# Vary importance of trade and migration by  applying equal factors
for (( i=-8; i<=8; i++ )) ; do
  SV=$(echo "scale=10; 0.002*0.5^$i" | bc )
  SM=$(echo "scale=10; 100*4^$i" | bc )
  SC=$(echo "scale=10; $SM*$SV" | bc )
  
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


# Changing migratino around constant trade (keep spreadm*spreadv constant)
for (( i=-10; i<=10; i++ )) ; do
  SV=$(echo "scale=10; 0.002*0.5^$i" | bc )
  SM=$(echo "scale=10; 100*2^$i" | bc )
  SC=$(echo "scale=10; $SM*$SV" | bc )
  
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

# Change migration around no trade
for (( i=-9; i<=11; i++ )) ; do
  SV=$(echo "scale=7; 0.002*2^$i" | bc )
  SM=$(echo "scale=2; 0.0" | bc )
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
