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
   @date   2010-03-29
   @file   GNetcdf.cc
*/

#include "GNetcdf.h"
#include <iostream>
#include <ctime>

using namespace std;

#ifdef HAVE_NETCDF_H

int gnc_write_header(NcFile& ncfile, int nreg) {
  if (!ncfile.is_valid()) {
    cerr << "Could not open NetCDF file for writing " << endl;
    return 1;
  }
  
  time_t today;
  std::time(&today);
  string s1(asctime(gmtime(&today)));
  string timestring=s1.substr(0,s1.find_first_of("\n"));
  
  ncfile.add_att("Conventions","CF-1.4");
  ncfile.add_att("title","GLUES");
  ncfile.add_att("history","File created");
  ncfile.add_att("address","Max-Planck-Str 1, 21502 Geesthacht, Germany");
  ncfile.add_att("principal_investigator","Carsten Lemmen");
  ncfile.add_att("email","carsten.lemmen@gkss.de");
  ncfile.add_att("institution","GKSS-Forschungszentrum Geesthacht GmbH");
  ncfile.add_att("source","GLUES 1.1.9 model");
  ncfile.add_att("comment","");
  ncfile.add_att("references","Wirtz & Lemmen (2003), Lemmen (2009)");
  ncfile.add_att("model_name","GLUES");
  ncfile.add_att("date_of_creation",timestring.c_str());
   
  NcDim *regdim, *timedim;
  if (!(regdim  = ncfile.add_dim("region", nreg))) return 1;
  if (!(timedim = ncfile.add_dim("time"))) return 1;
  
/** Create coordinate variables */  
  
  NcVar *var;

  if (!(var   = ncfile.add_var("time", ncFloat, timedim))) return 1;
  var->add_att("units","years since 01-01-01");
  var->add_att("calendar","360_day");
  var->add_att("coordinates","time");
  var->add_att("date_of_creation",timestring.c_str());

  if (!(var = ncfile.add_var("region", ncInt, regdim))) return 1;
  var->add_att("units", "");
  var->add_att("long_name","region_index");
  var->add_att("standard_name","region_index");
  var->add_att("description","Unique integer index of land region");
  var->add_att("valid_min",1);
  var->add_att("coordinates","lon lat");
  var->add_att("date_of_creation",timestring.c_str());

/** Create static variables */

  var = ncfile.add_var("latitude",ncFloat, regdim);
  var->add_att("units","degrees_north");
  var->add_att("long_name","center_latitude");
  var->add_att("cell_method","geographical mean of region latitudinal extent");
  var->add_att("description","Latitude of region center");
  var->add_att("coordinates","lon lat");
  var->add_att("date_of_creation",timestring.c_str());
  
  var = ncfile.add_var("longitude",ncFloat, regdim);
  var->add_att("units","degrees_east");
  var->add_att("cell_method","geographical mean of region longitudinal extent");
  var->add_att("long_name","center_longitude");
  var->add_att("description","Longitude of region center");
  var->add_att("coordinates","lon lat");
  var->add_att("date_of_creation",timestring.c_str());
    
  var = ncfile.add_var("technology_init",ncFloat,regdim);
  var->add_att("long_name","technology_index_initialization");
  var->add_att("units","1");
  var->add_att("valid_min",0.0);
  var->add_att("description","Initial value for technology index");
  var->add_att("coordinates","lon lat");
  var->add_att("date_of_creation",timestring.c_str());

  var = ncfile.add_var("farming_init",ncFloat,regdim);
  var->add_att("long_name","farming_ratio_initialization");
  var->add_att("units","1");
  var->add_att("valid_min",0.0);
  var->add_att("valid_max",1.0);
  var->add_att("description","Initial value for fraction of agriculturalist and pastoralists");
  var->add_att("coordinates","lon lat");
  var->add_att("date_of_creation",timestring.c_str());
 
  var = ncfile.add_var("economies_init",ncFloat,regdim);
  var->add_att("long_name","economy_diversity");
  var->add_att("units","1");
  var->add_att("valid_min",0.0);
  var->add_att("description","Initial value for number of diverse economic strategies");
  var->add_att("coordinates","lon lat");
  var->add_att("date_of_creation",timestring.c_str());

/** Time-dependent variables */
  var = ncfile.add_var("technology",ncFloat,timedim,regdim);
  var->add_att("long_name","technology_index");
  var->add_att("units","1");
  var->add_att("valid_min",0.0);
  var->add_att("description","Relative technology index with respect to mesolithic hunters");
  var->add_att("coordinates","time lon lat");
  var->add_att("date_of_creation",timestring.c_str());

  var = ncfile.add_var("farming",ncFloat,timedim,regdim);
  var->add_att("long_name","farming_ratio");
  var->add_att("units","1");
  var->add_att("valid_min",0.0);
  var->add_att("valid_max",1.0);
  var->add_att("description","Fraction of agriculturalist and pastoralist activities in population");
  var->add_att("coordinates","time lon lat");
  var->add_att("date_of_creation",timestring.c_str());
 
  var = ncfile.add_var("economies",ncFloat,timedim,regdim);
  var->add_att("long_name","economy_diversity");
  var->add_att("units","1");
  var->add_att("valid_min",0.0);
  var->add_att("description","Number of diverse economic strategies");
  var->add_att("coordinates","time lon lat");
  var->add_att("date_of_creation",timestring.c_str());

  var = ncfile.add_var("population_density",ncFloat,timedim,regdim);
  var->add_att("units","km^-2");
  var->add_att("long_name","population_density");
  var->add_att("description","Population density");
  var->add_att("valid_min",0.0);
  var->add_att("coordinates","time lon lat");
  var->add_att("date_of_creation",timestring.c_str());

  var = ncfile.add_var("gdd",ncFloat, timedim,regdim);
  var->add_att("units","d");
  var->add_att("long_name","growing degree days above zero");
  var->add_att("valid_min",0.0);
  var->add_att("valid_max",366.0);
  var->add_att("reference_value",0);
  var->add_att("description","");
  var->add_att("coordinates","time lon lat");
  var->add_att("date_of_creation",timestring.c_str());
  
  var = ncfile.add_var("npp",ncFloat, timedim, regdim);
  var->add_att("units","kg m-2 a-1");
  var->add_att("valid_min",0.0);
  var->add_att("long_name","net_primary_production");
  var->add_att("description","Net primary production");
  var->add_att("coordinates","time lon lat");  
  var->add_att("date_of_creation",timestring.c_str());
         
  return 0;
}


