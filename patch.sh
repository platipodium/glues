#/bin/bash
# Patch current bugs

if test -x gsed ; then SED=gsed; 
elif test -x sed ; then SED=sed;
else SED=sed
fi

# 1. Patch dynamic lib of sisi to static lib
#for F in src/Makefile src/region/Makefile src/variation/Makefile ; do
${SED} -i '/LIBS =/s#-lSiSi#sisi/lib/.libs/libSiSi.a#' src/Makefile; 
#done

