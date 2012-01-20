#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.59])
AC_INIT([SiSi], [2.0a], [carsten.lemmen@hzg.de])

AC_CONFIG_AUX_DIR([../../config])
AC_CONFIG_MACRO_DIR([../../config])'
AM_INIT_AUTOMAKE([SiSi],[2.0])

dnl automake-1.11 has AM_SILENT_RULES but we need to be 
dnl able to build on sunray as well which have 1.9
dnl the silent rule is switched on and can be disabled
dnl with ./configure --disable-silent-rules
m4_ifdef([AM_SILENT_RULES],[AM_SILENT_RULES([yes])])

AC_CONFIG_SRCDIR([include/cppinc.h])
AC_CONFIG_HEADERS([config.h])

dnl Platform configuration
AC_CANONICAL_HOST
AC_DEFINE_UNQUOTED(SISI_PLATFORM, "${host}",
[Define this to be the canonical name (cpu-vendor-os) of your system.])
AC_DEFINE_UNQUOTED(SISI_CPU, "${host_cpu}",
[Define this to be the name of the CPU of your system.])
AC_DEFINE_UNQUOTED(SISI_VENDOR, "${host_vendor}",
[Define this to be the name of the vendor of your system.])
AC_DEFINE_UNQUOTED(SISI_OS, "${host_os}",
[Define this to be the name of the OS of your system.])

SISI_PLATFORM="${host}"
AC_SUBST(SISI_PLATFORM)
SISI_OS="${host_os}"
AC_SUBST(SISI_OS)

case "${host_os}" in
  mingw*|windows*|winnt)
    AC_DEFINE(Win32, 1,
              [Define according to your operating system type.])
    SISI_OSTYPE="windows"
    ;;
  *)
    AC_DEFINE(__UNIX__, 1,
              [Define according to your operating system type.])
    SISI_OSTYPE="unix"
   ;;
esac
AC_SUBST(SISI_OSTYPE)

dnl End of platform configuration




# Checks for programs.
AC_PROG_CXX
AC_PROG_CC
AC_PROG_MAKE_SET
AC_PROG_RANLIB
AC_PROG_INSTALL
AC_PROG_AWK
AC_PROG_CPP
#AC_PROG_MKDIR_P
AC_PROG_LIBTOOL

# Specific DEBUG settings for sisi
#AC_DEFINE([__DESTRUCTOR_DEBUG__],[0],
#[Debug information on destructors in ResultElement and ResultReader])
#AC_DEFINE([__FILEPARSER_DEBUG__],[0],
#[Debug information in FileParser])
#AC_DEFINE([__SISSIPARSER_DEBUG__],[0],
#[Debug information in SiSiParser])
#AC_DEFINE([__STRING_DESTRUCTOR_DEBUG__],[0],
#[Debug information on String])

# Checks for libraries.
# FIXME: Replace `main' with a function in `-lm':
AC_CHECK_LIB([m], [cos])

# Checks for header files.
AC_CHECK_HEADERS([stdlib.h string.h])

# Checks for typedefs, structures, and compiler characteristics.
AC_HEADER_STDBOOL

# Checks for library functions.
AC_FUNC_ERROR_AT_LINE
AC_CHECK_FUNCS([sqrt])

AC_CONFIG_FILES([Makefile
                 config/Makefile
                 include/Makefile
                 include/common/Makefile
                 include/datastructures/Makefile
                 include/development/Makefile
                 include/math/Makefile
                 include/memory/Makefile
                 include/iostreams/Makefile
                 include/tree/Makefile
                 include/twowaylist/Makefile
                 lib/Makefile
                 src/Makefile
                 src/common/Makefile
                 src/datastructures/Makefile
                 src/development/Makefile
                 src/iostreams/Makefile
                 src/math/Makefile])
AC_OUTPUT
