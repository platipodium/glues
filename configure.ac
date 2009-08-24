dnl Process this file with autoconf to produce a configure script.
AC_PREREQ(2.59)

dnl Versioning: please increase micro version at each running version

m4_define(GLUES_MICRO_VERSION,3)
m4_define(GLUES_MINOR_VERSION,1)
m4_define(GLUES_MAJOR_VERSION,1)
m4_define(GLUES_VERSION,GLUES_MAJOR_VERSION.GLUES_MINOR_VERSION.GLUES_MICRO_VERSION)

AC_INIT([GLUES],GLUES_VERSION,[carsten.lemmen@gkss.de])

dnl configuring options

AC_CONFIG_AUX_DIR([config])
AC_CONFIG_SRCDIR([src/Glues.cc])
AM_CONFIG_HEADER([config.h])

dnl defining version and package
ALL_LINGUAS="en de"
#AM_GNU_GETTEXT
AM_INIT_AUTOMAKE([glues], $GLUES_VERSION)
#AM_MAINTAINER_MODE

dnl Optimization or debug
AC_DEFINE([DEBUG], [], [Debugging enabled])
AC_ARG_ENABLE(debug,[  --enable-debug enables debug support [default=no]],DEBUG=$enableval,DEBUG=no)
if test "x$DEBUG" = "xyes" ;
then 
  echo "Enabling debug support"
  AC_DEFINE(DEBUG)
else
  echo "Disabling debug support"
fi

dnl Check for programs	
AC_PROG_LIBTOOL
AC_PROG_CXX
#AX_GXX_VERSION
AC_LANG_CPLUSPLUS
AC_PROG_CC # for region package

dnl Check for multiprocessing
#AX_MPI from autoconf archive

dnl Check for libraries
AC_CHECK_LIB(m,cos) # for region package
AC_CHECK_LIB(m,min) 
AC_CHECK_LIB(m,max)
#AC_CHECK_LIB(intl,bindtextdomain)
	
dnl Checking for SiSi in explicit configure setting

AC_ARG_WITH(sisi,
	[AS_HELP_STRING([with-sisi=DIR],
                        [SISI install directory (overrides SISIPATH and local SiSi)])],
        [
	  sisi_path="$withval"
          sisi_lib_path="$withval/lib"
	  sisi_include_path="$withval/include"]
)
AC_ARG_WITH(sisi_include,
   [  --with-sisi-include=DIR  SISI include directory ],
   sisi_include_path="$withval")
AC_ARG_WITH(sisi_lib,
   [  --with-sisi-lib=DIR      SISI lib directory ], [
   sisi_lib_path="$withval"]
)

dnl SiSi default locations on SISIPATH or in local dir
LOCALSISI=0
test -z ${sisi_path} && sisi_path=${SISIPATH}
if test -z ${sisi_path} ; then
  sisi_path=$(pwd)/src/sisi
  LOCALSISI=1
fi
AC_SUBST(LOCALSISI)

dnl SiSi include and libary paths
test -z ${sisi_include_path} && sisi_include_path="${sisi_path}/include"
test -z ${sisi_lib_path} && sisi_lib_path="${sisi_path}/lib"

LDFLAGS="$LDFLAGS  -L${sisi_lib_path}"
CPPFLAGS="$CPPFLAGS -I${sisi_include_path}"


AC_MSG_NOTICE([Including SiSi headers from ${sisi_include_path}])
AC_MSG_NOTICE([Linking to SiSi library in  ${sisi_lib_path}])

