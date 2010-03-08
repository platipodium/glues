/* GLUES nc_util.h this file is part of
   the Global Land Use and technological Evolution Simulator
   
   Copyright (C) 2010
   Carsten Lemmen <carsten.lemmen@gkss.de>

   This program is free software; you can redistribute it and/or modify it
   under the terms of the GNU General Public License as published by the
   Free Software Foundation; either version 2, or (at your option) any later
   version.

   This program is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
   Public License for more details.

   You should have received a copy of the GNU General Public License along
   with this program; if not, write to the Free Software Foundation, Inc.,
   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
*/
/**
   @author Carsten Lemmen <carsten.lemmen@gkss.de>
   @date   2010-03-06
   @file nc_util.h
   @brief Utility functions for netCDF file handling
*/

#ifndef nc_util_h
#define nc_util_h

#include "config.h"
#include <string>
#include <iostream>
#include <ctime>

#ifdef HAVE_NETCDF_H
#include "netcdfcpp.h"
#endif

using namespace std;

int copy_att(NcFile*,const NcAtt*);
int copy_att(NcVar*,const NcAtt*);
int append_att(NcAtt*,const char*);

#endif
