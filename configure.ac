dnl Process this file with autoconf to produce a configure script.

dnl Minimum version of autoconf required
AC_PREREQ(2.59)

dnl only m4 macros are allowed before AC_INIT
dnl get version from file VERSION with some m4 magic
m4_define([GLUES_MICRO_VERSION],
 m4_bpatsubst(m4_esyscmd([cat VERSION]),
 [\([0-9]*\)\.\([0-9]*\)\.\([0-9a-z]*\)\(\w\|\W\)*],[\3]))
m4_define([GLUES_MINOR_VERSION],
 m4_bpatsubst(m4_esyscmd([cat VERSION]),
 [\([0-9]*\)\.\([0-9]*\)\.\([0-9a-z]*\)\(\w\|\W\)*],[\2]))
m4_define([GLUES_MAJOR_VERSION],
 m4_bpatsubst(m4_esyscmd([cat VERSION]),
 [\([0-9]*\)\.\([0-9]*\)\.\([0-9a-z]*\)\(\w\|\W\)*],[\1]))
m4_define([GLUES_VERSION],[GLUES_MAJOR_VERSION.GLUES_MINOR_VERSION.GLUES_MICRO_VERSION])

dnl Defines AC_PACKAGE_NAME, PACKAGE_NAME, AC_PACKAGE_TARNAME, PACKAGE_TARNAME
dnl Defines AC_PACKAGE_VERSION, PACKAGE_VERSION, AC_PACKAGE_STRING, PACKAGE_STRING
dnl Defines AC_PACKAGE_BUGREPORT, PACKAGE_BUGREPORT
AC_INIT([GLUES],[GLUES_VERSION],[carsten.lemmen@hzg.de],[glues])

#AC_COPYRIGHT broken on autoconf 2.61 sunray
#AC_COPYRIGHT ([[Carsten Lemmen and Kai W. Wirtz, Helmholtz-Zentrum Geesthacht]])

dnl configuring options for auxiliary directories
AC_CONFIG_AUX_DIR([config])
AC_CONFIG_SRCDIR([src/Glues.cc])
AC_CONFIG_MACRO_DIR([m4])

dnl configuration actions

# change the default prefix from /usr/local 
AC_PREFIX_DEFAULT([$HOME/opt])

dnl defining version and package
AM_INIT_AUTOMAKE([glues],[GLUES_VERSION])

dnl automake-1.11 has AM_SILENT_RULES but we need to be 
dnl able to build on sunray as well which have 1.9
dnl the silent rule is switched on and can be disabled
dnl with ./configure --disable-silent-rules
m4_ifdef([AM_SILENT_RULES],[AM_SILENT_RULES([yes])])

#AM_MAINTAINER_MODE
ALL_LINGUAS="en de"
#AM_GNU_GETTEXT

dnl Platform configuration
AC_CANONICAL_HOST
#AC_CANONICAL_BUILD
#AC_CANONICAL_TARGET
AC_DEFINE_UNQUOTED(GLUES_PLATFORM, "${host}",
[Define this to be the canonical name (cpu-vendor-os) of your system.])
AC_DEFINE_UNQUOTED(GLUES_CPU, "${host_cpu}",
[Define this to be the name of the CPU of your system.])
AC_DEFINE_UNQUOTED(GLUES_VENDOR, "${host_vendor}",
[Define this to be the name of the vendor of your system.])
AC_DEFINE_UNQUOTED(GLUES_OS, "${host_os}",
[Define this to be the name of the OS of your system.])

GLUES_PLATFORM="${host}"
AC_SUBST(GLUES_PLATFORM)
GLUES_OS="${host_os}"
AC_SUBST(GLUES_OS)

case "${host_os}" in
  mingw*|windows*|winnt)
    AC_DEFINE(Win32, 1,
              [Define according to your operating system type.])
    GLUES_OSTYPE="windows"
    ;;
  *)
    AC_DEFINE(__UNIX__, 1,
              [Define according to your operating system type.])
    GLUES_OSTYPE="unix"
   ;;
esac
AC_SUBST(GLUES_OSTYPE)

dnl End of platform configuration





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

dnl Check for libtool and changes to libtool
dnl disabling shared libs speeds up compilation significantly
LT_INIT([disable-shared])
AC_SUBST([LIBTOOL_DEPS])

