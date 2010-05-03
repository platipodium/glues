#!/bin/bash

g++  -g -O2  -I../.. -L/opt/local/lib -o $1 $1.cc -lnetcdf_c++ -lnetcdf -lm 

