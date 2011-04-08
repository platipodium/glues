#/bin/bash
# Patch current bugs

# 1. Patch dynamic lib of sisi to static lib
#for F in src/Makefile src/region/Makefile src/variation/Makefile ; do
gsed -i '/LIBS =/s#-lSiSi#sisi/lib/.libs/libSiSi.a#' src/Makefile; 
#done