dnl Check for programs
AC_PROG_CXX(["ccache g++" g++ c++ gpp aCC CC cxx cc++ cl.exe FCC KCC RCC xlC_r xlC])
#AX_GXX_VERSION
AC_LANG([C++])
AC_PROG_CC # for region package
# AC_PROG_AWK
# AC_PROG_RANLIB # for sisi (move to sisi configure?)

#AC_ARG_VAR (variable, description)
#Declare variable is a precious variable, and include its description in the variable section of `./configure --help'. 
AC_ARG_VAR(CC)
AC_ARG_VAR(CXX)

dnl Check for multiprocessing
#AX_MPI from autoconf archive

dnl Check for libraries
AC_SEARCH_LIBS(cos,m)
AC_SEARCH_LIBS(min,m)
AC_SEARCH_LIBS(exp,m)
AC_SEARCH_LIBS(pow,m)
AC_SEARCH_LIBS(sqrt,m)
AC_SEARCH_LIBS(bindtextdomain,intl)
	
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

AM_CONDITIONAL(LOCALSISI,test $LOCALSISI == 1)

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
      LIBS="$LIBS -lSiSi"
      SISILIBNAME=SiSi
   ],[
AC_COMPILE_IFELSE([AC_LANG_SOURCE([[
#include "Version.hh"
]])],[AC_MSG_RESULT(yes)
      LIBS="$LIBS -lSiSi2.0"
      SISILIBNAME=SiSi2.0
   ],[
 AC_MSG_RESULT(no)
 AC_MSG_ERROR([SiSi header can't be found, please set --with-sisi option.])
 ])
])

AC_SUBST(SISILIBNAME)

dnl FIXME	AC_DEFINE(HAVE_SISI,[],"Whether we have the SiSi package")],
dnl Check if we can link with SiSi
AC_SEARCH_LIBS(finalize,SiSi2.0) #,,,[SiSi sisi sisi2.0]
#AC_CHECK_LIB(SiSi2.0, SiSi::finalize, [LIBS="-lSiSi2.0 $LIBS"],
# [AC_MSG_ERROR(libSiSi2.0 not found or uses a different ABI..)])

#AC_SEARCH_LIBS([sisi_is_available],
#[sisi,SiSi,SiSi2.0],
#[AC_MSG_NOTICE([sisi library found : $ac_cv_search_sisi_is_available])],
#[AC_MSG_ERROR(libSiSi2.0 not found or uses a different ABI..)],[])


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
	  netcdf_path=no
        fi	  
	]
)

dnl if not explicitly excluded with with-netcdf=no option
if test "x${netcdf_path}" != "no" ; then

   dnl save old status of affected flags
   OLD_LDFLAGS="$LDFLAGS"
   OLD_CPPFLAGS="$CPPFLAGS"
   OLD_LIBS="$LIBS"

   if test "x${netcdf_path}" != "x" ; then
     dnl custom directories set
     LDFLAGS="$LDFLAGS -L$netcdf_lib_path"
     CPPFLAGS="$CPPFLAGS -I$netcdf_include_path"
   else
     dnl automatic search, try location of ncdump
     AC_PATH_PROG(NCDUMP, ncdump, "no")
      if test "x$NCDUMP" = "xno" ; then :
      else 
        netcdf_path=`dirname $NCDUMP`
        netcdf_path=`dirname $netcdf_path`
        netcdf_lib_path=$netcdf_path/lib
        netcdf_include_path=$netcdf_path/include
        LDFLAGS="$LDFLAGS -L$netcdf_lib_path"
        CPPFLAGS="$CPPFLAGS -I$netcdf_include_path"
      fi
  fi

dnl Include a generic call to check headers for autoconf
dnl version < 2.64, i.e. include fourth argument to the macro,
dnl see http://www.gnu.org/software/hello/manual/
dnl /autoconf/Present-But-Cannot-Be-Compiled.html
   AC_CHECK_HEADERS([netcdf.h],[],[],
       [[#ifdef HAVE_NETCDF_H
         #include <netcdf.h>
         #endif
       ]])
   AC_CHECK_HEADERS([netcdfcpp.h],[],[],
       [[#ifdef HAVE_NETCDFCPP_H
         #include <netcdfcpp.h>
         #endif
       ]])
   AC_CHECK_LIB(netcdf,ncclose)
   AC_CHECK_LIB(netcdf_c++,ncclose)
   AC_SEARCH_LIBS(ncclose,netcdf)
   AC_SEARCH_LIBS(ncclose,netcdf_c++)
  
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


