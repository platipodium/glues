## Process this file with automake to produce Makefile.in
## This makefile is part of the glues distribution
##
## Copyright (C) 2010
## Carsten Lemmen <carsten.lemmen@gkss.de>
## GKSS-Forschungszentrum Geesthacht GmbH
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
## 02110-1301, USA.

LIBTOOL_DEPS = @LIBTOOL_DEPS@

ACLOCAL_AMFLAGS = -I config

EXTRA_DIST = ChangeLog BUGS MANIFEST TODO VERSION Makefile.am-todo Makefile.todo bootstrap

SUBDIRS = include lib src config

# Rule for rebuilding libtool if necessary
libtool: $(LIBTOOL_DEPS)
	$(SHELL) ./config.status --recheck

# Add pkgconfig support
#pkgconfigdir = $(libdir)/pkgconfig
#pkgconfig_DATA= $(PACKAGE)-$(VERSION).pc

.PHONY: snapshot

# Snapshot (rule from gtkextras)
snapshot:
	$(MAKE) dist distdir=$(PACKAGE)-`date +"%y%m%d"`

SRCDIR      = src


LIBOBJECTS  =   $(SRCDIR)/Version.o \
                $(SRCDIR)/platform.o \
                $(SRCDIR)/common/date.o \
                $(SRCDIR)/datastructures/Parameter.o \
                $(SRCDIR)/datastructures/ParameterType.o \
                $(SRCDIR)/datastructures/String.o \
                $(SRCDIR)/development/MessageHandler.o \
                $(SRCDIR)/development/ResultElement.o \
                $(SRCDIR)/development/ResultReader.o \
                $(SRCDIR)/development/ResultWriter.o \
                $(SRCDIR)/iostreams/FileParser.o \
                $(SRCDIR)/iostreams/SiSiParser.o \
                $(SRCDIR)/math/Random.o

INCOBJECTS = \
include/common/CharacterHandler.hh \
include/common/ClassObject.hh \
include/common/date.hh \
include/common/FilenameHandling.hh \
include/common/StringHandler.hh \
include/datastructures/ArrayParameter.hh \
include/datastructures/BooleanParameter.hh \
include/datastructures/CharParameter.hh \
include/datastructures/CommentParameter.hh \
include/datastructures/FloatParameter.hh \
include/datastructures/InfoType.hh \
include/datastructures/IntParameter.hh \
include/datastructures/ListParameter.hh \
include/datastructures/Parameter.hh \
include/datastructures/ParameterType.hh \
include/datastructures/ResultParameter.hh \
include/datastructures/String.hh \
include/datastructures/StringParameter.hh \
include/datastructures/TableParameter.hh \
include/development/EmitCxxCode.hh \
include/development/LogFile.hh \
include/development/MessageHandler.hh \
include/development/OutputStream.hh \
include/development/ResultElement.hh \
include/development/ResultReader.hh \
include/development/ResultWriter.hh \
include/development/SiSi.hh \
include/iostreams/FileParser.hh \
include/iostreams/SiSiParser.hh \
include/math/Math.hh \
include/math/Random.hh \
include/math/Round.hh \
include/memory/ArrayChecker.hh \
include/memory/MemoryHandler.hh \
include/platform.hh \
include/tree/Node.hh \
include/tree/Tree.hh \
include/twowaylist/TwoWayList.hh \
include/twowaylist/TwoWayListElement.hh \
include/twowaylist/TwoWayListFloatElement.hh \
include/twowaylist/TwoWayListIntElement.hh \
include/twowaylist/TwoWayListStringElement.hh \
include/Version.hh

lib_LTLIBRARIES = libSiSi.la
libSiSi_la_LIBADD =
libSiSi_la_LDFLAGS = -rpath '$(libdir)' -version-info 2:0:0 -no-undefined
libSiSi_la_SOURCES = $(LIBOBJECTS)
include_HEADERS = $(INCOBJECTS)