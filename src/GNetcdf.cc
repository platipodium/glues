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
   @file   GNetcdf.cc
*/

#include "GNetcdf.h"
#include <iostream>

using namespace std;

#ifdef HAVE_NETCDF_H

int gnc_write_header(NcFile& ncfile, int nreg) {
  if (!ncfile.is_valid()) {
    cerr << "Could not open NetCDF file for writing " << endl;
    return 1;
  }
  
  ncfile.add_att("Conventions","CF-1.4");
  ncfile.add_att("title","GLUES");
  ncfile.add_att("history","File created");
  ncfile.add_att("institution","GKSS-Forschungszentrum Geesthacht GmbH");
  ncfile.add_att("source","GLUES 1.1.9 model");
  ncfile.add_att("comment","");
  ncfile.add_att("references","Wirtz & Lemmen (2003), Lemmen (2009)");
  ncfile.add_att("model_name","GLUES");
  
  NcDim *regdim, *timedim;
  if (!(regdim  = ncfile.add_dim("region", nreg))) return 1;
  if (!(timedim = ncfile.add_dim("time"))) return 1;
         
  return 0;
}


#endif
