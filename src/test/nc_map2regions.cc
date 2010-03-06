/* GLUES nc_map2regions; this file is part of
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
   @date   2010-03-06
   @file nc_map2regions.cc
   @description This program reads a map (created by nc_regionmap) and a climate region file
   (created by nc_climateregions), and scales all info on the climateregions to the new map
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

float sind(float);
float cosd(float);
float calc_gridcell_area(float clat,float dlon=0.5,float dlat=0.5,float radius=6378.137);
float npp_lieth(float,float);
double search_continent(short int**,int**,int, short int,int,int);

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
  string cellfilename="regions_11k.nc";
  string filename="regions_11k_685.nc";

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

/** Read the cell file, this file need to include the variables longitude, latitude,
npp and gdd */

  NcFile ncc(cellfilename.c_str(), NcFile::ReadOnly);
  if (!ncc.is_valid()) { 
    std::cerr << "Regions file " << cellfilename << " not found." << std::endl
    << "Please run nc_climateregions to create this file." << std::endl;
    return 1;
  }

  NcVar* var, *varid;
  int natt;
  NcDim *dim;
  int ndim;

  dim=ncc.get_dim("time");
  long nyear=dim->size();
  dim=ncc.get_dim("region");
  long nland=dim->size();
  dim=ncc.get_dim("neighbour");
  long nn=dim->size();
  dim=ncc.get_dim("continent");
  long ncont=dim->size();
 
  float *year=new float[nyear];
  ncc.get_var("time")->get(year,nyear);
  float *latit  = new float[nland];
  ncc.get_var("lat")->get(latit,nland);
  float *longit = new float[nland];
  ncc.get_var("lon")->get(longit,nland);
  float *area = new float[nland];
  ncc.get_var("area")->get(area,nland);
  int* region = new int[nland];
  ncc.get_var("region")->get(region,nland);
  short *npp = new short[nland*nyear];
  ncc.get_var("npp")->get(npp,nyear,nland);
  short *gdd = new short[nland*nyear];
  ncc.get_var("gdd")->get(gdd,nyear,nland);

  assert(gdd != NULL);
  assert(npp != NULL);
    
  int * ilat=new int[nland];
  int * ilon=new int[nland];
  int * regionid=new int[nland];
  int minreg=nrow*ncol;
  int maxreg=0;
  for (int i=0; i<nrow*ncol; i++) {
    if (minreg>=id[i] && id[i]>=0) minreg=id[i];
    if (maxreg<=id[i] && id[i]>=0) maxreg=id[i];
  }
  
  int nreg=maxreg-minreg+1;
  int* reg=new int[nreg];
  int* regn=new int[nreg];
  float* reglon=new float[nreg];
  float* reglat=new float[nreg];
  float* regarea=new float[nreg];
  float* reggdd=new float[nreg];
  float* regnpp=new float[nreg];
  float dx=0.5;
  float dy=0.5;
  
  for (int i=0; i<nreg; i++) {
    reg[i]=i+1;
    regn[i]=0;
    reglat[i]=0;
    reglon[i]=0;
    reggdd[i]=0;
    regnpp[i]=0;
  }

  NcFile ncfile(filename.c_str(), NcFile::Replace);
  if (!ncfile.is_valid()) return 1;

  for (int i=0; i<nland; i++) {
    ilat[i]=(lat[0]-latit[i])/dy;
    ilon[i]=(longit[i]-lon[0])/dx;
    regionid[i]=id[ilon[i]*nrow+ilat[i]];
    if (regionid[i]<0) continue; // exclude sea regions
    reglon[regionid[i]]+=longit[i];
    reglat[regionid[i]]+=latit[i];
    regarea[regionid[i]]+=area[i];
    regn[regionid[i]]++;
    for (int j=0; j<nyear; j++) {
      reggdd[j*nreg+regionid[i]]+=gdd[0*nland+i];
      //regnpp[j*nreg+regionid[i]]+=1.0*npp[i*nyear+j];
      regnpp[j*nreg+regionid[i]]+=npp[0*nland+i];
    }
    cout << regionid[i] << " " << i << " " <<  regn[regionid[i]] << " " << npp[i] << " " << regnpp[regionid[i]]/regn[regionid[i]] << endl;
  }  

  delete [] npp, gdd, area, latit, longit, ilat, ilon;

  for (int i=0; i<nreg; i++) {
    for (int j=0; j<nyear; j++) {
      regnpp[j*nreg+i]/=1.0*regn[i];
      reggdd[j*nreg+i]/=1.0*regn[i];
    }
    reglon[i]/=regn[i];
    reglat[i]/=regn[i];
    cout << i << " " << regn[i] << " " << reggdd[i] << " " << regnpp[i] << endl;
  }
  
 
