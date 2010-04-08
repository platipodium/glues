/* GLUES nc_write_region_dat; this file is part of
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
   @date   2010-03-24
   @file nc_regions.cc
   @description This program creates the region, climate and mapping files from regions.nc (on gridcell) or
   from regions_11k_685.nc (alread mapped)
*/

#include "config.h"
#include <string>
#include <ctime>
//#include <cstdlib>
#include <iostream>
#include <fstream>
#include <cmath>
#include <iomanip>
//#include <cassert>

#ifdef HAVE_NETCDF_H
#include "netcdfcpp.h"
#endif

#ifndef M_PI
#define M_PI    3.14159265358979323846f
#endif

using namespace std;

float calc_geodesic(float,float,float,float);
bool is_var(NcFile*, std::string);
bool is_att(NcVar*,  std::string);
bool is_att(NcFile*, std::string);
bool is_dim(NcFile*, std::string);
bool check_var(NcFile*, std::string,int);

int main(int argc, char* argv[]) 
{

if (argc>1) {
  std::cout << "nc_write_region_dat" << std::endl << std::endl  
  << "This program creates the region, climate and mapping files from regions.nc" << endl; 
  return 0;
}

#ifndef HAVE_NETCDF_H
    std::cout << " No netcdf interface defined. FAIL" << std::endl;
    return 1;
#else
  
  string prefix="regions";
  string appendix="_11k-2_685";
  
  string ncfilename=prefix + appendix + ".nc";
  string regfilename=prefix + appendix + ".dat";
  string regnppname=prefix + "_npp" + appendix + ".dat";
  string reggddname=prefix + "_gdd" + appendix + ".dat";
  
  /** You may need to run the C++ program nc_regions to create the input file */
  
  NcFile ncin(ncfilename.c_str(), NcFile::ReadOnly);
  if (!ncin.is_valid()) return 1;

  NcDim *dim; 
  NcVar *var;

  int ntime=1;
  if (is_dim(&ncin,"time")) {
    dim=ncin.get_dim("time");
    ntime=dim->size();
  }

  dim=ncin.get_dim("region");
  int nreg=dim->size();
  dim=ncin.get_dim("neighbour");
  int nn=dim->size();
  dim=ncin.get_dim("continent");
  int nc=dim->size();
  
  float *region=new float[nreg];
  var=ncin.get_var("region");
  var->get(region,nreg);
  
  float *lat = new float[nreg];
  if (check_var(&ncin,"latitude",nreg)) var=ncin.get_var("latitude");
  else if (check_var(&ncin,"lat",nreg)) var=ncin.get_var("lat");
  else return 1;
  var->get(lat,nreg);
  
  float *lon = new float[nreg];
  if (check_var(&ncin,"longitude",nreg)) var=ncin.get_var("longitude");
  else if (check_var(&ncin,"lon",nreg)) var=ncin.get_var("lon");
  else  return 1; 
  var->get(lon,nreg);
  
  float *area = new float[nreg];
  if (!check_var(&ncin,"area",nreg)) return 1;
  var=ncin.get_var("area");
  var->get(area,nreg);

  float *neigh = new float[nn*nreg];
  if (!check_var(&ncin,"region_neighbour",nreg*nn)) return 1;
  var=ncin.get_var("region_neighbour");
  var->get(neigh,nn,nreg);

  float *npp = new float[ntime*nreg];
  if (!check_var(&ncin,"npp",ntime*nreg)) return 1;
  var=ncin.get_var("npp");
  var->get(npp,ntime,nreg);

  float *gdd = new float[ntime*nreg];
  if (!check_var(&ncin,"gdd",ntime*nreg)) return 1;
  var=ncin.get_var("gdd");
  var->get(gdd,ntime,nreg);

  int *cont = new int[nreg];
  if (!check_var(&ncin,"region_continent",nreg)) return 1;
  var=ncin.get_var("region_continent");
  var->get(cont,nreg);

  float *carea = new float[nc];
  if (!check_var(&ncin,"continent_area",nc)) return 1;
  var=ncin.get_var("continent_area");
  var->get(carea,nc);
  
  float *regnn = new float[nreg];
  bool has_neighbour_info = false;
  if (check_var(&ncin,"number_of_neighbours",nreg)) {
    ncin.get_var("number_of_neighbours")->get(regnn,nreg);
    has_neighbour_info = true;
  }
  float *regboundary = new float[nn*nreg];
  if (check_var(&ncin,"region_boundary",nn*nreg)) {
    ncin.get_var("region_boundary")->get(regboundary,nn,nreg);
    has_neighbour_info = true;
  }
  else has_neighbour_info = false;
  
  ncin.close();

  ofstream ofs;
  ofs.open(regfilename.c_str(),ios::out);

  float lly=-89.75;
  float llx=-179.75;
  float dx=0.5;
  float dy=0.5;
  int *ilat=new int[nreg];
  int *ilon=new int[nreg];

  /** apply selection to area greater threshold */
  double threshold=40000000;
  for (int i=0; i<-nreg; i++) {
    if (carea[cont[i]-1]>=threshold) continue;
    region[i]=0;
  }
 
  /** apply latlon filter */
  for (int i=0; i<-nreg; i++) {
    if (lat[i]<35 || lat[i]>37 || lon[i]<48 || lon[i]>50) region[i]=0;
  }
   
  for (int i=0; i<nreg; i++) {
  
    // x2lat = 90.0-index/2.0;
    // x2lon = index/2.0-180.;
    // Skip on threshold
    if (region[i]==0) continue;

    ilat[i]=lrintf((-lly-lat[i])/dy);
    ilon[i]=lrintf((lon[i]-llx)/dx);

    if (!has_neighbour_info) {
  	  regnn[i]=0;
  	  for (int j=0; j<nn; j++) {
  	    int n=neigh[j*nreg+i];
  	    if (n>0 && region[n-1]>0) regnn[i]+=1;
      }
    }
    /** Output format is 
      id numcells area longitude latitude numneighbours neighid:neighboundary
    */
    ofs.unsetf(ios::floatfield); 
    ofs << setprecision(5) << setw(5) << region[i] << " 1 " <<  setw(7) << lroundf(area[i]) << " " 
    	<< setw(3) << ilon[i] << " " << setw(3) << ilat[i] << " " << setw(1) << regnn[i] ;
    
    /* allow diagonal boundary with fraction of straight boundary */
    if (has_neighbour_info) {
      for (int j=0; j<regnn[i]; j++) {
        //ofs << setiosflags(ios::fixed) << setprecision(0)  
        ofs	<< " " << setw(5) <<  neigh[j*nreg+i] << ":" << regboundary[j*nreg+i];
      }
    }
    else {
      float edge=1/20.0;
      if (regnn[i]>0) {
        for (int j=0; j<nn; j++) {
          int n=neigh[j*nreg+i];
          if (region[n-1]==0) continue;
          float lon1,lon2,lat1,lat2;
          if (n>0) {
            ofs << setiosflags(ios::fixed) << setprecision(2) ; 
            if (j<1) lon1=lon[i]-dx/2.0, lon2=lon1, lat1=lat[i]-dx, lat2=lat[i]+dx;
            else if (j<4) lon1=lon[i]-dx/2.0, lon2=lon[i]+dx/2.0, lat1=lat[i]+dx, lat2=lat1;
            else if (j<5) lon1=lon[i]+dx/2.0, lon2=lon1, lat1=lat[i]-dx, lat2=lat[i]+dx;
            else lon1=lon[i]-dx/2.0, lon2=lon[i]+dx/2.0, lat1=lat[i]-dx, lat2=lat1;
          
            if ( j % 2 >0) ofs << " " << setw(5) << n << ":" << edge*calc_geodesic(lon1,lat1,lon2,lat2);
            else ofs << " " << setw(5) <<  n << ":" << calc_geodesic(lon1,lat1,lon2,lat2);
          }
        }
      }
    }
    ofs << std::endl;
   }
  
  ofs.close();
 
 const int nclim=ntime;
 
 ofs.open(regnppname.c_str(),ios::out);
 ofs << setiosflags(ios::fixed) << setprecision(2);
 for (int j=0; j<nclim; j++) {
   for (int i=0; i<nreg; i++) if (region[i]>0) ofs << npp[j*nreg+i] << " ";
   ofs << endl;
 }
 ofs.close();

 ofs.open(reggddname.c_str(),ios::out);
 ofs << setiosflags(ios::fixed) << setprecision(2);
 for (int j=0; j<nclim; j++) {
   for (int i=0; i<nreg; i++) if (region[i]>0) ofs << gdd[j*nreg+i] << " ";
   ofs <<  endl;
 }
 ofs.close();
 
 // Write dummy event files
 ofs.open("EventInReg.dat",ios::out);
 for (int i=0; i<nreg ; i++) if (region[i]>0) ofs << "-1 -1 -1 -1 -1 -1 -1 -1" << endl; 
 ofs.close();
 
 ofs.open("EventInRad.dat",ios::out);
 for (int i=0; i<nreg; i++) if (region[i]>0) ofs << "0 0 0 0 0 0 0 0" << endl; 
 ofs.close();
 
 
 return 0;
#endif
}

