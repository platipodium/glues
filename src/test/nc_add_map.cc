/* GLUES nc_add_map; this file is part of
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
   @date   2010-03-18
   @file nc_add_map.cc
   @description This program adds a map (created by nc_regionmap) to a climate region file
   (created by nc_climateregions).  
*/

//#include "nc_util.h"

#include "config.h"
#include <string>
#include <ctime>
#include <cstdlib>
#include <iostream>
#include <fstream>
#include <cmath>
#include <cassert>
#include <cstring>

#ifdef HAVE_NETCDF_H
#include "netcdfcpp.h"
#endif

#ifndef M_PI
#define M_PI    3.14159265358979323846f
#endif

using namespace std;

bool is_var(NcFile*, std::string);

int main(int argc, char* argv[]) 
{

#ifndef HAVE_NETCDF_H
    std::cout << " No netcdf interface defined. FAIL" << std::endl;
    return 1;
#else
  
  /** You may need to run nc_regions to get regions.nc grid file
      You may need to rund nc_regionmap to create map file from raster file
   */


  string mapfilename="glues_map.nc";
  string cellfilename="regions_11k-2.nc";

 /** Open map file, read id and lat/lon fields  */
 
  NcFile ncm(mapfilename.c_str(), NcFile::ReadOnly);
  if (!ncm.is_valid()) return 1;

  int nrow=ncm.get_dim("lat")->size();
  int ncol=ncm.get_dim("lon")->size();

  float *lat = new float[nrow];
  ncm.get_var("lat")->get(lat,nrow);
  float *lon = new float[ncol];
  ncm.get_var("lon")->get(lon,ncol);
  int* id=new int[ncol*nrow];
  ncm.get_var("id")->get(id,ncol,nrow);
  ncm.close();

/** Read the cell file */

  NcFile ncc(cellfilename.c_str(), NcFile::Write);
  if (!ncc.is_valid()) { 
    std::cerr << "Regions file " << cellfilename << " not found." << std::endl
    << "Please run nc_climateregions to create this file." << std::endl;
    return 1;
  }

  NcVar* var, *varid;
  int natt;
  NcDim *dim;
  int ndim;

  dim=ncc.get_dim("region");
  long nland=dim->size();

  float *latit = new float[nland]; 
  ncc.get_var("lat")->get(latit,nland);
  float *longit = new float[nland];
  ncc.get_var("lon")->get(longit,nland);
    
  int * ilat=new int[nland];
  int * ilon=new int[nland];
  int * mapid=new int[nland];
  int minreg=nrow*ncol;
  int maxreg=0;
  for (int i=0; i<nrow*ncol; i++) {
    if (minreg>=id[i] && id[i]>=0) minreg=id[i];
    if (maxreg<=id[i] && id[i]>=0) maxreg=id[i];
  }
   
  /** Calculate new field mapid */
  float dx=0.5;
  float dy=0.5;
  int mid;
  for (int i=0; i<nland; i++) {
    mapid[i]=0;
    // +1 correction due to fault in glues_map.nc
    ilat[i]=(lat[0]-latit[i])/dy+1;
    ilon[i]=(longit[i]-lon[0])/dx-1;
    mid=id[ilon[i]*nrow+ilat[i]];
    if (mid>0) mapid[i]=mid;
  }
  
  time_t today;
  std::time(&today);
  string s1(asctime(gmtime(&today)));
  string monthstring=s1.substr(0,s1.find_first_of("\n"));
  
  /** Copy global attributes */
  NcAtt* att;
  //att=ncfile.get_att("history");
  //append_att(att,"nc_map2regions");
  ncc.add_att("date_of_modification",monthstring.c_str());
 
  if (is_var(&ncc,"map_id")) var=ncc.get_var("map_id");
  else var = ncc.add_var("map_id", ncInt, ncc.get_dim("region"));
  
  var->add_att("date_of_creation",monthstring.c_str());
  var->add_att("long_name","map_id");
  var->add_att("description",(string("mapped id from ") + mapfilename).c_str());
  var->add_att("source",mapfilename.c_str());
  
  var->put(mapid,nland);
 
  ncc.close();

  return 0;
#endif
}


bool is_var(NcFile* ncfile, std::string varname) {

  int n=ncfile->num_vars();
  NcVar* var;
 
  for (int i=0; i<n; i++) {
    var=ncfile->get_var(i);
    string name(var->name());
    if (name==varname) return true;
  }

  cerr << "NetCDF file does not contain variable \"" << varname << "\".\n";    
  return false;
}
