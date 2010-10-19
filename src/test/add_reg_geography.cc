/* GLUES add_reg_geography; this file is part of
   the Global Land Use and technological Evolution Simulator
   
   Copyright (C) 2009,2010
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
   @date   2009-01-19
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
 
  unsigned int i;
  string filename="reg_geography.nc";
   
  NcError ncerror(NcError::verbose_nonfatal);
  NcFile ncfile(filename.c_str(), NcFile::Write);
  if (!ncfile.is_valid()) return 1;

  NcAtt* histatt=ncfile.get_att("history");
  int length=histatt->num_vals();
  char * cbuff  = new char[length];
  //for (i=0; i<length; i++) cbuff+i=histatt->as_string(i);
  cbuff=histatt->as_string(0);
  string history = "add_reg_gegraphy, " + string(cbuff);
  histatt->remove();
  ncfile.add_att("history",history.c_str());
  
  NcDim *regdim = ncfile.get_dim("region");
  int nreg = regdim->size();
         
  NcDim *timedim = ncfile.get_dim("time");
  int ntime = timedim->size();

  string regname = "../../examples/setup/685/region_geography.tsv";
  ifstream ifs(regname.c_str(),ios::in);  
  if (ifs.bad()) return 1;  

  ifs.seekg(0,ios::end);
  length=ifs.tellg();
  ifs.seekg(0,ios::beg);
  
  float *fbuffer=new float[length];
  while (ifs.good()) ifs >> fbuffer[i++];
  ifs.close();  
  
  length=(i-1)/nreg;
    
  float *record=new float[nreg];
  
  NcVar *latvar=ncfile.get_var("latitude");
  if (ncerror.get_err() != 0) {
    latvar = ncfile.add_var("latitude",ncFloat, regdim);
    latvar->add_att("units","degrees_north");
    latvar->add_att("long_name","center latitude");
    latvar->add_att("standard_name","latitude");
    latvar->add_att("description","Latitude of region center");
  }
  for (i=0; i<nreg; i++) record[i]=fbuffer[2+length*i];
  latvar->put(record,nreg);
  
  NcVar *lonvar=ncfile.get_var("longitude");
  if (ncerror.get_err() !=0 ) {
    lonvar = ncfile.add_var("longitude",ncFloat, regdim);
    lonvar->add_att("units","degrees_east");
    lonvar->add_att("standard_name","longitude");
    lonvar->add_att("long_name","center longitude");
    lonvar->add_att("description","longitude of region center");
  }
  for (i=0; i<nreg; i++) record[i]=fbuffer[3+length*i];
  lonvar->put(record,nreg);

  NcVar *var;
  { 
    NcError ncerror(NcError::silent_nonfatal);
    var=ncfile.get_var("area");
  }
  if (ncerror.get_err() !=0 ) {
    var = ncfile.add_var("area",ncFloat, regdim);
    var->add_att("units","km^2");
    var->add_att("long_name","area of region");
    var->add_att("description","Area of region");
    var->add_att("coordinates","longitude latitude");
  }
  for (i=0; i<nreg; i++) record[i]=fbuffer[4+length*i];
  var->put(record,nreg);
  
  delete [] record;
  delete [] fbuffer;
 
  ncfile.close();  
       
  return 0;
#endif
}

