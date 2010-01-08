#!/bin/sh

# GLUES daily test

url="http://glues.hg.sourceforge.net:8000/hgroot/glues/glues"


HG=`which hg`
MAKE=`which gmake` 
DATE=`date +"%Y%m%d%H%M" `
OWD=`pwd`
SYS=`uname -a` 
HOST=`hostname` 

topdir=$HOME/.glues
tmp=$topdir/glues-test-$DATE-$HOST
log=$topdir/glues-test-$DATE-$HOST.log

test -d $topdir || mkdir -p $topdir
test -d $tmp && rm -rf $tmp

echo Glues daily build test $DATE > $log
echo On system $SYS >> $log

# test for execution of HG and MAKE variables
if test -x $HG ; then echo HG=$HG >> $log ; else 
  echo Mercurial CVS $HG not found. >> $log
  cd $OWD
  exit 1
fi
if test -x $MAKE ; then echo MAKE=$MAKE >> $log ; else
  echo make program $MAKE not found. >> $log
  cd $OWD
  exit
fi

cd $topdir
$HG clone $url $tmp >> $log
if test -d $tmp ; then :
else 
  echo "HG checkout faild" >> $log
  cd $OWD
  exit 1
fi

cd $tmp
./bootstrap >> $log 
if test -x configure ; then : 
else
  echo "Bootstrap failed" >> $log
  cd $OWD
  exit 1
fi
  
./configure >> $log 
if test -f Makefile ; then :
else
  echo "Configure failed" >> $log
  cd $OWD
  exit 1
fi
  
$MAKE -j4  >> $log 
if test -x src/glues ; then :
else/h/lemmen/opt/bin/test_glues_build.sh:
  echo "Make failed" >> $log
  cd $OWD
  exit 1
fi

./run.sh >> $log
if $? ; then : 
else 
  echo "Run failed" >> $log
  cd $OWD
  exit 1
fi

cd $OWD
#rm -rf $tmp

exit 0





$HG clone $url $tmp >> $log

cd $tmp
./bootstrap >> $log || echo "Bootstrap failed" >> $log 
./configure >> $log || echo "Configure failed" >> $log
$MAKE -j4    >> $log || echo "Make failed" >> $log
sh ./run.sh >> $log || echo "Run failed" >> $log

cd $OWD
#rm -rf $tmp

exit