//  NcFile ncfile(filename.c_str(), NcFile::Replace);
  if (!ncfile.is_valid()) return 1;
  
  time_t today;
  std::time(&today);
  string s1(asctime(gmtime(&today)));
  string monthstring=s1.substr(0,s1.find_first_of("\n"));
  
  /** Copy global attributes */
  NcAtt* att;
  for (int i=0; i<ncc.num_atts(); i++) {
    att=ncc.get_att(i);
    //copy_att(&ncfile,att);
  }
  ncfile.add_att("date_of_creation",monthstring.c_str());
  ncfile.add_att("filenames_output",filename.c_str());
  //att=ncfile.get_att("history");
  //append_att(att,"nc_map2regions");
 
  /** Recreate dimensions */
  for (int i=0; i<ncc.num_dims(); i++) {
     dim=ncc.get_dim(i);
     if (dim->is_unlimited()) ncfile.add_dim(dim->name(), 0);
     else if (!strncmp(dim->name(),"region",6)) ncfile.add_dim(dim->name(), nreg);
     else ncfile.add_dim(dim->name(), dim->size());
  }

  for (int i=0; i<ncc.num_vars(); i++) {
    var=ncc.get_var(i);
    ndim=var->num_dims();
    switch (ndim) {
     case 1: ncfile.add_var(var->name(), var->type(), var->get_dim(0)); break;
     case 2: ncfile.add_var(var->name(), var->type(), var->get_dim(0), var->get_dim(1)); break;
     case 3: ncfile.add_var(var->name(), var->type(), var->get_dim(0), var->get_dim(1), var->get_dim(2)); break;
     case 4: ncfile.add_var(var->name(), var->type(), var->get_dim(0), var->get_dim(1), var->get_dim(2), var->get_dim(3)); break;
     case 5: ncfile.add_var(var->name(), var->type(), var->get_dim(0), var->get_dim(1), var->get_dim(2), var->get_dim(3), var->get_dim(4)); break;
    }
    varid=ncfile.get_var(i);
    //for (int j=0; j<var->num_atts(); j++) copy_att(varid,var->get_att(j));
    varid->add_att("date_of_creation",monthstring.c_str());
  }

  if (!(var = ncfile.add_var("number_of_gridcells", ncInt, ncfile.get_dim("region")))) return 1;
  var->add_att("date_of_creation",monthstring.c_str());
  var->add_att("long_name","number_of_gridcells");
  var->add_att("description","number of half degree grid cells associated with this region");
  
  /** Fill values */
  ncfile.get_var("time")->put(year,nyear);
  ncfile.get_var("number_of_gridcells")->put(regn,nreg);
  ncfile.get_var("region")->put(reg,nreg);
  ncfile.get_var("lon")->put(reglon,nreg);
  ncfile.get_var("lat")->put(reglat,nreg);
  ncfile.get_var("area")->put(regarea,nreg);
  short* sh=new short[nyear*nreg];
  for (int i=0; i<nyear*nreg; i++) sh[i]=lrintf(regnpp[i]);
  //for (int i=0; i<nreg; i++)  cout << i << " " << regnpp[i] << " " << sh[i] << endl;
  ncfile.get_var("npp")->put(sh,nyear,nreg);
  for (int i=0; i<nyear*nreg; i++) sh[i]=lrintf(reggdd[i]);
  ncfile.get_var("gdd")->put(sh,nyear,nreg);  
  
  
  
  
 
  ncc.close();
  ncfile.close();
 cout << "end: " ; 
  return 0;

  
  float lly=-89.75;
  float llx=-179.75;

  int* map=new int[(nrow+2)*(ncol+2)];
  for (int i=0; i<(nrow+2)*(ncol+2); i++) map[i]=0;
  
  //int maxlat=10000;
  for (int i=0; i<nland; i++) {
    ilat[i]=lrintf((latit[i]-lly)/dy)+1;
    ilon[i]=lrintf((longit[i]-llx)/dx)+1;
    map[(ncol+2)*ilat[i]+ilon[i]]=region[i];
    //maxlat=min(ilat[i],maxlat);
    //cout << maxlat << endl;
  }
  for (int i=0; i<nrow; i++) {
    map[i*(ncol+2)+0]=map[i*(ncol+2)+ncol];
    map[i*(ncol+2)+ncol+1]=map[i*(ncol+2)+1];
  }
  for (int i=0; i<ncol; i++) {
    map[0*(ncol+2)+i]=map[1*(ncol+2)+i];
    map[(nrow+1)*(ncol+2)+i]=map[(ncol+2)*nrow+i];
  }

  int* neigh=new int[nland*nn];
  int ireg;
  for (int i=0; i<nland; i++) {
 
 	 ireg=ilat[i]*(ncol+2)+ilon[i];
 	 if (map[ireg]!=i+1)
       cerr << ilat[i] << "/" << ilon[i] << " " << i+1 << "/" << map[ireg] << " " << ireg << endl;
    neigh[nland*0+i]=map[(ilat[i]+0)*(ncol+2)+ilon[i]-1]; // ww neighbour
    neigh[nland*1+i]=map[(ilat[i]+1)*(ncol+2)+ilon[i]-1]; // nw neighbour
    neigh[nland*2+i]=map[(ilat[i]+1)*(ncol+2)+ilon[i]-0]; // nn neighbour
    neigh[nland*3+i]=map[(ilat[i]+1)*(ncol+2)+ilon[i]+1]; // ne neighbour
    neigh[nland*4+i]=map[(ilat[i]+0)*(ncol+2)+ilon[i]+1]; // ee neighbour
    neigh[nland*5+i]=map[(ilat[i]-1)*(ncol+2)+ilon[i]+1]; // se neighbour
    neigh[nland*6+i]=map[(ilat[i]-1)*(ncol+2)+ilon[i]-0]; // ss neighbour
    neigh[nland*7+i]=map[(ilat[i]-1)*(ncol+2)+ilon[i]-1]; // sw neighbour
  }
  var=ncfile.get_var("region_neighbour");
  var->put(neigh,nn,nland);
  
    
  /** Define continuous land masses */
  short int* continent=new short int[nland];
  for (int i=0; i<nland; i++) continent[i]=0;
  double s=0;

  //if (!(dim = ncfile.add_dim("continent",id))) return 1;
  
  if (!(var = ncfile.add_var("continent", ncInt, ncfile.get_dim("continent")))) return 1;
  var->add_att("date_of_creation",monthstring.c_str());
  var->add_att("long_name","continent");
  var->add_att("standard_name","continent enumeration");
  var->add_att("description","Unique identifier of contiguous landmass");
  // has no units attribute

  if (!(var = ncfile.add_var("continent_area", ncFloat, ncfile.get_dim("continent")))) return 1;
  var->add_att("date_of_creation",monthstring.c_str());
  var->add_att("long_name","continental area");
  var->add_att("standard_name","continent_area");
  var->add_att("description","Area of continent");
  var->add_att("units","km^2");

  if (!(var = ncfile.add_var("continent_gridcells", ncInt, ncfile.get_dim("continent")))) return 1;
  var->add_att("date_of_creation",monthstring.c_str());
  var->add_att("long_name","continent_gridcells");
  var->add_att("standard_name","continent_gridcells");
  var->add_att("description","Number of gridcells on continent");
  
  /** End definition mode */
  var=ncfile.get_var("region_continent");
  var->put(continent,nland);
  
  /*int* cont=new int[id];
  float* carea=new float[id];
  int* cnum=new int[id];

  for (int i=0; i<id; i++) {
    cont[i]=i+1;
    cnum[i]=0;
    carea[i]=0;
  }
  var=ncfile.get_var("continent");
  var->put(cont,id);
  //return 0;
  
  for (int i=0; i<nland; i++) {
    cnum[continent[i]-1]++;
    carea[continent[i]-1]+=area[i];
  }
  var=ncfile.get_var("continent_area");
  var->put(carea,id);
  var=ncfile.get_var("continent_gridcells");
  var->put(cnum,id);
  */
  ncfile.close();
 
 return 0;
