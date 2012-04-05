/* GLUES netcdf interface; this file is part of
   the Global Land Use and technological Evolution Simulator

   Copyright (C) 2010,2011,2012
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
   @date   2012-04-03
   @file   GNetcdf.cc
*/

#include "GNetcdf.h"
#include <iostream>
#include <ctime>

#ifdef HAVE_NETCDF_H


int gnc_write_header(NcFile& ncfile) {

  if (!ncfile.is_valid()) {
    std::cerr << "Could not open NetCDF file for writing " << std::endl;
    return 1;
  }

  time_t today;
  std::time(&today);
  std::string s1(asctime(gmtime(&today)));
  std::string timestring=s1.substr(0,s1.find_first_of("\n"));
  
  ncfile.add_att("Conventions","CF-1.4");
  ncfile.add_att("title","GLUES");
  ncfile.add_att("history","File created");
  ncfile.add_att("address","Max-Planck-Str 1, 21502 Geesthacht, Germany");
  ncfile.add_att("principal_investigator","Carsten Lemmen");
  ncfile.add_att("email","carsten.lemmen@hzg.de");
  ncfile.add_att("institution","Helmholtz-Zentrum Geesthacht GmbH");
  ncfile.add_att("funding_source","Helmholtz Gemeinschaft");
  ncfile.add_att("funding_scheme","Institutional");
  //ncfile.add_att("funding_scheme_name","Interdynamik");
  ncfile.add_att("funding_project","PACES");
  ncfile.add_att("source","model");
  ncfile.add_att("references","Wirtz & Lemmen (2003), Lemmen (2009), Lemmen et al. (2011)");
  ncfile.add_att("model_name","GLUES");
  ncfile.add_att("model_version",VERSION);
  ncfile.add_att("date_of_creation",timestring.c_str());

  return 0;
}


