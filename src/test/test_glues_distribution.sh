#!/bin/sh

# GLUES daily test

url=" http://dfn.dl.sourceforge.net/project/glues/glues-1.1.7.tar.gz"

WGET=`which wget` 
MAKE=`which gmake` 
DATE=`date +"%Y%m%d%H%M" `
OWD=`pwd`
SYS=`uname -a` 
HOST=`hostname` 
NAME=`basename $url | sed 's/.tar.gz//'`
VERSION=`echo $NAME | sed 's/[-a-z].*//'`

topdir=$HOME/.glues
tmp=$topdir/glues-distro-$DATE-$HOST
log=$topdir/glues-distro-$DATE-$HOST.log

test -d $topdir || mkdir -p $topdir
test -d $tmp && rm -rf $tmp

echo Glues weekly distro test $DATE > $log
echo On system $SYS >> $log

# test for execution of HG and MAKE variables
if test -x $WGET ; then echo WGET=$WGET >> $log ; else 
  echo wget tool not found >> $log
  cd $OWD
  exit 1
fi
if test -x $MAKE ; then echo MAKE=$MAKE >> $log ; else
  echo make program $MAKE not found. >> $log
  cd $OWD
  exit
fi

cd $topdir
$WGET $url >> $log

gunzip --force  $NAME.tar.gz
tar xf $NAME.tar
mv $NAME $tmp

cd $tmp
  
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
