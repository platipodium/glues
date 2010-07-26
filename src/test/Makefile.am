# Makefile for GLUES sources.

# Copyright (C) 2008,2009,2010
# Carsten Lemmen <carsten.lemmen@gkss.de>, GKSS-Forschungszentrum Geesthacht

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

TESTS= test_GeoRegion test_LandRegion test_Population \
	test_TechnologyTrait test_CulturePopulation test_CultureRegion \
	test_IO test_netcdf

check_PROGRAMS = $(TESTS)

noinst_HEADERS = ../GeoRegion.h ../GeoNeighbour.h ../Symbols.h ../LandRegion.h \
	../Constants.h ../LocalClimate.h ../Population.h ../EffectiveVariable.h \
	../TechnologyTrait.h ../CulturePopulation.h ../CultureRegion.h \
	../FarmingQuotaTrait.h ../DomesticationFractionTrait.h

EXTRA_DIST = georegions.tsv test_IO.tsv test_glues_distribution.sh test_glues_build.sh

noinst_SCRIPTS = test_glues_build.sh test_glues_distribution.sh

test_netcdf_SOURCES=test_netcdf.cc
test_netcdf_LDADD=-lnetcdf -lnetcdf_c++

test_GeoRegion_SOURCES = ../GeoRegion.cc ../GeoNeighbour.cc test_GeoRegion.cc

test_LandRegion_SOURCES=../GeoRegion.cc ../GeoNeighbour.cc ../LandRegion.cc  \
	../LocalClimate.cc \
	test_LandRegion.cc

test_Population_SOURCES=../Population.cc test_Population.cc

test_TechnologyTrait_SOURCES=../TechnologyTrait.cc test_TechnologyTrait.cc \
	../EffectiveVariable.cc

test_CulturePopulation_SOURCES=../TechnologyTrait.cc ../CulturePopulation.cc \
	../CultureRegion.cc ../Population.cc test_CulturePopulation.cc \
	../EffectiveVariable.cc ../GeoRegion.cc ../GeoNeighbour.cc ../LandRegion.cc  \
	../LocalClimate.cc ../FarmingQuotaTrait.cc ../DomesticationFractionTrait.cc

test_CultureRegion_SOURCES=../TechnologyTrait.cc ../CulturePopulation.cc \
	../CultureRegion.cc ../Population.cc test_CultureRegion.cc \
	../EffectiveVariable.cc ../GeoRegion.cc ../GeoNeighbour.cc ../LandRegion.cc  \
	../LocalClimate.cc ../FarmingQuotaTrait.cc ../DomesticationFractionTrait.cc

test_IO_SOURCES=../IO.cc test_IO.cc
