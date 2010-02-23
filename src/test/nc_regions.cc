/* GLUES nc_regions; this file is part of
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
   @date   2010-02-21
   @file nc_regions.cc
   @description This program creates the region and neighbour files for a land grid of 0.5 resolution
*/

#include "config.h"
#include <string>
#include <ctime>
#include <cstdlib>
#include <iostream>
#include <fstream>
#include <cmath>
#include <cassert>

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
  
  string filename="regions.nc";
  
  /** You may need to run the matlab scripts get_iiasa and cl_read_iiasa
      to create the input file */
  string iiasaname="../../visual/matlab/iiasa.nc";
  
  NcFile ncin(iiasaname.c_str(), NcFile::ReadOnly);
  if (!ncin.is_valid()) return 1;

  NcDim *dim;
  dim=ncin.get_dim("month");
  long ntime=dim->size();
  dim=ncin.get_dim("id");
  long nreg=dim->size();
 
  float *time=new float[ntime];
  float *region=new float[nreg];
  float *latit = new float[nreg];
  float *longit = new float[nreg];
  float *prec = new float[nreg*ntime];
  float *temp = new float[nreg*ntime];
 
  NcVar *var;
  var=ncin.get_var("month");
  var->get(time,ntime);
  var=ncin.get_var("id");
  var->get(region,nreg);
  var=ncin.get_var("lat");
  var->get(latit,nreg);
  var=ncin.get_var("lon");
  var->get(longit,nreg);
  var=ncin.get_var("prec");
  var->get(prec,ntime,nreg);
  var=ncin.get_var("tmean");
  var->get(temp,ntime,nreg);
  ncin.close();
 
  NcFile ncfile(filename.c_str(), NcFile::Replace);
  if (!ncfile.is_valid()) return 1;
  
  time_t today;
  std::time(&today);
  string s1(asctime(gmtime(&today)));
  string timestring=s1.substr(0,s1.find_first_of("\n"));
  
  ncfile.add_att("Conventions","CF-1.4");
  ncfile.add_att("title","GLUES netCDF regions ");
  ncfile.add_att("history","Created by nc_regions");
  ncfile.add_att("institution","GKSS-Forschungszentrum Geesthacht GmbH");
  ncfile.add_att("address","Max-Planck-Str 1, 21502 Geesthacht, Germany");
  ncfile.add_att("principal_investigator","Carsten Lemmen");
  ncfile.add_att("email","carsten.lemmen@gkss.de");
  ncfile.add_att("model_name","GLUES");
  ncfile.add_att("model_version","1.1.7");
  ncfile.add_att("source","GLUES model 1.1.7");
  ncfile.add_att("comment","Background climate provided by IIASA database");
  ncfile.add_att("references","Wirtz & Lemmen, Climatic Change 2003; Lemmen, Geomorphologie 2009");
  ncfile.add_att("date_of_creation",timestring.c_str());
  ncfile.add_att("filenames_output",filename.c_str());
 
 
  const int nrow=360;
  const int ncol=720;
  const int nn=8;
  
  // Create time and region dimensions, copy all others
  // CF-Convention is T,Z,Y,X
  if (!(dim = ncfile.add_dim("time", 0))) return 1;
  if (!(dim = ncfile.add_dim("lat", nrow))) return 1;
  if (!(dim = ncfile.add_dim("lon",ncol))) return 1;
  if (!(dim = ncfile.add_dim("region", nreg))) return 1;
  if (!(dim = ncfile.add_dim("neighbour", nn))) return 1;
  
  // Create coordinate variables
  if (!(var = ncfile.add_var("time", ncFloat, ncfile.get_dim("time")))) return 1;
  var->add_att("date_of_creation",timestring.c_str());
  var->add_att("long_name","time");
  var->add_att("standard_name","time");
  var->add_att("units","month of the year");
  var->add_att("axis","T");

  if (!(var = ncfile.add_var("lat", ncFloat, ncfile.get_dim("lat")))) return 1;
  var->add_att("date_of_creation",timestring.c_str());
  var->add_att("long_name","latitude");
  var->add_att("standard_name","latitude");
  var->add_att("units","degree_north");
  var->add_att("axis","Y");
  
  if (!(var = ncfile.add_var("lon", ncFloat, ncfile.get_dim("lon")))) return 1;
  var->add_att("date_of_creation",timestring.c_str());
  var->add_att("long_name","longitude");
  var->add_att("standard_name","longitude");
  var->add_att("units","degree_east");
  var->add_att("axis","X");
  
  if (!(var = ncfile.add_var("region", ncInt, ncfile.get_dim("region")))) return 1;
  var->add_att("date_of_creation",timestring.c_str());
  var->add_att("long_name","region id");
  var->add_att("standard_name","region_id");
  var->add_att("description","Unique identifier of discrete region");
  var->add_att("coordinates","lat lon");
  // has no units attribute

  if (!(var = ncfile.add_var("neighbour", ncInt, ncfile.get_dim("neighbour")))) return 1;
  var->add_att("date_of_creation",timestring.c_str());
  var->add_att("long_name","neighbour");
  var->add_att("standard_name","neighbour");
  var->add_att("description","neighbour enumeration {ww,nw,nn,ne,ee,se,ss,sw}");
  // has no units attribute


  if (!(var = ncfile.add_var("latitude", ncFloat, ncfile.get_dim("region")))) return 1;
  var->add_att("date_of_creation",timestring.c_str());
  var->add_att("long_name","latitude");
  var->add_att("standard_name","latitude");
  var->add_att("units","degree_north");
  var->add_att("description","Latitude of region center");
  var->add_att("coordinates","lat lon");
  
  if (!(var = ncfile.add_var("longitude", ncFloat, ncfile.get_dim("region")))) return 1;
  var->add_att("date_of_creation",timestring.c_str());
  var->add_att("long_name","longitude");
  var->add_att("standard_name","longitude");
  var->add_att("units","degree_east");
  var->add_att("description","Longitude of region center");
  var->add_att("coordinates","lat lon");
 
  if (!(var = ncfile.add_var("temperature", ncFloat, ncfile.get_dim("time"), ncfile.get_dim("region")))) return 1;
  var->add_att("date_of_creation",timestring.c_str());
  var->add_att("long_name","monthly mean temperature");
  var->add_att("standard_name","monthly_mean_temperature");
  var->add_att("units","degree_celsius");
  var->add_att("description","Monthly mean temperature from IIASA climatology");
  var->add_att("reference","Leemans & Cramer (1991)");
  var->add_att("coordinates","time lat lon");
 
  if (!(var = ncfile.add_var("precipitation", ncFloat, ncfile.get_dim("time"), ncfile.get_dim("region")))) return 1;
  var->add_att("date_of_creation",timestring.c_str());
  var->add_att("long_name","monthly sum of precipitation");
  var->add_att("standard_name","monthly_sum_precipitation");
  var->add_att("units","mm");
  var->add_att("description","Monthly precipitation from IIASA climatology");
  var->add_att("reference","Leemans & Cramer (1991)");
  var->add_att("coordinates","time lat lon");
 
 /*if (!(var = ncfile.add_var("region_map", ncFloat, ncfile.get_dim("lat"), ncfile.get_dim("lon")))) return 1;
  var->add_att("date_of_creation",timestring.c_str());
  var->add_att("long_name","region map");
  var->add_att("standard_name","region_map");
  var->add_att("description","Map of region id"); 
*/

  if (!(var = ncfile.add_var("annual_precipitation", ncFloat, ncfile.get_dim("region")))) return 1;
  var->add_att("date_of_creation",timestring.c_str());
  var->add_att("long_name","annual precipitation");
  var->add_att("standard_name","annual_precipitation");
  var->add_att("units","mm");
  var->add_att("description","Annual cumulative precipitation from IIASA climatology");
  var->add_att("reference","Leemans & Cramer (1991)");
  var->add_att("coordinates","lat lon");

  if (!(var = ncfile.add_var("annual_temperature", ncFloat, ncfile.get_dim("region")))) return 1;
  var->add_att("date_of_creation",timestring.c_str());
  var->add_att("long_name","annual mean temperature");
  var->add_att("standard_name","annual_mean_temperature");
  var->add_att("units","degree_C");
  var->add_att("description","Annual mean temperature from IIASA climatology");
  var->add_att("reference","Leemans & Cramer (1991)");
  var->add_att("coordinates","lat lon");


  if (!(var = ncfile.add_var("region_neighbour", ncInt, ncfile.get_dim("neighbour"), ncfile.get_dim("region")))) return 1;
  var->add_att("date_of_creation",timestring.c_str());
  var->add_att("long_name","region neighbour");
  var->add_att("standard_name","region_neighbour");
  var->add_att("description","Region id of neighbours to 8 directions");
  var->add_att("coordinates","lat lon neighbour");

  if (!(var = ncfile.add_var("area", ncFloat, ncfile.get_dim("region")))) return 1;
  var->add_att("date_of_creation",timestring.c_str());
  var->add_att("long_name","area");
  var->add_att("units","km^{2}");
  var->add_att("standard_name","region_area");
  var->add_att("description","Area of single region (gridcell)");
  var->add_att("coordinates","lat lon");

  if (!(var = ncfile.add_var("npp", ncFloat, ncfile.get_dim("region")))) return 1;
  var->add_att("date_of_creation",timestring.c_str());
  var->add_att("long_name","net primary productivity");
  var->add_att("standard_name","net_primary_productivity");
  var->add_att("description","Net primary production of carbon");
  var->add_att("units","g m^-2 a^-1");
  var->add_att("coordinates","lat lon");

  if (!(var = ncfile.add_var("gdd", ncFloat, ncfile.get_dim("region")))) return 1;
  var->add_att("date_of_creation",timestring.c_str());
  var->add_att("long_name","growing degree days above zero");
  var->add_att("standard_name","growing_degree_days_above_zero");
  var->add_att("description","Number of days with mean temperature above zero");
  var->add_att("coordinates","lat lon");

  if (!(var = ncfile.add_var("region_continent", ncShort, ncfile.get_dim("region")))) return 1;
  var->add_att("date_of_creation",timestring.c_str());
  var->add_att("long_name","region continent");
  var->add_att("standard_name","region_continent");
  var->add_att("description","Unique number of continuous landmass on which region is located");
  var->add_att("coordinates","lat lon");
 
  // Fill coordinate variables with values
  var=ncfile.get_var("time");
  for (int i=0; i<ntime; i++) var->put_rec(time+i,i);
  var=ncfile.get_var("neighbour");
  float neighbour[8]={1,2,3,4,5,6,7,8};
  var->put(neighbour);

  float lly=-89.75;
  float llx=-179.75;
  float dx=0.5;
  float dy=0.5;
  float *lat  = new float[nrow];
  for (int i=0; i<nrow; i++) {
    lat[i]=lly+dy*i;
  }
  var=ncfile.get_var("lat");
  var->put(lat,nrow);
  
  float *lon = new float[ncol];
  for (int i=0; i<ncol; i++) {
    lon[i]=llx+dx*i;
  }
  var=ncfile.get_var("lon");
  var->put(lon,ncol);

  var=ncfile.get_var("region");
  var->put(region,nreg);

  // Fill  variables with values
  var=ncfile.get_var("latitude");
  var->put(latit,nreg);
  var=ncfile.get_var("longitude");
  var->put(longit,nreg);
  var=ncfile.get_var("precipitation");
  var->put(prec,ntime,nreg);
  var=ncfile.get_var("temperature");
  var->put(temp,ntime,nreg);
  
  int* ilat=new int[nreg];
  int* ilon=new int[nreg];
  int* map=new int[(nrow+2)*(ncol+2)];
  for (int i=0; i<(nrow+2)*(ncol+2); i++) map[i]=0;
  
  //int maxlat=10000;
  for (int i=0; i<nreg; i++) {
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

  int* neigh=new int[nreg*nn];
  int ireg;
  for (int i=0; i<nreg; i++) {
 
 	 ireg=ilat[i]*(ncol+2)+ilon[i];
 	 if (map[ireg]!=i+1)
       cerr << ilat[i] << "/" << ilon[i] << " " << i+1 << "/" << map[ireg] << " " << ireg << endl;
    neigh[nreg*0+i]=map[(ilat[i]+0)*(ncol+2)+ilon[i]-1]; // ww neighbour
    neigh[nreg*1+i]=map[(ilat[i]+1)*(ncol+2)+ilon[i]-1]; // nw neighbour
    neigh[nreg*2+i]=map[(ilat[i]+1)*(ncol+2)+ilon[i]-0]; // nn neighbour
    neigh[nreg*3+i]=map[(ilat[i]+1)*(ncol+2)+ilon[i]+1]; // ne neighbour
    neigh[nreg*4+i]=map[(ilat[i]+0)*(ncol+2)+ilon[i]+1]; // ee neighbour
    neigh[nreg*5+i]=map[(ilat[i]-1)*(ncol+2)+ilon[i]+1]; // se neighbour
    neigh[nreg*6+i]=map[(ilat[i]-1)*(ncol+2)+ilon[i]-0]; // ss neighbour
    neigh[nreg*7+i]=map[(ilat[i]-1)*(ncol+2)+ilon[i]-1]; // sw neighbour
  }
  var=ncfile.get_var("region_neighbour");
  var->put(neigh,nn,nreg);
  
  // Calculate gridcell area
  float * fval=new float[nreg];
  float * area=new float[nreg];
  for (int i=0; i<nreg; i++) area[i]=calc_gridcell_area(latit[i]);
  var=ncfile.get_var("area");
  var->put(area,nreg);
  
  // Calculate npp with Miami limitation model
  float *atemp=new float[nreg];
  float *aprec=new float[nreg];
  float *gdd  =new float[nreg];
  for (int i=0; i<nreg; i++) {
    aprec[i]=prec[i*ntime+0];
    atemp[i]=temp[i*ntime+0];
    gdd[i]=(temp[i*ntime+0]>0?1:0);
    for (int j=1; j<ntime; j++) {
      aprec[i]+=prec[j*nreg+i];
      atemp[i]+=temp[j*nreg+i];
      gdd[i]+=(temp[j*nreg+i]>0?1:0);
    }
    atemp[i]/=ntime;
    gdd[i]*=30; // 360 day calendar
    fval[i]=npp_lieth(atemp[i],aprec[i]);
  }
  var=ncfile.get_var("npp");
  var->put(fval,nreg);
  var=ncfile.get_var("gdd");
  var->put(gdd,nreg);
  
  var=ncfile.get_var("annual_temperature");
  var->put(atemp,nreg);
  var=ncfile.get_var("annual_precipitation");
  var->put(aprec,nreg);
  
  
  /** Define continuous land masses */
  short int* continent=new short int[nreg];
  for (int i=0; i<nreg; i++) continent[i]=0;
  short int id=0;
  double s=0;
  for (int i=0; i<nreg; i++) {
    if (continent[i]>0) continue;
    
    id++;
    continent[i]=id;
    search_continent(&continent,&neigh,i,id,nreg,nn); 
  }

  if (!(dim = ncfile.add_dim("continent",id))) return 1;
  
  if (!(var = ncfile.add_var("continent", ncInt, ncfile.get_dim("continent")))) return 1;
  var->add_att("date_of_creation",timestring.c_str());
  var->add_att("long_name","continent");
  var->add_att("standard_name","continent enumeration");
  var->add_att("description","Unique identifier of contiguous landmass");
  // has no units attribute

  if (!(var = ncfile.add_var("continent_area", ncFloat, ncfile.get_dim("continent")))) return 1;
  var->add_att("date_of_creation",timestring.c_str());
  var->add_att("long_name","continental area");
  var->add_att("standard_name","continent_area");
  var->add_att("description","Area of continent");
  var->add_att("units","km^2");

  if (!(var = ncfile.add_var("continent_gridcells", ncInt, ncfile.get_dim("continent")))) return 1;
  var->add_att("date_of_creation",timestring.c_str());
  var->add_att("long_name","continent_gridcells");
  var->add_att("standard_name","continent_gridcells");
  var->add_att("description","Number of gridcells on continent");
  
  /** End definition mode */
  var=ncfile.get_var("region_continent");
  var->put(continent,nreg);
  
  int* cont=new int[id];
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
  
  for (int i=0; i<nreg; i++) {
    cnum[continent[i]-1]++;
    carea[continent[i]-1]+=area[i];
  }
  var=ncfile.get_var("continent_area");
  var->put(carea,id);
  var=ncfile.get_var("continent_gridcells");
  var->put(cnum,id);
  
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
double search_continent(short int** cont, int** neigh, int i, short int id, int nreg, int nn) {

   double s;
   int n;
   for (int j=0; j<nn; j++) {
      n=(*neigh)[nreg*j+i];
      if ((*cont)[n-1]<1) {
        (*cont)[n-1]=id;
        s++;
        s+=search_continent(cont,neigh,n-1,id,nreg,nn);
      }
    }
    return s;
  }

