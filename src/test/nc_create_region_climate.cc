/* GLUES create_reg_climate; this file is part of
   the Global Land Use and technological Evolution Simulator
   
   Copyright (C) 2009,2010
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
   @date   2010-02-23
   @file create_reg_climate.cc
*/

#include "config.h"
#include <string>
#include <iostream>
#include <fstream>

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
  const int nreg=685;
  unsigned int i;
  
  string filename="reg_climate.nc";
   
  NcFile ncfile(filename.c_str(), NcFile::Replace);
  if (!ncfile.is_valid()) return 1;
  
  ncfile.add_att("Conventions","CF-1.4");
  ncfile.add_att("title","GLUES netcdf background climate");
  ncfile.add_att("history","Glues template netcdf file");
  ncfile.add_att("institution","GKSS-Forschungszentrum Geesthacht GmbH");
  ncfile.add_att("source","GLUES 1.1.9 model");
  ncfile.add_att("comment","");
  ncfile.add_att("references","Wirtz & Lemmen (2003), Lemmen (2009)");
  
  ncfile.add_att("model_name","GLUES");
  
  NcDim *regdim, *timedim;
  if (!(regdim  = ncfile.add_dim("region", nreg))) return 1;
  if (!(timedim = ncfile.add_dim("time"))) return 1;
       
  NcVar *regionvar;
  if (!(regionvar = ncfile.add_var("region", ncFloat, regdim))) return 1;
  float *region = new float[nreg];
  for (i=0; i<nreg; i++) region[i] = i+1.0;
  regionvar->put(region,nreg);
  delete [] region;
  
  regionvar->add_att("units", "");
  regionvar->add_att("long_name","region_index");
  regionvar->add_att("standard_name","region_index");
  regionvar->add_att("description","Unique integer index of region");
  regionvar->add_att("valid_min",1.0);
  regionvar->add_att("coordinates","lon lat");
  
  NcVar *timevar;
  timevar   = ncfile.add_var("time", ncFloat, timedim);
  timevar->add_att("units","years since 01-01-01");
  timevar->add_att("calendar","360_day");
  
  NcVar *gddvar;
  gddvar = ncfile.add_var("gdd",ncFloat, timedim,regdim);
  gddvar->add_att("units","d");
  gddvar->add_att("long_name","growing degree days above zero");
  gddvar->add_att("description","");
  gddvar->add_att("coordinates","lon lat");
  
  NcVar *nppvar;
  nppvar = ncfile.add_var("npp",ncFloat, timedim, regdim);
  nppvar->add_att("units","kg m-2 a-1");
  nppvar->add_att("long_name","net_primary_production");
  nppvar->add_att("description","Net primary production");
  nppvar->add_att("coordinates","lon lat");
  
    
  string gddname = "../../examples/setup/685/reg_npp_80_685.dat";
  ifstream ifs(gddname.c_str(),ios::in);  

  if (ifs.bad()) return 1;  

  ifs.seekg(0,ios::end);
  int length=ifs.tellg();
  ifs.seekg(0,ios::beg);
  
  float *fbuffer=new float [length];
  
  while (ifs.good()) ifs >> fbuffer[i++];
  ifs.close();  
 
  unsigned int nclim=(i-1)/nreg;
 
  float *time = new float[nclim];
  for (i=0; i<nclim; i++) time[i] = -9500.0 + i*500;
  timevar->put(time,nclim);
  
  
  gddvar->put(fbuffer,nclim,nreg);

  string nppname("../../examples/setup/685/reg_npp_80_685.dat");
  ifs.open(nppname.c_str(),ios::in);
  while (ifs.good()) ifs >> fbuffer[i++];
  ifs.close();
   nppvar->put(fbuffer,nclim,nreg);
  
  delete [] fbuffer;
  delete [] time;
  ncfile.close();  
       
  return 0;
#endif
}