int gnc_write_definitions(NcFile& ncfile, int nreg, int nneigh, int ncont) {

  if (!ncfile.is_valid()) {
    std::cerr << "Could not open NetCDF file for writing " << std::endl;
    return 1;
  }

  time_t today;
  std::time(&today);
  std::string s1(asctime(gmtime(&today)));
  std::string timestring=s1.substr(0,s1.find_first_of("\n"));

  
  NcDim *regdim, *timedim, *neighdim, *contdim;
  if (!(regdim   = ncfile.add_dim("region", nreg))) return 1;
  if (!(neighdim = ncfile.add_dim("neighbour", nneigh))) return 1;
  if (!(contdim = ncfile.add_dim("continent", ncont))) return 1;
  if (!(timedim  = ncfile.add_dim("time"))) return 1;
  
  
/** Create coordinate variables */  
  
  NcVar *var;

  if (!(var   = ncfile.add_var("time", ncFloat, timedim))) return 1;
  var->add_att("units","years since 01-01-01");
  var->add_att("calendar","360_day");
  var->add_att("coordinates","time");
  var->add_att("comment","No adjustement has been made for the shift of the calendar away from present day");
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
    
  var = ncfile.add_var("area",ncFloat, regdim);
  var->add_att("units","km^{2}");
  var->add_att("long_name","area");
  var->add_att("description","Area of region");
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
  var->add_att("long_name","economy_diversity_initialization");
  var->add_att("units","1");
  var->add_att("valid_min",0.0);
  var->add_att("description","Initial value for number of diverse economic strategies");
  var->add_att("coordinates","lon lat");
  var->add_att("date_of_creation",timestring.c_str());

  var = ncfile.add_var("population_density_init",ncFloat, regdim);
  var->add_att("units","km-2");
  var->add_att("valid_min",0.0);
  var->add_att("long_name","population_density_initialization");
  var->add_att("description","Initial value for density of population");
  var->add_att("coordinates","time lon lat");  
  var->add_att("date_of_creation",timestring.c_str());

/** Neighbour variables */
   if (!(var = ncfile.add_var("region_neighbour", ncInt, ncfile.get_dim("neighbour"), ncfile.get_dim("region")))) return 1;
  var->add_att("date_of_creation",timestring.c_str());
  var->add_att("long_name","region neighbour");
  var->add_att("standard_name","region_neighbour");
  var->add_att("description","Region id of neighbours");
  var->add_att("coordinates","lat lon neighbour");

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

  var = ncfile.add_var("economies_potential",ncFloat,timedim,regdim);
  var->add_att("long_name","potential_for_economies");
  var->add_att("units","1");
  var->add_att("valid_min",0.0);
  var->add_att("description","Maximum potential of diverse economic strategies");
  var->add_att("coordinates","time lon lat");
  var->add_att("date_of_creation",timestring.c_str());
  
  var = ncfile.add_var("npp",ncFloat, timedim, regdim);
  var->add_att("units","kg m-2 a-1");
  var->add_att("valid_min",0.0);
  var->add_att("long_name","net_primary_production");
  var->add_att("description","Net primary production");
  var->add_att("coordinates","time lon lat");  
  var->add_att("date_of_creation",timestring.c_str());

  var = ncfile.add_var("population_size",ncFloat, timedim, regdim);
  var->add_att("units","1");
  var->add_att("valid_min",0.0);
  var->add_att("long_name","population_size");
  var->add_att("description","Size of population (individuals)");
  var->add_att("coordinates","time lon lat");  
  var->add_att("date_of_creation",timestring.c_str());
 
  var = ncfile.add_var("population_density",ncFloat, timedim, regdim);
  var->add_att("units","km-2");
  var->add_att("valid_min",0.0);
  var->add_att("long_name","population_density");
  var->add_att("description","Density of population");
  var->add_att("coordinates","time lon lat");  
  var->add_att("date_of_creation",timestring.c_str());

  var = ncfile.add_var("relative_growth_rate",ncFloat, timedim, regdim);
  var->add_att("units","a-1");
  var->add_att("long_name","relative_growth_rate");
  var->add_att("description","Relative change of population density");
  var->add_att("coordinates","time lon lat");  
  var->add_att("date_of_creation",timestring.c_str());

  var = ncfile.add_var("temperature_limitation",ncFloat, timedim, regdim);
  var->add_att("units","1");
  var->add_att("long_name","temperature_limitation");
  var->add_att("description","Limitation of habitability by temperature");
  var->add_att("coordinates","time lon lat");  
  var->add_att("date_of_creation",timestring.c_str());

  var = ncfile.add_var("actual_fertility",ncFloat, timedim, regdim);
  var->add_att("units","unknown");
  var->add_att("long_name","actual_fertility");
  var->add_att("description","Fertility resulting from natural and anthropogenic effects");
  var->add_att("coordinates","time lon lat");  
  var->add_att("date_of_creation",timestring.c_str());

  var = ncfile.add_var("natural_fertility",ncFloat, timedim, regdim);
  var->add_att("units","unknown");
  var->add_att("long_name","natural_fertility");
  var->add_att("description","Fertility based on background climate");
  var->add_att("coordinates","time lon lat");  
  var->add_att("date_of_creation",timestring.c_str());
 
  var = ncfile.add_var("migration_density",ncFloat, timedim, regdim);
  var->add_att("units","km^{-2} a^{-1}");
  var->add_att("long_name","migration_density");
  var->add_att("description","Density of migrated population");
  var->add_att("coordinates","time lon lat");  
  var->add_att("date_of_creation",timestring.c_str());

  var = ncfile.add_var("subsistence_intensity",ncFloat, timedim, regdim);
  var->add_att("units",1);
  var->add_att("long_name","subsistence_intensity");
  var->add_att("description","Intensity of per capita land use");
  var->add_att("coordinates","time lon lat");  
  var->add_att("date_of_creation",timestring.c_str());

  var = ncfile.add_var("region_is_in_sahara",ncShort,regdim);
  var->add_att("units","");
  var->add_att("long_name","region_is_in_sahara");
  var->add_att("description","Indicates whether region is located in Sahara");
  var->add_att("coordinates","time lon lat");  
  var->add_att("date_of_creation",timestring.c_str());

  var = ncfile.add_var("region_continent",ncShort,regdim);
  var->add_att("units","");
  var->add_att("long_name","region_continent");
  var->add_att("description","Continent id where the region is located in");
  var->add_att("coordinates","lon lat");  
  var->add_att("date_of_creation",timestring.c_str());

//   var = ncfile.add_var("technology_spread_by_people",ncFloat, timedim, regdim);
//   var->add_att("units","a^{-1}");
//   var->add_att("long_name","technology_spread_by_people");
//   var->add_att("description","Net exchange of technology by migrants");
//   var->add_att("coordinates","time lon lat");  
//   var->add_att("date_of_creation",timestring.c_str());
// 
//   var = ncfile.add_var("technology_spread_by_information",ncFloat, timedim, regdim);
//   var->add_att("units","a^{-1}");
//   var->add_att("long_name","technology_spread_by_information");
//   var->add_att("description","Net exchange of technology by information");
//   var->add_att("coordinates","time lon lat");  
//   var->add_att("date_of_creation",timestring.c_str());
// 
//   var = ncfile.add_var("technology_spread",ncFloat, timedim, regdim);
//   var->add_att("units","a^{-1}");
//   var->add_att("long_name","technology_spread");
//   var->add_att("description","Net exchange of technology");
//   var->add_att("coordinates","time lon lat");  
//   var->add_att("date_of_creation",timestring.c_str());
// 
//   var = ncfile.add_var("economies_spread_by_people",ncFloat, timedim, regdim);
//   var->add_att("units","a^{-1}");
//   var->add_att("long_name","economies_spread_by_people");
//   var->add_att("description","Net exchange of economies by migrants");
//   var->add_att("coordinates","time lon lat");  
//   var->add_att("date_of_creation",timestring.c_str());
// 
//   var = ncfile.add_var("economies_spread_by_information",ncFloat, timedim, regdim);
//   var->add_att("units","a^{-1}");
//   var->add_att("long_name","economies_spread_by_information");
//   var->add_att("description","Net exchange of economies by information");
//   var->add_att("coordinates","time lon lat");  
//   var->add_att("date_of_creation",timestring.c_str());
// 
   var = ncfile.add_var("farming_spread_by_people",ncFloat, timedim, regdim);
   var->add_att("units","a^{-1}");
   var->add_att("long_name","farming_spread_by_people");
   var->add_att("description","Net exchange of farming by migrants");
   var->add_att("coordinates","time lon lat");  
   var->add_att("date_of_creation",timestring.c_str());

  var = ncfile.add_var("suitable_species",ncFloat, timedim, regdim);
  var->add_att("units","1");
  var->add_att("long_name","relative_number_of_suitable_species");
  var->add_att("description","Relative number of suitable species for agropastoralism");
  var->add_att("coordinates","time lon lat");  
  var->add_att("date_of_creation",timestring.c_str());

  var = ncfile.add_var("suitable_temperature",ncFloat, timedim, regdim);
  var->add_att("units","1");
  var->add_att("long_name","relative_suitability_of temperature_for_diversity");
  var->add_att("description","Temperature dependence of suitable species for agropastoralism");
  var->add_att("coordinates","time lon lat");  
  var->add_att("date_of_creation",timestring.c_str());

  /**
  Farming does not spread by information 
  var = ncfile.add_var("farming_spread_by_information",ncFloat, timedim, regdim);
  var->add_att("units","a^{-1}");
  var->add_att("long_name","farming_spread_by_information");
  var->add_att("description","Net exchange of farming by information");
  var->add_att("coordinates","time lon lat");  
  var->add_att("date_of_creation",timestring.c_str());
  */

  return 0;
}


