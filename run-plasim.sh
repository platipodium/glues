#!/bin/bash

# this script runs the setup with npp from plasim

SED=gsed
X=src/glues
P=examples/simulations/plasim/plasim
S=examples/setup/plasim

SIM=$P.sim
CTL=$P.ctl
SCE=$P.sce
DAT=$P.dat
OPAR=$P.opar
R=$S/results
PAR=$P.par
T=test

# base simulation without fluctuation
$SED -i '/LocalSpread/s/LocalSpread.*$/LocalSpread 1/' $CTL
$SED -i '/flucampl/s/flucampl.*$/flucampl 0.0/' $DAT
$SED -i '/gdd_opt/s/gdd_opt.*$/gdd_opt 0.7/' $PAR
$SED -i '/kappa/s/kappa.*$/kappa 550.0/' $PAR
$SED -i '/spreadv/s/spreadv.*$/spreadv 0.002/' $PAR
$SED -i '/spreadm/s/spreadm.*$/spreadm 100/' $OPAR
#$SED -i '/climatefile/s/string.*$/string climatefile "regions_npp_11k_685.dat"/' $SCE
$SED -i '/climatefile/s/string.*$/string climatefile  "..\/..\/..\/data\/plasim_11k_vecode_685_npp.tsv"/' $SCE

# Loop over parameters for this scenario
for (( i=400 ; i<801; i=i+50 )) ; do
  SCE=$i
  $SED -i '/kappa/s/kappa.*$/kappa '$SCE'.0/' $PAR
  
  NC=plasim_${SCE}.nc
  LOG=plasim_${SCE}.log
    
  $X $SIM 2> ${LOG} && \
  ncks -O -v time,subsistence_intensity,area,population_density,technology,farming,region,latitude,longitude test.nc ${NC}  
  
  ncap2 -A -s 'landuse[time,region]=population_density[time,region]*sqrt(technology)/subsistence_intensity;
               cropfraction[time,region]=landuse/0.1*0.02*farming;
               cropfraction_static[time,region]=0.02*population_density*farming' ${NC} ${NC} &
  
  
done


exit

$SED -i '/climatefile/s/string.*$/string climatefile "plasim_LSG_6999_6000_mean_685_npp.tsv"/' $SCE
$X $SIM && cp $T.nc plasim_LSG_6999_6000_mean_685.nc

$SED -i '/climatefile/s/string.*$/string climatefile "plasim_reconstructedSST_global_6999_6000_mean_685_npp.tsv"/' $SCE
$X $SIM && cp $T.nc plasim_reconstructedSST_global_6999_6000_mean_685.nc

$SED -i '/climatefile/s/string.*$/string climatefile "plasim_reconstructedSST_regional_6999_6000_mean_685_npp.tsv"/' $SCE
$X $SIM && cp $T.nc plasim_reconstructedSST_regional_6999_6000_mean_685.nc

$SED -i '/climatefile/s/string.*$/string climatefile "regions_npp_11k_685.dat"/' $SCE