/** Adds a record's worth of data to the netcdf file
  @param ncfile  Reference to netcdf file
  @param varname Variable name as C++ string
  @param data    Pointer to data
  @param irecord index of record to put the data in
*/
int gnc_write_record(NcFile& ncfile, const std::string& varname, const int** data, const int irecord) {

  if (!ncfile.is_valid()) {
    cerr << "Could not open NetCDF file for appending." << endl;
    return 1;
  }
  

  if (!gnc_is_var(ncfile,varname)) return 1;
  
  NcVar* var;
  var=ncfile.get_var(varname.c_str());
  var->put_rec(*data,irecord);

  time_t today;
  std::time(&today);
  string s1(asctime(gmtime(&today)));
  string timestring=s1.substr(0,s1.find_first_of("\n"));

  var->add_att("date_of_modification",timestring.c_str());

  return 0;
}


/** Checks whether a variable with name varname exists
  @param ncfile  Reference to netcdf file
  @param varname Variable name as C++ string
*/
bool gnc_is_var(const NcFile& ncfile, const std::string& varname) {

  int n=ncfile.num_vars();
  NcVar* var;
 
  for (int i=0; i<n; i++) {
    var=ncfile.get_var(i);
    string name(var->name());
    if (name==varname) return true;
  }

  cerr << "NetCDF file does not contain variable \"" << varname << "\".\n";    
  return false;
}

/** Checks whether a dimension with name dimname exists
  @param ncfile  Reference to netcdf file
  @param dimname Dimension name as C++ string
*/
bool gnc_is_dim(const NcFile& ncfile, const std::string& dimname) {

  int n=ncfile.num_dims();
  NcDim* dim;
 
  for (int i=0; i<n; i++) {
    dim=ncfile.get_dim(i);
    string name(dim->name());
    if (name==dimname) return true;
  }

  cerr << "NetCDF file does not contain dimension \"" << dimname << "\".\n";    
  return false;
}

/** Checks whether an attribute with name attname exists
  @param ncfile  Reference to netcdf file
  @param attname Attribute name as C++ string
*/
bool gnc_is_att(const NcFile& ncfile, const std::string& attname) {

  int n=ncfile.num_atts();
  NcAtt* att;
 
  for (int i=0; i<n; i++) {
    att=ncfile.get_att(i);
    string name(att->name());
    if (name==attname) return true;
  }

  cerr << "NetCDF file does not contain attribute \"" << attname << "\".\n";    
  return false;
}

/** Checks whether an attribute with name attname exists in variable
  @param var  Pointer to netcdf variable
  @param attname Attribute name as C++ string
*/
bool gnc_is_att(const NcVar*  var, const std::string& attname) {

  int n=var->num_atts();
  NcAtt* att;
 
  for (int i=0; i<n; i++) {
    att=var->get_att(i);
    string name(att->name());
    if (name==attname) return true;
  }

  cerr << "Variable \"" << var->name() << "\" does not contain attribute \"" << attname << "\".\n";    
  return false;
}

/** Checks whether a varialbe with lenght of one or all coordinates exists
  @param ncfile  Reference to netCDF file
  @param varname Variable name as C++ string
  @param len Length of one or all dimensions
*/
bool gnc_check_var(const NcFile& ncfile, const std::string & varname, const int len) {

  if (!gnc_is_var(ncfile,varname)) return false;
  
  NcVar* var=ncfile.get_var(varname.c_str());
  NcDim* dim;
  
  int n=var->num_dims();
  int s=1;
  for (int i=0; i<n; i++) {
    dim=var->get_dim(i);
    if (dim->size()==len) return true;
    s*=dim->size();
  }
  if (s==len) return true;

  cerr << "None of the dimensions of variable \"" << varname << "\" is of requested length " << len << ".\n";    
  return false;
}

#endif