/** Adds a record's worth of data to the netcdf file
  @param ncfile  Reference to netcdf file
  @param varname Variable name as C++ string
  @param data    Pointer to data
  @param irecord index of record to put the data in
*/
int gnc_write_record(NcFile& ncfile, const std::string& varname, int** data, const int irecord) {

  if (!ncfile.is_valid()) {
    std::cerr << "Could not open NetCDF file for appending." << std::endl;
    return 1;
  }
  
  if (!gnc_is_var(ncfile,varname)) return 1;
  
  NcVar* var;
  NcDim* dim;
  var=ncfile.get_var(varname.c_str());
  int ndim=var->num_dims();
  int *ndims = new int[ndim];
  int udimid = -1;
  for (int i=0; i<ndim; i++) {
    dim=var->get_dim(i);
    if (dim->is_unlimited()) udimid=i;
    ndims[i]=dim->size();
  }
  int *rdims = new int[ndim];
  for (int i=0,j=0; i<ndim; i++) {
    if (udimid == i) continue;
    rdims[j]=ndims[i];
  }
  if (udimid>-1) ndim=ndim-1;
 
  if (irecord>=0) {
// TODO: for more dimensions OR NOT??
      var->put_rec(*data,irecord); 
  }
  else switch(ndim) {
    case (1): var->put(*data,ndims[0]); break;
    case (2): var->put(*data,ndims[0],ndims[1]); break;
    case (3): var->put(*data,ndims[0],ndims[1],ndims[2]); break;
    case (4): var->put(*data,ndims[0],ndims[1],ndims[2],ndims[3]); break;
  }
 
 /* time_t today;
  std::time(&today);
  std::string s1(asctime(gmtime(&today)));
  std::string timestring=s1.substr(0,s1.find_first_of("\n"));

  var->add_att("date_of_modification",timestring.c_str());
*/
  return 0;
}


