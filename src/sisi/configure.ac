#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.65])
AC_INIT([SiSi], [2.0], [carsten.lemmen@gkss.de])

AM_INIT_AUTOMAKE([SiSi],[2.0])

AC_CONFIG_SRCDIR([include/cppinc.h])
AC_CONFIG_HEADERS([config.h])

# Checks for programs.
AC_PROG_CXX
AC_PROG_CC
AC_PROG_MAKE_SET
AC_PROG_RANLIB

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
                 include/Makefile
                 include/common/Makefile
                 include/datastructures/Makefile
                 include/development/Makefile
                 include/math/Makefile
                 include/memory/Makefile
                 include/tree/Makefile
                 include/twowaylist/Makefile
                 src/Makefile
                 src/common/Makefile
                 src/datastructures/Makefile
                 src/development/Makefile
                 src/iostreams/Makefile
                 src/math/Makefile])
AC_OUTPUT
