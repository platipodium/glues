# Makefile for GLUES sources.

# Copyright (C) 2007,2008,2009,2010
# Carsten Lemmen, GKSS-Forschungszentrum Geesthacht

## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3, or (at your option)
## any later version.

## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.

## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
## 02110-1301, USA.

SUBDIRS=sisi test variation patch region

bin_PROGRAMS = glues

#glues_DEPENDENCIES = sisi/lib/libSiSi2.0.a sisi/lib/libSiSi.la
glues_DEPENDENCIES = sisi/lib/libSiSi.la

noinst_HEADERS = \
Symbols.h \
Input.h \
Messages.h \
AsciiTable.h \
Constants.h \
Exchange.h \
GeographicalNeighbour.h \
GeographicalRegion.h \
GlobalClimate.h \
Globals.h \
MySiSi.hh \
PopulatedRegion.h \
RegionMapping.h \
RegionalClimate.h \
RegionalPopulation.h \
VegetatedRegion.h \
callSiSi.hh \
input.c.patch \
variables.h \
Tracer.h \
GeographicalWorld.h \
Continent.h  \
IO.h \
GNetcdf.h \
Data.h

EXTRA_DIST=Messages.cc.in
#Events.h IO.h

glues_SOURCES = \
AsciiTable.cc \
Exchange.cc \
GeographicalNeighbour.cc \
GeographicalRegion.cc \
GlobalClimate.cc \
Globals.cc \
Glues.cc \
Initialize.cc \
Input.cc \
PopulatedRegion.cc \
RegionMapping.cc \
RegionalClimate.cc \
RegionalPopulation.cc \
Spread.cc \
VegetatedRegion.cc \
callSiSi.cc \
Tracer.cc \
Messages.cc \
GeographicalWorld.cc \
Continent.cc \
GeoRegion.cc \
GeoNeighbour.cc \
IO.cc \
GNetcdf.cc

#Events.cc 
#dump_binary.c \
#printevents.c 

#Events.cc

#INCLUDES =  -I/usr/local/netcdf/gcc-4.3.1/include

glues_LDADD=  -lnetcdf -lnetcdf_c++ \
	 #/usr/local/netcdf/gcc-4.3.1/lib/libnetcdf_c++.a \
	 #/usr/local/netcdf/gcc-4.3.1/lib/libnetcdf.a \
	#-lintl
