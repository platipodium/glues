#!/bin/bash

IN=glues_map.nc
OUT=${IN%%.nc}_dim.nc
STAT=${IN}.stat

if !(test -f $STAT ) ; then 
  ncks -v id $IN | grep id | sed 's/[]=[]/ = /g' |cut -d" " -f3,10,14,21 | awk '
  BEGIN {minlon=1000;maxlon=0;minlat=1000;maxlat=0}
  { if ($4>0) {
    if ($1<minlon) minlon=$1;
    if ($1>maxlon) maxlon=$1;
    if ($2<minlat) minlat=$2;
    if ($2>maxlat) maxlat=$2;
  }} 
  END {print minlon,maxlon,minlat,maxlat}
  ' > $STAT
else 
  cat $STAT
fi
read minlon maxlon minlat maxlat < $STAT

# Cut interesting slabs and variables from original file
ncks -O -d lat,$minlat,$maxlat -d lon,$minlon,$maxlon -v id $IN $OUT

IN=test.nc
BASE=${IN%%.nc}
OUT=${BASE}_dim.nc

# Cut interesting slabs and variables from original file and pack data
ncks -O -d time,-9500.0,-2001.0 -v population_density,technology,farming,economies $IN $OUT

IN=${BASE}_dim.nc
BASE=${IN%%.nc}
NTIME=`ncdump -h $IN | grep currently | cut -d'(' -f2 | cut -d" " -f1`

#echo $IN $BASE $NTIME

for (( i=0; i<NTIME; i=i+10 )) ; do 
#for (( i=0; i<1; i=i+10 )) ; do 
  OUT=${BASE}_$i.nc
  RA=${BASE}_ra_$i.nc
  ncks -O -d time,$i,`expr $i + 9` $IN $OUT
  ncra -O $OUT $RA
  rm -f $OUT
done

OUT=pangaea_reg.nc
rm -f $OUT

ncrcat -O ${BASE}_ra_??.nc $OUT
ncrcat -O $OUT ${BASE}_ra_???.nc $OUT
ncrcat -O $OUT ${BASE}_ra_1???.nc $OUT

rm -f ${BASE}_ra_*.nc

ncap2 -O -s "farming=pack_byte(farming);technology=pack_byte(technology);economies=pack_byte(economies);population_density=pack_short(population_density)" $OUT $OUT


exit
