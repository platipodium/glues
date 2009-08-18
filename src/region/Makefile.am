# Makefile for GLUES sources.

# Copyright (C) 2007 Carsten Lemmen, GKSS-Forschungszentrum Geesthacht

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

bin_PROGRAMS = region

noinst_HEADERS = defines.h random.h vars.h
region_SOURCES = attach.c gbinary.c input.c reg_eval.c region.c utils.c

region_LDADD=-lm

# The following are copied from the original file
# Used with ImageMagick
#MOP	= `Magick-config --cflags --cppflags`
#MOL	= #-L/usr/X11R6/lib -L../lib -lMagick   -ltiff -lttf -ljpeg -lpng  -ldpstk -ldps -lXext -lXt  -lSM -lICE -lX11  -lbz2 -lz    -lm
#`Magick-config --ldflags --libs`
#DEFINES     = -D__UNIX__ -D_SAGE