inline float cosd(float x) {
  return cos(x/180.*M_PI);
}

inline float sind(float x) {
  return sin(x/180.*M_PI);
}

float calc_geodesic(float lon1, float lat1, float lon2, float lat2) {

  float pi180=M_PI/180.0;
  float radius=6378.137;

  lon1*=pi180;
  lon2*=pi180;
  lat1*=pi180;
  lat2*=pi180;

  float dlon = lon2 - lon1; 
  float dlat = lat2 - lat1;
  
  float a = sin(dlat/2)*sin(dlat/2) + cos(lat1)*cos(lat2)*sin(dlon/2)*sin(dlon/2);
  float angles = 2 * atan( sqrt(a)) ; //, sqrt(1-a) );
  return radius * angles;
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

bool is_dim(NcFile* ncfile, std::string dimname) {

  int n=ncfile->num_dims();
  NcDim* dim;
 
  for (int i=0; i<n; i++) {
    dim=ncfile->get_dim(i);
    string name(dim->name());
    if (name==dimname) return true;
  }

  cerr << "NetCDF file does not contain dimension \"" << dimname << "\".\n";    
  return false;
}


bool is_att(NcFile* ncfile, std::string attname) {

  int n=ncfile->num_atts();
  NcAtt* att;
 
  for (int i=0; i<n; i++) {
    att=ncfile->get_att(i);
    string name(att->name());
    if (name==attname) return true;
  }

  cerr << "NetCDF file does not contain attribute \"" << attname << "\".\n";    
  return false;
}


bool is_att(NcVar* var, std::string attname) {

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


bool check_var(NcFile* ncfile, std::string varname,int len) {

  if (!is_var(ncfile,varname)) return false;
  
  NcVar* var=ncfile->get_var(varname.c_str());
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