/** Adds a record's worth of data to the netcdf file
  @param ncfile  Reference to netcdf file
  @param varname Variable name as C++ string
  @param data    Pointer to data
  @param irecord index of record to put the data in
*/
int gnc_write_record(NcFile& ncfile, const std::string& varname, float** data, const int irecord) {

  if (!ncfile.is_valid()) {
    std::cerr << "Could not open NetCDF file for appending." << std::endl;
    return 1;
  }
  
  if (!gnc_is_var(ncfile,varname)) return 1;
  
  NcVar* var;
  NcDim* dim;
  var=ncfile.get_var(varname.c_str());
  int ndim=var->num_dims();
  int *ndims = new int[ndim];
  int udimid = -1;
  for (int i=0; i<ndim; i++) {
    dim=var->get_dim(i);
    if (dim->is_unlimited()) udimid=i;
    ndims[i]=dim->size();
  }
  int *rdims = new int[ndim];
  for (int i=0,j=0; i<ndim; i++) {
    if (udimid == i) continue;
    rdims[j]=ndims[i];
  }
  if (udimid>-1) ndim=ndim-1;
 
  if (irecord>=0) {
// TODO: for more dimensions OR NOT??
      var->put_rec(*data,irecord); 
  }
  else switch(ndim) {
    case (1): var->put(*data,ndims[0]); break;
    case (2): var->put(*data,ndims[0],ndims[1]); break;
    case (3): var->put(*data,ndims[0],ndims[1],ndims[2]); break;
    case (4): var->put(*data,ndims[0],ndims[1],ndims[2],ndims[3]); break;
  }
 
 /* time_t today;
  time(&today);
  std::string s1(asctime(gmtime(&today)));
  std::string timestring=s1.substr(0,s1.find_first_of("\n"));

  var->add_att("date_of_modification",timestring.c_str());
*/
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
    std::string name(var->name());
    if (name==varname) return true;
  }

  std::cerr << "NetCDF file does not contain variable \"" << varname << "\".\n";    
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
    std::string name(dim->name());
    if (name==dimname) return true;
  }

  std::cerr << "NetCDF file does not contain dimension \"" << dimname << "\".\n";    
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
    std::string name(att->name());
    if (name==attname) return true;
  }

  std::cerr << "NetCDF file does not contain attribute \"" << attname << "\".\n";    
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
    std::string name(att->name());
    if (name==attname) return true;
  }

  std::cerr << "Variable \"" << var->name() << "\" does not contain attribute \"" << attname << "\".\n";    
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

  std::cerr << "None of the dimensions of variable \"" << varname << "\" is of requested length " << len << ".\n";    
  return false;
}



