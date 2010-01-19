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
   @date   2010-01-15
   @file nc_result.cc
*/

#include "config.h"
#include <string>
#include <iostream>
#include <fstream>
#include <vector>
#include <cstdlib>
#include <cstdio>
#include <cmath>
#include <cstring>
#include <map>

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
 
  string template_filename="glues_template.nc";
  string input_filename="../../examples/setup/685/results.out";
  string output_filename="results.nc";
   
  NcFile nctmpl(template_filename.c_str(), NcFile::ReadOnly);
  if (!nctmpl.is_valid()) return 1;
  
  ifstream ifs(input_filename.c_str(),ios::in | ios::binary);
  if (!ifs.good()) return 1;
  
  NcFile ncfile(output_filename.c_str(), NcFile::Replace);
  if (!ncfile.is_valid()) return 1;
  
  vector<string> vars;
  string line;
  
  // big endian versus low endian?
  
  char numvar; // matlab uint8
  ifs.get(numvar);
  
  for (char i=0; i<numvar; i++) {
    ifs >> line;
    vars.push_back(line);
  //  cout <<  line << endl;
  }

/*
Byte fields for nreg
00 40 2b 44
*/
  
  char dummy,ch4[20];
  ifs.get(dummy);
  ifs.read(ch4,20);
  
 // printf("%x %x %x %x\n",ch4[0],ch4[1],ch4[2],ch4[3]);
  
  float* fptr=(float*) (ch4);
  int nreg = (int)(*fptr);
  // The following check fails on big-endian systems
  if (nreg>1E6 || nreg < 1) return 1;  
  
  float tstart=*(fptr+1);  
  float tend  =*(fptr+2);
  float tstep =*(fptr+3);
  int ntime=ceil((tend-tstart)/tstep);
//  cout << nreg << " " << tstart << ":" << tstep << ":" << tend << " " << ntime << endl;
  
  
  // Populate coordinate vars
  float time[ntime];
  for (int i=0; i<ntime; i++) time[i]=tstart+i*tstep;
  float region[nreg];
  for (int i=0; i<nreg; i++) region[i]=1+i;
  
  // Create time and region dimensions, copy all others
  int ndim = nctmpl.num_dims();
  NcDim* dim;
  NcDim *rdim, *tdim;
  if (!(rdim = ncfile.add_dim("region", nreg))) return 1;
  if (!(tdim = ncfile.add_dim("time", 0))) return 1;
  for (int i=0; i<ndim; i++) {
    dim=nctmpl.get_dim(i);
    if (strncmp(dim->name(),"region",6)) continue;
    if (strncmp(dim->name(),"time",4)) continue;
    ncfile.add_dim(dim->name(),dim->size());
  }

  // Copy global attributes
  int natt = nctmpl.num_atts();
  NcAtt* att;
  for (int i=0; i<natt; i++) {
    att=nctmpl.get_att(i);
    long attlen=att->num_vals();
    NcType atttype=att->type();
    NcValues* values=att->values();
    int nbyte=values->bytes_for_one();
    char buffer[attlen*nbyte];
    //buffer = (char*)values;
    //ncfile.add_att(att->name(),att->
  }

  // Create coordinate variables and copy all       
  NcVar *var, *ncvar;
  if (!(var = ncfile.add_var("region", ncFloat, rdim))) return 1;

  NcError ncerror(NcError::verbose_nonfatal);
  
  int nvar = nctmpl.num_vars();
  for (int i=0; i<nvar; i++) {
    var=nctmpl.get_var(i);
    if (ncvar=ncfile.get_var(var->name())) continue;
    
    ndim=var->num_dims();
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
 
  var=ncfile.get_var("time");
  for (int i=0; i<ntime; i++) var->put_rec(ncfile.rec_dim(),time+i,i);
  //netcdf_copyvar(ncfile,ncrvar);  
  
  var=ncfile.get_var("region");
  //dim=var->get_dim(0);
  for (int i=0; i<nreg; i++)  var->put(region,nreg);  

  string s;
  vector<string>::iterator ivar;
  char data[ntime*nreg*sizeof(float)];
  float* result = (float*) data;
  for (ivar=vars.begin() ; ivar<vars.end(); ivar++)  {
    
    var=ncfile.get_var((*ivar).c_str());
    if (!var) {
      if (strcmp((*ivar).c_str(),"Technology")) s="technology";
      if (strcmp((*ivar).c_str(),"Farming")) s="farming";
      if (strcmp((*ivar).c_str(),"Agricultures")) s="economies";
      if (strcmp((*ivar).c_str(),"Resistance")) s="resistance";
      if (strcmp((*ivar).c_str(),"Density")) s="population_density";
      if (strcmp((*ivar).c_str(),"Migration")) s="migration_rate";
      if (strcmp((*ivar).c_str(),"Climate")) s="climate";
      if (strcmp((*ivar).c_str(),"CivStart")) s="time_of_high_civilization";
      if (strcmp((*ivar).c_str(),"Birthrate")) s="rate_of_birth";
      var=ncfile.get_var(s.c_str());
      if (!var) ncfile.add_var(s.c_str(),ncFloat,tdim,rdim);
    }
    ifs.read(data,sizeof(data));
    var->put(result,ntime*nreg);
  }


  ifs.close();


  
  nctmpl.close();
  ifs.close();
  ncfile.close();
 
 return 0;
#endif
}