#endif
}

float calc_gridcell_area(float clat,float dlon,float dlat,float radius) { 
  float area;
  area=2*M_PI*radius*radius*(2*cosd(clat)*sind(dlat/2.0));
  area=area*dlon/360.;
  return area;
}

inline float cosd(float x) {
  return cos(x/180.*M_PI);
}

inline float sind(float x) {
  return sin(x/180.*M_PI);
}

inline float npp_lieth(float temp, float prec) {

/** CL_NPP_LIETH calculates net primary production from temp and precip
%   NPP=CL_NPP_LIETH(TEMP,PREC) calculates the net primary production (npp)
%   based on the limitation model of Lieth (1972).
%   Input parameter 
%     prec : Annual precipitation [mm]
%     temp:  annual mean temperature 
%
%   Output npp in g/m2/a
%
%   Note
%   Lieth's formula is also know as the Miami model.  The code is 
%   based on the implementation by V. Brovkin (1997) in VECODE
*/

  const static float NPPMAX   = 1460;    
  const static float V1       = 0.000664;
  const static float V2       = 0.119;
  const static float V3       = 3.7248;

  float npp_p=(1.-exp(-V1*prec))*NPPMAX;
  float npp_t=1./(1.+V3*exp(-V2*temp))*NPPMAX;
  return min(npp_p,npp_t);
}

  /** Define continuous land masses */
double search_continent(short int** cont, int** neigh, int i, short int id, int nland, int nn) {

   double s;
   int n;
   for (int j=0; j<nn; j++) {
      n=(*neigh)[nland*j+i];
      if ((*cont)[n-1]<1) {
        (*cont)[n-1]=id;
        s++;
        s+=search_continent(cont,neigh,n-1,id,nland,nn);
      }
    }
    return s;
  }

