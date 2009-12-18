#!/bin/sh

# GLUES daily test

url="http://glues.hg.sourceforge.net:8000/hgroot/glues/glues"

dat=`date +"%Y%m%d%H%M" `

owd=`pwd`
tmp=$HOME/.glues/glues-test-$dat
log=$HOME/.glues/$dat.log

test -d $tmp || mkdir -p $tmp
cd $tmp

echo $dat > $log
hg clone $url >> $log
cd glues
./bootstrap >> $log || echo "Bootstrap failed" >> $log 
./configure >> $log || echo "Configure failed" >> $log
./gmake     >> $log || echo "Make failed" >> $log
sh ./run.sh >> $log || echo "Run failed" >> $log

cd $owd
#rm -rf $tmp

exit
