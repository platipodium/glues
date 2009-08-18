dnl Additional macros used by configure.

dnl Usage: GLUES_ERROR(message)
dnl This macro displays the warning "message" and sets the flag glues_error
dnl to yes.
AC_DEFUN([GLUES_ERROR],[
glues_error_txt="$glues_error_txt
** $1
"
glues_error=yes])

dnl Usage: GLUES_WARNING(message)
dnl This macro displays the warning "message" and sets the flag glues_warning
dnl to yes.
AC_DEFUN([GLUES_WARNING],[
glues_warning_txt="$glues_warning_txt
== $1
"
glues_warning=yes])


dnl Usage: GLUES_WARNING(message)
dnl This macro displays the warning "message" and sets the flag glues_warning
dnl to yes.
AC_DEFUN([GLUES_INFO],[
glues_info_txt="$glues_info_txt
== $1
"
glues_info=yes])

dnl Usage: GLUES_CHECK_ERRORS
dnl (preferably to be put at end of configure.in)
dnl This macro displays a warning message if GLUES_ERROR or GLUES_WARNING
dnl has occured previously.
AC_DEFUN([GLUES_CHECK_ERRORS],[
if test "x${glues_error}" = "xyes"; then
    echo "**** The following problems have been detected by configure."
    echo "**** Please check the messages below before running \"make\"."
    echo "$glues_error_txt"
    if test "x${glues_warning_txt}" != "x"; then
        echo "${glues_warning_txt}"
    fi
    echo "deleting cache ${cache_file}"
    rm -f $cache_file
    else
        if test x$glues_warning = xyes; then
            echo "==========================================================="
            echo "=== configure has detected the following install options."
            echo "=== Please check the messages below before running \"make\"."
            echo "$glues_warning_txt"
        fi
    echo "Configuration done. Now type \"make\"."
fi])
