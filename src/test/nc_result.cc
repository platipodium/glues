/* GLUES nc_result; this file is part of
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
   @date   2009-08-07
   @file nc_glues.cc
*/

#include "config.h"
#include <string>
#include "iostream"

#ifdef HAVE_NETCDF_H
#include "netcdfcpp.h"
#endif

using namespace std;

int main(int argc, char* argv[]) 
{

#ifndef HAVE_NETCDF_H
    std::cout << " No netcdf interface defined. FAIL" << std::endl;
    return 1;
#else
 
  const int ntime=0;
  const int nreg=1;
  string filename="glues_template.nc";
   
  NcFile ncfile(filename.c_str(), NcFile::Replace);
  if (!ncfile.is_valid()) return 1;
  
  ncfile.add_att("Conventions","CF-1.4");
  ncfile.add_att("title","GLUES netcdf template in CF conventions");
  ncfile.add_att("history","Glues template netcdf file");
  ncfile.add_att("institution","GKSS-Forschungszentrum Geesthacht GmbH");
  ncfile.add_att("source","GLUES 1.1.7 model");
  ncfile.add_att("comment","");
  ncfile.add_att("references","Wirtz & Lemmen (2003), Lemmen (2009)");
  
  ncfile.add_att("model_name","GLUES");
  
  NcDim *regdim, *timedim;
  if (!(regdim  = ncfile.add_dim("region", nreg))) return 1;
  if (!(timedim = ncfile.add_dim("time", ntime))) return 1;
       
  NcVar *regionvar;
  if (!(regionvar = ncfile.add_var("region", ncFloat, regdim))) return 1;
  
  regionvar->add_att("units", "");
  regionvar->add_att("long_name","region_index");
  regionvar->add_att("standard_name","region_index");
  regionvar->add_att("description","Unique integer index of region");
  regionvar->add_att("valid_min",1.0);
  regionvar->add_att("coordinates","lon lat");
  
  //regionvar->add_att("_FillValue",1E-30);

  NcVar *timevar;
  timevar   = ncfile.add_var("time", ncFloat, timedim);
  timevar->add_att("units","years since 01-01-01");
  timevar->add_att("calendar","360_day");
  
  NcVar *latvar;
  latvar = ncfile.add_var("latitude",ncFloat, regdim);
  latvar->add_att("units","degrees_north");
  latvar->add_att("long_name","center_latitude");
  latvar->add_att("description","Latitude of region center");
  
  NcVar *lonvar;
  lonvar = ncfile.add_var("longitude",ncFloat, regdim);
  lonvar->add_att("units","degrees_east");
  lonvar->add_att("long_name","center_longitude");
  lonvar->add_att("description","longitude of region center");
  
  NcVar *techvar;
  techvar = ncfile.add_var("technology",ncFloat,timedim,regdim);
  techvar->add_att("long_name","technology_index");
  techvar->add_att("units","1");
  techvar->add_att("description","Relative technology index with respect to mesolithic hunters");

  NcVar *farmvar;
  farmvar = ncfile.add_var("farming",ncFloat,timedim,regdim);
  farmvar->add_att("long_name","farming_ratio");
  farmvar->add_att("units","1");
  farmvar->add_att("description","Fraction of agriculturalist and pastoralist activities in population");
 
  NcVar *econvar;
  econvar = ncfile.add_var("economies",ncFloat,timedim,regdim);
  econvar->add_att("long_name","economy_diversity");
  econvar->add_att("units","1");
  econvar->add_att("description","Number of diverse economic strategies");
    
  NcVar *densityvar;
  densityvar = ncfile.add_var("population_density",ncFloat,timedim,regdim);
  densityvar->add_att("units","km^-2");
  densityvar->add_att("long_name","population_density");
  densityvar->add_att("description","Population density");
   
  return 0;
#endif
}