dnl Check SISI Header
AC_MSG_CHECKING(for SiSi's Version.hh)
AC_COMPILE_IFELSE([AC_LANG_SOURCE([[
#include "Version.hh"
]])],[AC_MSG_RESULT(yes)
      LIBS="$LIBS -lSiSi2.0"
   ],[
 AC_MSG_RESULT(no)
 AC_MSG_ERROR([SiSi header can't be found, please set --with-sisi option.])
])

# FIXME	AC_DEFINE(HAVE_SISI,[],"Whether we have the SiSi package")],
dnl Check if we can link with SiSi
#AC_CHECK_LIB(SiSi2.0, SiSi::finalize(), [LIBS="-lSiSi2.0 $LIBS"],
# [AC_MSG_ERROR(libSiSi2.0 not found or uses a different ABI..)])

dnl AC_SEARCH_LIBS([SiSi::finalize()],[sisi,SiSi,SiSi2.0],
	#[],[],[])

# it is better to use ac_serach libs over ac_check_lib
dnl AC_SEARCH_LIBS (function, search-libs, [action-if-found], [action-if-not-found], [other-libraries])

dnl Checking for netcdf 
netcdf_path=""
netcdf_include_path=""
netcdf_lib_path=""

AC_ARG_WITH(netcdf,
	[AS_HELP_STRING([with-netcdf=DIR],
                        [NETCDF install directory])],
        [
	if test "x${withval} != xno" ; then 
	  netcdf_path="${withval}"
          netcdf_lib_path="${withval}/lib"
	  netcdf_include_path="${withval}/include"
	else
	  netcdf_path=none
        fi	  
	]
)

if test "x${netcdf_path}" != "no" ; then

   dnl save old status of affected flags
   OLD_LDFLAGS="$LDFLAGS"
   OLD_CPPFLAGS="$CPPFLAGS"
   OLD_LIBS="$LIBS"

   if test "x${netcdf_path}" != "x" ; then
     dnl custom directories set
     LDFLAGS="$LDFLAGS -L$netcdf_lib_path"
     CPPFLAGS="$CPPFLAGS -I$netcdf_include_path"
     LIBS="$LIBS -lnetcdf_c++ -lnetcdf"
   else
     dnl automatic search, try compilers and ncdump
     AC_PATH_PROG(NCDUMP, ncdump, "no")
      if test "x$NCDUMP" = "xno" ; then :
      fi
  fi

   AC_CHECK_HEADERS([netcdf.h])
   AC_CHECK_HEADERS([netcdfcpp.h])
   AC_CHECK_LIB(netcdf,ncclose)
   AC_CHECK_LIB(netcdf_c++,ncclose)
  
else

      GLUES_WARNING([Compiling without netcdf support])
fi



#AC_DISABLE_SHARED
AC_C_BIGENDIAN( [LITTLE_ENDIAN=], [LITTLE_ENDIAN=-DLITTLE_ENDIAN=BYTE_ORDER] )
AC_SUBST(LITTLE_ENDIAN)

# Checks for header files.
#AC_HEADER_STDC
AC_CHECK_HEADERS([locale.h])

dnl Make sure all the necessary standard headers are installed on the system.
AC_CHECK_HEADER(iostream, , GLUES_ERROR([The standard <iostream> header file could not be found.]))
AC_CHECK_HEADER(vector, , GLUES_ERROR([The standard <vector> header file could not be found.]))
AC_CHECK_HEADER(list, , GLUES_ERROR([The standard <list> header file could not be found.]))
AC_CHECK_HEADER(map, , GLUES_ERROR([The standard <map> header file could not be found.]))
AC_CHECK_HEADER(string, , GLUES_ERROR([The standard <string> header file could not be found.]))
AC_CHECK_HEADER(algorithm, , GLUES_ERROR([The standard <algorithm> header file could not be found.]))
AC_CHECK_HEADER(cstring, , GLUES_ERROR([The standard <cstring> header file could not be found.]))

# Checks for typedefs, structures, and compiler characteristics.
#AC_HEADER_STDBOOL
#AC_C_CONST
#AC_C_INLINE

# Checks for library functions.
#AC_FUNC_ERROR_AT_LINE
AC_FUNC_MALLOC
AC_CHECK_FUNCS([pow exp sqrt strstr strrchr])

#AC_ARG_WITH(sisi, [ --with-sisi location of SISI library])
#if test x"$with_openssl" != "x" ; then
#AC_CHECK_LIB(SiSi2.0,_ZN6StringC2Ev)
#fi

AC_DEFINE([WITH_GNUPLOT],[],[Which gnuplot to use])
AC_PATH_PROG(GNUPLOT, gnuplot, "no")
if test "x$GNUPLOT" = "xno" ; then
  GLUES_WARNING([Optional program gnuplot not found])
else
  AC_DEFINE(WITH_GNUPLOT,"$GNUPLOT")
fi

AC_DEFINE([WITH_DOXYGEN],[],[Which doxygen to use])
AC_PATH_PROG(DOXYGEN, doxygen, "no")
if test "x$DOXYGEN" = "xno" ; then
  GLUES_WARNING([Doxygen not found but required to build documentation])
else
  AC_DEFINE(WITH_DOXYGEN,"$DOXYGEN")
fi





dnl Remove also many MACROS (AC_DEFINE) which are unused by GLUES
dnl and polluate (and slow down because libtool has to parse them) the build.
if test -f confdefs.h; then
  sed '/#define PACKAGE_/d' <confdefs.h >confdefs.tmp
  sed '/#define HAVE_STRING/d' <confdefs.tmp >confdefs.h
  sed '/#define HAVE_ALLOCA /d' <confdefs.h >confdefs.tmp
  sed '/#define HAVE_DLFCN_H/d' <confdefs.tmp >confdefs.h
  sed '/#define HAVE_MEM/d' <confdefs.h >confdefs.tmp
  sed '/#define STDC_HEADERS/d' <confdefs.tmp >confdefs.h
  sed '/#define HAVE_STRTOL/d' <confdefs.h >confdefs.tmp
  sed '/#define HAVE_STDLIB_H/d' <confdefs.tmp >confdefs.h
  sed '/#define HAVE_UNISTD_H/d' <confdefs.h >confdefs.tmp
  sed '/#define HAVE_STDC_HEADERS/d' <confdefs.tmp >confdefs.h
  sed '/#define HAVE_LONG_DOUBLE/d' <confdefs.h >confdefs.tmp
  sed '/#define HAVE_SYS_STAT_H/d' <confdefs.tmp >confdefs.h
  sed '/#define HAVE_SYS_TYPES_H/d' <confdefs.h >confdefs.tmp
  sed '/#define PROTOTYPES/d' <confdefs.tmp >confdefs.h
  sed '/#define __PROTOTYPES/d' <confdefs.h >confdefs.tmp
  mv confdefs.tmp confdefs.h
fi


AC_CONFIG_FILES([Makefile 
  src/Makefile src/region/Makefile src/sisi/Makefile
  src/test/Makefile config/Makefile
  src/variation/Makefile
  examples/Makefile examples/setup/Makefile 
  examples/setup/938/Makefile
  examples/setup/939/Makefile
  examples/setup/685/Makefile examples/results/Makefile
  examples/results/685/Makefile
  examples/results/938/Makefile
  examples/results/939/Makefile
  examples/simulations/Makefile examples/simulations/685/Makefile
  examples/simulations/938/Makefile
  examples/simulations/test_new_event/Makefile
  visual/Makefile visual/matlab/Makefile
  variation/Makefile doc/Makefile
])


#  po/Makefile.in

AC_OUTPUT

GLUES_CHECK_ERRORS
