/* GLUES nc_regionmap; this file is part of
   the Global Land Use and technological Evolution Simulator
   
   Copyright (C) 2010
   Carsten Lemmen <carsten.lemmen@hzg.de>

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
   @author Carsten Lemmen <carsten.lemmen@hzg.de>
   @date   2010-10-19
   @file nc_regionmap.cc
*/

#include "config.h"
#include <string>
#include <ctime>
#include <iostream>
#include <fstream>

#ifdef HAVE_NETCDF_H
#include "netcdfcpp.h"
#endif

int main(int argc, char* argv[]) 
{

#ifndef HAVE_NETCDF_H
    std::cout << " No netcdf interface defined. FAIL" << std::endl;
    return 1;
#else
  
  std::string input_filename="../../visual/matlab/glues_regionid.rst";
  std::string filename="glues_map.nc";
   
  const int ntime=0;
   
  NcFile ncfile(filename.c_str(), NcFile::Replace);
  if (!ncfile.is_valid()) return 1;
  
  time_t today;
  time(&today);
  std::string s1(asctime(gmtime(&today)));
  std::string timestring=s1.substr(0,s1.find_first_of("\n"));
  
  ncfile.add_att("Conventions","CF-1.4");
  ncfile.add_att("title","GLUES netCDF region raster in CF conventions");
  ncfile.add_att("history","Created by nc_regionmap");
  ncfile.add_att("institution","Helmholtz-Zentrum Geesthacht GmbH");
  ncfile.add_att("address","Max-Planck-Str 1, 21502 Geesthacht, Germany");
  ncfile.add_att("principal_investigator","Carsten Lemmen");
  ncfile.add_att("email","carsten.lemmen@hzg.de");
  ncfile.add_att("model_name","GLUES");
  ncfile.add_att("model_version","1.1.7");
  ncfile.add_att("source","GLUES model 1.1.7");
  ncfile.add_att("comment","Background climate provided by Climber-2 anomalies on IIASA database");
  ncfile.add_att("references","Wirtz & Lemmen, Climatic Change 2003; Lemmen, Geomorphologie 2009");
  ncfile.add_att("date_of_creation",timestring.c_str());
  ncfile.add_att("filenames_input",(input_filename).c_str());
  ncfile.add_att("filenames_output",filename.c_str());
  

  std::ifstream ifs(input_filename.c_str(),std::ios::in);
  if (!ifs.good()) return 1;
  
// Define and read grid
  const unsigned int ncol=720;
  const unsigned int nrow=360;
  const float dx=0.5; 
  const float dy=0.5;
  const float lly=-89.75;
  const float llx=-179.75;
  int id[ncol][nrow];
  float lat[nrow];
  float lon[ncol];
  
  for (int irow=0; irow<nrow; irow++)
    for (int icol=0; icol<ncol; icol++)
      ifs >> id[icol][irow];

  for (int i=0; i<ncol; i++) lon[i]=llx+i*dx;
  for (int i=0; i<nrow; i++) lat[nrow-1-i]=lly+i*dy;
  

  
  //float region[nreg];
 // for (int i=0; i<nreg; i++) region[i]=1+i;
  
  // Create time and region dimensions, copy all others
  // CF-Convention is T,Z,Y,X
  NcDim* dim;
  if (!(dim = ncfile.add_dim("time", 0))) return 1;
  if (!(dim = ncfile.add_dim("lat", nrow))) return 1;
  if (!(dim = ncfile.add_dim("lon", ncol))) return 1;
 
/*  time_t today;
  std::time(&today);
  string s1(asctime(gmtime(&today)));
  string timestring=s1.substr(0,s1.find_first_of("\n"));
*/
  
  // Create coordinate variables and copy all       
  NcVar *var;
  if (!(var = ncfile.add_var("lat", ncFloat, ncfile.get_dim("lat")))) return 1;
  var->add_att("date_of_creation",timestring.c_str());
  var->add_att("long_name","latitude");
  var->add_att("standard_name","latitude");
  var->add_att("units","degree_north");
  var->add_att("axis","Y");
  
  if (!(var = ncfile.add_var("lon", ncFloat, ncfile.get_dim("lon")))) return 1;
  var->add_att("date_of_creation",timestring.c_str());
  var->add_att("long_name","longitude");
  var->add_att("standard_name","longitude");
  var->add_att("units","degree_east");
  var->add_att("axis","X");

  if (!(var = ncfile.add_var("time", ncFloat, ncfile.get_dim("time")))) return 1;
  var->add_att("date_of_creation",timestring.c_str());
  var->add_att("long_name","time");
  var->add_att("standard_name","time");
  var->add_att("calendar","none");
  var->add_att("units","days since 0001-01-01 00:00:00.00");
  var->add_att("axis","T");

  // Create variables
  if (!(var = ncfile.add_var("id", ncFloat, ncfile.get_dim("lon"),ncfile.get_dim("lat")))) return 1;
  var->add_att("date_of_creation",timestring.c_str());
  var->add_att("standard_name","region_id");
  var->add_att("long_name","region identifier");
  var->add_att("description","Unique identifier of land (positive) or sea (negative) region");
  var->add_att("units","");
 
  // Fill variables with values
  var=ncfile.get_var("time");
  float time=0;
  var->put_rec(ncfile.rec_dim(),&time,0);

  var=ncfile.get_var("lat");
  var->put(lat,nrow);
  
  var=ncfile.get_var("lon");
  var->put(lon,ncol);
  
  var=ncfile.get_var("id");
  int *id_ptr = id[0];
  var->put(id_ptr,ncol,nrow);

  ifs.close();
  ncfile.close();
 
 return 0;
#endif
}

