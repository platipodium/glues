#!/bin/bash

# Test the head of the repository 

TMP=/tmp/glues_test_head
OWD=`pwd`
DIR=$HOME/devel/mercurial

rm -rf $TMP
mkdir -p $TMP

cd $TMP
hg --quiet clone $DIR
cd mercurial
echo -n TEST bootstrap ...
test ./bootstrap > /dev/null && echo OK  
echo -n TEST configure ...
test ./configure > /dev/null && echo OK
echo -n TEST build ...
test gmake > /dev/null && echo OK
echo -n TEST runtime ...
test ./run.sh > /dev/null && echo OK
echo -n TEST distribution ...
gmake dist > /dev/null && echo OK
test $? 

cd $OWD
