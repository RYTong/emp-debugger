dnl Configuration script for EWP.
dnl 
dnl Copyright (c) 2009-2010 Beijing RYTong Information Technologies, Ltd.
dnl All rights reserved.
dnl
dnl No part of this source code may be copied, used, or modified
dnl without the express written consent of RYTong.

AC_INIT(BOC_APP, 1.0)
echo "Configuring ${PACKAGE_STRING}"

dnl
dnl Configuration templates
dnl
builtin(include, ./build/configure.in.head)

dnl Assuming current dir is the top source dir.
APP_TOP=`absolutize $PWD`
if ! test -e "$APP_TOP/configure" ; then
   AC_MSG_ERROR([We should configure in the top source directory.])
fi
AC_SUBST(APP_TOP)

dnl Common setup
builtin(include, ./build/configure.in.shlib)
builtin(include, ./build/configure.in.debug)

dnl Libraries
builtin(include, ./build/configure.in.erlang)
builtin(include, ./build/configure.in.yaws)
builtin(include, ./build/configure.in.ewp)

dnl
dnl Output files.
dnl

define(AcOutputFiles,
       Makefile
       Emakefile
       build/Makefile.include.c_vars
       drivers/Makefile)

dnl Put everything together and generate output.
builtin(include, ./build/configure.in.tail)