#AC_FUNC_MALLOC
# If the malloc function is compatible with the GNU C library malloc (i.e., `malloc (0)' returns a valid pointer), define HAVE_MALLOC to 1. Otherwise define HAVE_MALLOC to 0, ask for an AC_LIBOBJ replacement for `malloc', and define malloc to rpl_malloc so that the native malloc is not used in the main project.
# Typically, the replacement file `malloc.c' should look like (note the `#undef malloc'):
#
#   @verbatim #if HAVE_CONFIG_H # include <config.h> #endif #undef malloc
#   #include <sys/types.h>
#   void *malloc ();
#    /* Allocate an N-byte block of memory from the heap. If N is zero, allocate a 1-byte block. */
#    void * rpl_malloc (size_t n) { if (n == 0) n = 1; return malloc (n); } 
#AC_FUNC_MALLOC
# AC_LIBOBJ(malloc.c)
# AC_CONFIG_LIBOBJ_DIR (arch)
# This can cause a nasty bug ::malloc not found

AC_CHECK_FUNCS([strstr strrchr])

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
dnl and pollute (and slow down because libtool has to parse them) the build.
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

dnl configure HEADERS, COMMANDS, LINKS, and FILES

AC_CONFIG_HEADERS([config.h])
#AC_CONFIG_LINKS

AC_CONFIG_COMMANDS([time-stamp], [date >time-stamp])

AC_CONFIG_FILES([run.sh:run.sh.in],[chmod +x run.sh])
AC_CONFIG_FILES([grid.sh:grid.sh.in],[chmod +x grid.sh])

AC_CONFIG_FILES([Makefile
  src/Makefile src/region/Makefile 
  src/test/Makefile config/Makefile
  src/variation/Makefile
  src/patch/Makefile
  src/Messages.cc
  examples/Makefile examples/setup/Makefile 
  examples/setup/938/Makefile
  examples/setup/939/Makefile
  examples/setup/685/Makefile
  examples/setup/plasim/Makefile
  examples/setup/62483/Makefile
  examples/results/Makefile
  examples/results/685/Makefile
  examples/results/938/Makefile
  examples/results/939/Makefile
  examples/simulations/pop/pop.sce
  examples/simulations/pop/pop.sim
  examples/simulations/pop/Makefile
  examples/simulations/685/lbk.sim
  examples/simulations/685/lbk.sce
  examples/simulations/1/Makefile
  examples/simulations/1/lbk.sce
  examples/simulations/2/Makefile
  examples/simulations/2/lbk.sce
  examples/simulations/netcdf/lbk.sce
  examples/simulations/netcdf/lbk.sim
  examples/simulations/62483/Makefile
  examples/simulations/62483/onekbc.sce
  examples/simulations/62483/onekbc.sim
  examples/simulations/eurolbk/eurolbk.sce
  examples/simulations/eurolbk/eurolbk.sim
  examples/simulations/eurolbk/Makefile
  examples/simulations/plasim/Makefile
  examples/simulations/plasim/plasim.sce
  examples/simulations/plasim/plasim.sim
  examples/simulations/Makefile examples/simulations/685/Makefile
  examples/simulations/938/Makefile
  examples/simulations/test_new_event/Makefile
  visual/Makefile 
  visual/matlab/Makefile visual/matlab/get_files.m visual/matlab/startup.m
  visual/matlab/lib/Makefile visual/matlab/data/Makefile 
  visual/matlab/doc/Makefile
  visual/tex/Makefile
  visual/python/Makefile
  visual/gnuplot/Makefile visual/plots/Makefile visual/plot/Makefile
  visual/plot/quicklook/Makefile
  variation/Makefile 
  doc/Makefile doc/pangaea/Makefile
])

if test $LOCALSISI = 1 ; then
  AC_CONFIG_SUBDIRS([src/sisi])
fi
 
#  po/Makefile.in

AC_OUTPUT

GLUES_CHECK_ERRORS
