#!/bin/sh

# GLUES weekly test for distribution version

if  [ "x$1" == "x" ] ; then
  VERSION=1.1.6
else
  VERSION=$1
fi

BASE=glues-$VERSION
TGZ=$BASE.tar.gz


url="http://downloads.sourceforge.net/project/glues/${TGZ}?use_mirror=surfnet"

owd=`pwd`
topdir=$HOME/.glues
tmp=$topdir/$BASE
log=$topdir/$BASE.log

test -d topdir || mkdir -p $topdir
test -d $tmp && rm -rf $tmp

echo $dat > $log

cd $topdir
test -f $TGZ || wget $url >> $log
tar xvf $TGZ 

if ! test -d $tmp ; then 
  echo "wget retrieval of $url faild" >> $log
  cd $owd
  exit 1
fi

cd $tmp
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
