#!/bin/bash
D=examples/simulations/685
S=lbk

T0=$(grep TimeStart $D/$S.sim | cut -f3 | cut -d'.' -f1)
T1=$T0 #$(expr ${T0} + 1000)

gsed -i '/TimeStart/s/'$T0'/'$T1'/' $D/$S.sim

grep TimeStart $D/$S.sim
src/glues $D/$S.nc