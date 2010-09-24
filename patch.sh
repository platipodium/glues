#/bin/bash
# Patch current bugs

# 1. Patch dynamic lib of sisi to static lib
for F in src/Makefile src/region/Makefile src/variation/Makefile ; do
sed -i '/LIBS =/s#-lSiSi#'`pwd`'/src/sisi/lib/.libs/libSiSi.a#' $F; 
done

