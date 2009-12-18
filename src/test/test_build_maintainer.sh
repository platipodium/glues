#!/bin/sh

# GLUES daily test

url="http://glues.hg.sourceforge.net:8000/hgroot/glues/glues"

dat=`date +"%Y%m%d%H%M" `

owd=`pwd`
topdir=$HOME/.glues
tmp=$topdir/glues-test-$dat
log=$topdir/$dat.log

test -d topdir || mkdir -p $topdir
test -d $tmp && rm -rf $tmp

echo $dat > $log

cd $topdir
hg clone $url $tmp >> $log
if ! test -d $tmp ; then 
  echo "HG checkout faild" >> $log
  cd $owd
  exit 1
fi

cd $tmp
./bootstrap >> $log 
if test -x configure ; then : 
else
  echo "Bootstrap failed" >> $log
  cd $owd
  exit 1
fi
  
./configure >> $log 
if test -f Makefile ; then :
else
  echo "Configure failed" >> $log
  exit 1
fi
  
gmake -j4  >> $log 
if ! test -x src/glues ; then
  echo "Make failed" >> $log
  cd $owd
  exit 1
fi

./run.sh >> $log
if $? ; then : 
else 
  echo "Run failed" >> $log
  cd $owd
  exit 1
fi

cd $owd
#rm -rf $tmp

exit 0
