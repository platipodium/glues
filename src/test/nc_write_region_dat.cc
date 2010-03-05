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
   @date   2010-02-22
   @file nc_regions.cc
   @description This program creates the region, climate and mapp8ing files from regions.nc
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
  
  string ncfilename="regions.nc";
  string regfilename="regions.dat";
  string regnppname="reg_npp.dat";
  string reggddname="reg_gdd.dat";
  
  /** You may need to run the C++ program nc_regions to create the input file */
  
  NcFile ncin(ncfilename.c_str(), NcFile::ReadOnly);
  if (!ncin.is_valid()) return 1;

  NcDim *dim; 
  NcVar *var;

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
  var=ncin.get_var("latitude");
  var->get(lat,nreg);
  
  float *lon = new float[nreg];
  var=ncin.get_var("longitude");
  var->get(lon,nreg);
  
  float *area = new float[nreg];
  var=ncin.get_var("area");
  var->get(area,nreg);

  float *neigh = new float[nn*nreg];
  var=ncin.get_var("region_neighbour");
  var->get(neigh,nn,nreg);

  float *npp = new float[nreg];
  var=ncin.get_var("npp");
  var->get(npp,nreg);

  float *gdd = new float[nreg];
  var=ncin.get_var("gdd");
  var->get(gdd,nreg);

  int *cont = new int[nreg];
  var=ncin.get_var("region_continent");
  var->get(cont,nreg);

  float *carea = new float[nc];
  var=ncin.get_var("continent_area");
  var->get(carea,nc);
  
  ncin.close();

  ofstream ofs;
  ofs.open(regfilename.c_str(),ios::out);

  float lly=-89.75;
  float llx=-179.75;
  float dx=0.5;
  float dy=0.5;
  int *ilat=new int[nreg];
  int *ilon=new int[nreg];
  int *numneigh=new int[nreg];
 
 
  /** apply selection to area greater threshold */
  double threshold=40000000;
  for (int i=0; i<nreg; i++) {
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
  	numneigh[i]=0;
  	for (int j=0; j<nn; j++) {
  	  int n=neigh[j*nreg+i];
  	  if (n>0 && region[n-1]>0) numneigh[i]+=1;
    }
    /** Output format is 
      id numcells area longitude latitude numneighbours neighid:neighboundary
    */
    ofs.unsetf(ios::floatfield); 
    ofs << setprecision(5) << setw(5) << region[i] << " 1 " <<  setw(4) << lroundf(area[i]) << " " 
    	<< setw(3) << ilon[i] << " " << setw(3) << ilat[i] << " " << setw(1) << numneigh[i] ;
    
    /* allow diagonal boundary with fraction of straight boundary */
    float edge=1/20.0;
    
    if (numneigh[i]>0) {
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
    ofs << std::endl;
   }
  
  ofs.close();
 
 const int nclim=23;
 
 ofs.open(regnppname.c_str(),ios::out);
 ofs << setiosflags(ios::fixed) << setprecision(2);
 for (int j=0; j<nclim; j++) {
   for (int i=0; i<nreg; i++) if (region[i]>0) ofs << npp[i] << " ";
   ofs << endl;
 }
 ofs.close();

 ofs.open(reggddname.c_str(),ios::out);
 ofs << setiosflags(ios::fixed) << setprecision(2);
 for (int j=0; j<nclim; j++) {
   for (int i=0; i<nreg; i++) if (region[i]>0) ofs << gdd[i] << " ";
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
