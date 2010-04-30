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
 
  string input_filename="../../test.nc";
  string region_filename="glues_map.nc";
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
  if (!(dim = ncfile.add_dim("time", 0))) return 1;
  dim=ncmap.get_dim("lat");
  ncfile.add_dim(dim->name(),dim->size());
  dim=ncmap.get_dim("lon");
  ncfile.add_dim(dim->name(),dim->size());
return 0;
  
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
return 0;
  
  // Copy time dimension and coordinate variable 
  int ntime=ncin.get_dim("time")->size();  
  float* time = new float[ntime];
  NcVar *var;
  var=ncin.get_var("time");
  var->get(time,ntime);
  int ndim=var->num_dims();
  ncfile.add_var(var->name(), var->type(), var->get_dim(0));

return 0;
  int nreg=ncin.get_dim("region")->size();
  float* region=new float[nreg];
  var=ncin.get_var("region");
  var->get(region,nreg);
  return 0;

  // Populate coordinate vars
  

  
  // Create coordinate variables and copy all       
  NcVar *ncvar;

{
  NcError ncerror(NcError::silent_nonfatal);
  
  int nvar = ncin.num_vars();
  for (int i=0; i<nvar; i++) {
    var=ncin.get_var(i);
    if (ncvar=ncfile.get_var(var->name())) continue;
    
    int ndim=var->num_dims();
    if (ndim==1) ncvar=ncfile.add_var(var->name(), var->type(), var->get_dim(0));
    if (ndim==2) ncvar=ncfile.add_var(var->name(), var->type(), 
      var->get_dim(0),var->get_dim(1));
    if (ndim==3) ncvar=ncfile.add_var(var->name(), var->type(), 
      var->get_dim(0),var->get_dim(1),var->get_dim(2));
    if (ndim==4) ncvar=ncfile.add_var(var->name(), var->type(), 
      var->get_dim(0),var->get_dim(1),var->get_dim(2),var->get_dim(3));
    if (ndim==5) ncvar=ncfile.add_var(var->name(), var->type(), 
      var->get_dim(0),var->get_dim(1),var->get_dim(2),var->get_dim(3),var->get_dim(4));
  }
 }
 
 // For each target variable, look for corresponding attributes in source file and copy them
 for (int i=0; i<ncfile.num_vars(); i++) {
   var=ncfile.get_var(i);
   if (ncvar=ncin.get_var(var->name())) {
     for (int i=0; i<ncvar->num_atts(); i++) {  
       copy_att(var,ncvar->get_att(i));
     }
   }
 }
  
 var=ncfile.get_var("time");
  for (int i=0; i<ntime; i++) var->put_rec(ncfile.rec_dim(),time+i,i);
  //netcdf_copyvar(ncfile,ncrvar);  
  
  var=ncfile.get_var("region");
  //dim=var->get_dim(0);
  for (int i=0; i<nreg; i++)  var->put(region,nreg);  

  string s;
  vector<string>::iterator ivar;
  char data[nreg*sizeof(float)];
  float* result = (float*) data;
  int i;
  
  {
  NcError ncerror(NcError::silent_nonfatal);

  for (int itime=0; itime<ntime; itime++) 
  
    
    var=ncfile.get_var((*ivar).c_str());
    if (!var) {
      if (!strcmp((*ivar).c_str(),"Technology")) s="technology";
      else if (!strcmp((*ivar).c_str(),"Farming")) s="farming";
      else if (!strcmp((*ivar).c_str(),"Agricultures")) s="economies"; 
      else if (!strcmp((*ivar).c_str(),"Resistance")) s="resistance"; 
      else if (!strcmp((*ivar).c_str(),"Density")) s="population_density";
      else if (!strcmp((*ivar).c_str(),"Migration")) s="migration_rate";
      else if (!strcmp((*ivar).c_str(),"Climate")) s="climate";
      else if (!strcmp((*ivar).c_str(),"CivStart")) s="time_of_high_civilization";
      else if (!strcmp((*ivar).c_str(),"Birthrate")) s="rate_of_birth";
      var=ncfile.get_var(s.c_str());
        var->add_att("date_of_modification",timestring.c_str());
      
    }
    
    //cout << (*ivar) << "/" << s << "t=" << time[itime] << " r=" ; 
    result=(float*)data;
    //var->put_rec(result,itime);

      var->add_att("glues_name",(*ivar).c_str());
      var->add_att("glues_order",i);

    //for (i=0; i<nreg; i+=137) cout << result[i] << ",";
    //cout << endl;
    
    i++;
  }

  
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



