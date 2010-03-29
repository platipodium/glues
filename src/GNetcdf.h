/* GLUES netcdf interface; this file is part of
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
   @date   2010-03-26
   @file   GNetcdf.h
*/

#ifndef glues_netcdf_h
#define glues_netcdf_h

#include <iostream>
#include <sstream>
#ifdef HAVE_CONFIG_H
  #include "config.h"
#endif

#ifdef HAVE_NETCDF_H
#include "netcdfcpp.h"

int gnc_write_header(NcFile&, int);

bool gnc_is_var(const NcFile&, const std::string&);
bool gnc_is_dim(const NcFile&, const std::string&);
bool gnc_is_att(const NcFile&, const std::string&);
bool gnc_is_att(const NcVar* , const std::string&);

bool gnc_check_var(NcFile&, const std::string&, const int);

int gnc_write_record(NcFile&, const std::string&, int**, const int irecord=-1);
int gnc_write_record(NcFile&, const std::string&, float**, const int irecord=-1);

#endif

#endif
