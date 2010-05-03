/* GLUES nc_pangaea; this file is part of
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
   @date   2010-04-27
   @file nc_pangaea.cc
*/

#include "config.h"
#include <string>
#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <cstdlib>
#include <cstdio>
#include <cmath>
#include <cstring>
#include <ctime>

#ifdef HAVE_NETCDF_H
#include "netcdfcpp.h"
#endif

using namespace std;

int copy_att(NcFile*,const NcAtt*);
int copy_att(NcVar*,const NcAtt*);
int append(NcAtt*,const char*);

int main(int argc, char* argv[]) 
{

#ifndef HAVE_NETCDF_H
    std::cerr << " No netcdf interface defined. FAIL" << std::endl;
    return 1;
#else
 
  string input_filename="pangaea_reg.nc";
  string region_filename="glues_map_dim.nc";
  string output_filename="pangaea.nc";
  
  NcFile ncin(input_filename.c_str(), NcFile::ReadOnly);
  if (!ncin.is_valid()) {
    std::cerr << " Input " << input_filename << " could not be read." << std::endl;
    return 1;
  }
   
  NcFile ncmap(region_filename.c_str(), NcFile::ReadOnly);
  if (!ncmap.is_valid()) {
    std::cerr << " Input " << region_filename << " could not be read." << std::endl;
    return 1;
  }
   
  NcFile ncfile(output_filename.c_str(), NcFile::Replace);
  if (!ncfile.is_valid()) {
    std::cerr << " Output " << output_filename << " could not be created." << std::endl;
    return 1;
  }

  // Get current time
  time_t today;
  std::time(&today);
  string s1(asctime(gmtime(&today)));
  string timestring=s1.substr(0,s1.find_first_of("\n"));
  
  // Create dimensions
  NcDim* dim;
  dim=ncmap.get_dim("lat");
  ncfile.add_dim(dim->name(),dim->size());
  dim=ncmap.get_dim("lon");
  ncfile.add_dim(dim->name(),dim->size());
  if (!(dim = ncfile.add_dim("time", 0))) return 1;
    
  // Copy global attributes
  for (int i=0; i<ncin.num_atts(); i++) {  
    copy_att(&ncfile,ncin.get_att(i));
  }
  if (ncfile.get_att("date_of_creation"))
    ncfile.add_att("date_of_modification",timestring.c_str());
  else
    ncfile.add_att("date_of_creation",timestring.c_str());    
  ncfile.add_att("filenames_input",(input_filename + ", " + region_filename).c_str());
  ncfile.add_att("filenames_output",output_filename.c_str());
  
  NcVar *var;
  NcVar *ivar;
  NcAtt *att;

  // Copy time dimension and variable from ncin
  int ntime=ncin.get_dim("time")->size();  
  float* time = new float[ntime];
  ivar=ncin.get_var("time");
  var=ncfile.add_var(ivar->name(), ivar->type(),ncfile.get_dim("time"));
  for (int i=0; i<ivar->num_atts(); i++) copy_att(var,ivar->get_att(i)); 
  ivar->get(time,ntime);
  var->put(time,ntime);
  
  // Copy lat/lon dimensions from ncmap
  int nlat=ncmap.get_dim("lat")->size();  
  float* lat = new float[nlat];
  ivar=ncmap.get_var("lat");
  var=ncfile.add_var(ivar->name(), ivar->type(),ncfile.get_dim("lat"));
  for (int i=0; i<ivar->num_atts(); i++) copy_att(var,ivar->get_att(i)); 
  ivar->get(lat,nlat);
  var->put(lat,nlat);
  
  int nlon=ncmap.get_dim("lon")->size();  
  float* lon = new float[nlon];
  ivar=ncmap.get_var("lon");
  var=ncfile.add_var(ivar->name(), ivar->type(),ncfile.get_dim("lon"));
  for (int i=0; i<ivar->num_atts(); i++) copy_att(var,ivar->get_att(i)); 
  ivar->get(lon,nlon);
  var->put(lon,nlon);
  
 
  /* Get region ids */
  int nreg=ncin.get_dim("region")->size();
  float* region=new float[nreg];
  var=ncin.get_var("region");
  var->get(region,nreg);
  
  /* Get map ids, make all sea equal to -1 and write to region variable */
  float* map=new float[nlon*nlat];
  ivar=ncmap.get_var("id");
  ivar->get(map,nlon,nlat);
  var=ncfile.add_var("region",ncShort,ncfile.get_dim("lon"),ncfile.get_dim("lat"));
  for (int i=0; i<nlon*nlat; i++) if (map[i]<0) map[i]=-1;
  var->put(map,nlon,nlat);
  
  short* pop=new short[nreg*ntime];
  short* tech=new short[nreg*ntime];
  short* farm=new short[nreg*ntime];
  short* econ=new short[nreg*ntime];
  short* val=new short[nlon*nlat];
  ivar=ncin.get_var("population_density");
  ivar->get(pop,ntime,nreg);
  ncin.get_var("technology")->get(tech,ntime,nreg);
  ncin.get_var("farming")->get(farm,ntime,nreg);
  ncin.get_var("economies")->get(econ,ntime,nreg);
  
  var=ncfile.add_var(ivar->name(),ivar->type(),ncfile.get_dim("time"),ncfile.get_dim("lon"),ncfile.get_dim("lat"));
  return 0;
  for (int t=0; t<1; t++) {
    /*for (int i=0; i<nlon*nlat; i++) {
      val[i]=0;
      if (map[i]>0) val[i]=pop[t+ntime*lroundf(map[i]-1)];
    }
    */
    //var->put_rec(val,t);
    cout << t << endl;
  }
      
  
  
  // Populate coordinate vars
  
  
  // Create coordinate variables and copy all       
  
  
  ncin.close();
  ncmap.close();
  ncfile.close();
 
 return 0;
#endif
}

int copy_att(NcFile* file, const NcAtt* att) { 
  // Copy a global attribute
  long attlen=att->num_vals();
  NcType atttype=att->type();
  NcValues* values=att->values();
  
  switch (atttype) {
	  case ncChar: 	file->add_att(att->name(),(char*)values->base()); break;
	  case ncByte: file->add_att(att->name(),attlen,(short*)values->base()); break;
	  case ncShort: file->add_att(att->name(),attlen,(short*)values->base()); break;
	  case ncInt: file->add_att(att->name(),attlen,(long*)values->base()); break;
	  case ncFloat: file->add_att(att->name(),attlen,(float*)values->base()); break;
	  case ncDouble: file->add_att(att->name(),attlen,(double*)values->base()); break;
  }
  return 0;
}

int copy_att(NcVar* var, const NcAtt* att) { 
  // Copy a global attribute
  long attlen=att->num_vals();
  NcType atttype=att->type();
  NcValues* values=att->values();
  
  switch (atttype) {
	  case ncChar: 	var->add_att(att->name(),(char*)values->base()); break;
	  case ncByte: var->add_att(att->name(),attlen,(short*)values->base()); break;
	  case ncShort: var->add_att(att->name(),attlen,(short*)values->base()); break;
	  case ncInt: var->add_att(att->name(),attlen,(long*)values->base()); break;
	  case ncFloat: var->add_att(att->name(),attlen,(float*)values->base()); break;
	  case ncDouble: var->add_att(att->name(),attlen,(double*)values->base()); break;
  }
  return 0;
}

int append(NcAtt* att, const char* ch) { 
  // Copy a global attribute
  long attlen=att->num_vals();
  NcType atttype=att->type();
  NcValues* values=att->values();
  string s1((char*)values->base());
  string s2 = s2.append(", " + string(ch));
  
  return 0;
}



