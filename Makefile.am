## Process this file with automake to produce Makefile.in
## This makefile is part of the glues distribution
##
## Copyright (C) 2007,2008, 2009, 2010,2011,2012
## Carsten Lemmen <carsten.lemmen@hzg.de>
## Helmholtz-Zentrum Geesthacht GmbH
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

AM_CPPFLAGS = -I ./src/sisi
 
EXTRA_DIST = ChangeLog run.sh run-euroclim.sh run-eurolbk.sh run-krisen.sh run-harappa.sh run-amant.sh bootstrap BUGS

SUBDIRS = src config examples variation visual doc #po intl

REVISION = `$MERCURIAL summary`

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
