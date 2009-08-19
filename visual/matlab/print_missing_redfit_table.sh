#!/bin/bash

DATDIR=/h/lemmen/projects/glues/m/holocene/redfit/data

TOTAL=${DATDIR}/input/total
OUTDIR=${DATDIR}/output/repl_*.?_0.5*

printf "%40s"  \"Name\"
for O in $(find $OUTDIR -type d) ; do
  POSTFIX=$(basename $O )
  printf " %s" \"${POSTFIX##repl_}\"
done
echo

#exit
for F in $(ls ${TOTAL}/*.dat) ; do 

  B=$(basename $F)
  B=${B%%.dat}
  BN=${B%%_tot}

  printf "%40s" \"$BN\"

  for O in $(find $OUTDIR -type d) ; do

    R=$O/$B.red

    if test -f $R ; then
      printf %2s 1
    else  
      printf %2s 0 
    fi

  done	
  echo 

done
