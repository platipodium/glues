#!/bin/bash

NSIM=1000

GLUES=../bin/glues.prg
RVAR=../bin/random_variation
PREFIX=lbk
SIMDIR=../examples/simulations/685

mkdir -p  ${SIMDIR}_var
rm ${SIMDIR}_var/${PREFIX}*
cp ${SIMDIR}/${PREFIX}* ${SIMDIR}_var

SIMDIR=${SIMDIR}_var
RUNDIR=$(pwd)

for (( s=0; s<${NSIM}; s=s+1 )) ; do

    cd ${RUNDIR}

    seed=$(date +'%s')
    LOG=${SIMDIR}/runvar_${seed}.log

    ${RVAR} ${seed} > ${LOG}    

    names=($(cat variation_values.tsv | grep -v '#' | cut -f2))
    values=($(cat variation_values.tsv | grep -v '#' | cut -f3))
    types=($(cat variation_values.tsv |  grep -v '#' |cut -f1))
    
#echo ${names[*]}

    cd ${SIMDIR}

    for (( i=0; i<${#names} ; i=i+1 )) ; do
	n=${names[$i]}
	v=${values[$i]}
	t=${types[$i]}
	
#   echo $t $n=$v
    
  #sed '/'"$var"'/p' filename
	mv ${PREFIX}.init tmp.init
	mv ${PREFIX}.opar tmp.opar
	mv ${PREFIX}.par tmp.par
	mv ${PREFIX}.dat tmp.dat
	sed  '/'"$n"'/  s/^.*$/'"$t\t$n\t$v"'/' tmp.init > ${PREFIX}.init
	sed  '/'"$n"'/  s/^.*$/'"$t\t$n\t$v"'/' tmp.dat  > ${PREFIX}.dat
	sed  '/'"$n"'/  s/^.*$/'"$t\t$n\t$v"'/' tmp.opar > ${PREFIX}.opar
	sed  '/'"$n"'/  s/^.*$/'"$t\t$n\t$v"'/' tmp.par > ${PREFIX}.par
     done

    cd ${RUNDIR} 

    ${GLUES} ${SIMDIR}/${PREFIX}.sim >> ${LOG}


done

#src/glues examples/simulations/685/lbk.sim