/** Read a record's worth of data from the netcdf file
  @param ncfile  Reference to netcdf file
  @param varname Variable name as C++ string
  @param data    Pointer to data
  @param irecord index of record to put the data in
*/
int gnc_read_record(NcFile& ncfile, const std::string& varname, float** data, const long irecord) {

  if (!ncfile.is_valid()) {
    std::cerr << "Could not open NetCDF file for reading." << std::endl;
    return 1;
  }
  
  if (!gnc_is_var(ncfile,varname)) return 1;
  
  NcVar* var;
  NcDim* dim;
  var=ncfile.get_var(varname.c_str());
  int ndim=var->num_dims();
  int *ndims = new int[ndim];
  int udimid = -1;
  for (int i=0; i<ndim; i++) {
    dim=var->get_dim(i);
    if (dim->is_unlimited()) udimid=i;
    ndims[i]=dim->size();
  }
 
  if ((udimid>-1) && (irecord>ndims[udimid])) {
    std::cerr << "Record beyond length of time variable requested." << std::endl;
    return 1;
  }
 
  long *cur   = new long[ndim];
  long *edges = new long[ndim];
  for (int i=0; i<ndim; i++) {
    if (udimid == i) {
      if (irecord>-1) cur[i]=irecord;
      else cur[i]=ndims[i]-1;
      edges[i]=1;
    }
    else {
      cur[i]=0;
      edges[i]=ndims[i];
    }
    //std::cerr << i << " " << ndims[i] << " " << cur[i] << std::endl;
  }

  var->set_cur(cur);
  switch(ndim) {
    case (1): var->get(*data,edges[0]); break;
    case (2): var->get(*data,edges[0],edges[1]); break;
  }
 
  return 0;
}


int gnc_read_record(NcFile& ncfile, const std::string& varname, int** data, const long irecord) {

  if (!ncfile.is_valid()) {
    std::cerr << "Could not open NetCDF file for reading." << std::endl;
    return 1;
  }
  
  if (!gnc_is_var(ncfile,varname)) return 1;
  
  NcVar* var;
  NcDim* dim;
  var=ncfile.get_var(varname.c_str());
  int ndim=var->num_dims();
  int *ndims = new int[ndim];
  int udimid = -1;
  for (int i=0; i<ndim; i++) {
    dim=var->get_dim(i);
    if (dim->is_unlimited()) udimid=i;
    ndims[i]=dim->size();
  }
 
  if ((udimid>-1) && (irecord>ndims[udimid])) {
    std::cerr << "Record beyond length of time variable requested." << std::endl;
    return 1;
  }
 
  long *cur   = new long[ndim];
  long *edges = new long[ndim];
  for (int i=0; i<ndim; i++) {
    if (udimid == i) {
      if (irecord>-1) cur[i]=irecord;
      else cur[i]=ndims[i]-1;
      edges[i]=1;
    }
    else {
      cur[i]=0;
      edges[i]=ndims[i];
    }
    //std::cerr << i << " " << ndims[i] << " " << cur[i] << std::endl;
  }

  var->set_cur(cur);
  switch(ndim) {
    case (1): var->get(*data,edges[0]); break;
    case (2): var->get(*data,edges[0],edges[1]); break;
  }
 
  return 0;
}














#endif
