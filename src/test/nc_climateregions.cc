/* GLUES nc_climateregions; this file is part of
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
   @date   2010-03-04
   @file nc_climateregions.cc
   @description This program reads a map (created by nc_regionmap), reads a climatology and
   a varying climate, produces regions and neighbour files
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
  
  /** You may need to run nc_regions to get regions.nc grid file
      You may need to rund nc_regionmap to create map file from raster file
   */


  string mapfilename="glues_map.nc";
  string regionfilename="regions.nc";
  string transientfilename="plasim_11k-2.nc";
  string filename="regions_11k-2.nc";
  
/** Read the climatology, this file need to include the variables longitude, latitude,
monthly precip and montly temperature */

  NcFile ncc(regionfilename.c_str(), NcFile::ReadOnly);
  if (!ncc.is_valid()) { 
    std::cerr << "Regions/climatology file " << regionfilename << " not found." << std::endl
    << "Please run nc_regions to create this file." << std::endl;
    return 1;
  }

  NcDim *dim;
  dim=ncc.get_dim("time");
  long nmonth=dim->size();
  dim=ncc.get_dim("region");
  long nland=dim->size();
 
  float *month=new float[nmonth];
  float *latit = new float[nland];
  float *longit = new float[nland];
  float *prec = new float[nland*nmonth];
  float *temp = new float[nland*nmonth];
  float dx=0.5;
  float dy=0.5;

  NcVar *var;
  var=ncc.get_var("time");
  var->get(month,nmonth);
  var=ncc.get_var("latitude");
  var->get(latit,nland);
  var=ncc.get_var("longitude");
  var->get(longit,nland);
  var=ncc.get_var("precipitation");
  var->get(prec,nmonth,nland);
  var=ncc.get_var("temperature");
  var->get(temp,nmonth,nland);
  ncc.close();
 
 /** now open transient climate run, this may be on a different grid */
 
  NcFile nct(transientfilename.c_str(), NcFile::ReadOnly);
  if (!nct.is_valid()) return 1;
  
  long ny=nct.get_dim("lat")->size();
  long nx=nct.get_dim("lon")->size();
  long ntime=nct.get_dim("time")->size();
  
  float *time=new float[ntime];
  float *lat = new float[ny];
  float *lon = new float[nx];
  float *lsp = new float[ntime*ny*nx];
  float *t2 =  new float[ntime*ny*nx];
  
  nct.get_var("time")->get(time,ntime);
  nct.get_var("lat")->get(lat,ny);
  nct.get_var("lon")->get(lon,nx);
  nct.get_var("lsp")->get(lsp,ntime,ny,nx);
  nct.get_var("t2")->get(t2,ntime,ny,nx);
 
  long nyear=ntime/12;
  long ystep=50;         // Plasim is 50 year climatological value
  long yoffset=-9000;    // Start of simulation is 9000 BC
  
  /** Interpolation of climate */
  float *tyear=new float[nmonth*nland];
  float *pyear=new float[nmonth*nland];
  float *tslice=new float[nmonth*ny*nx]; // current time record
  float *pslice=new float[nmonth*ny*nx]; // current time record
  float *t0=new float[nmonth*ny*nx];     // time record at 1950
  float *p0=new float[nmonth*ny*nx];     // time record at 1950
  var=nct.get_var("t2");
  var->set_cur((nyear-1)*nmonth,-1,-1);
  var->get(t0,nmonth,ny,nx);
  var=nct.get_var("lsp");
  var->set_cur((nyear-1)*nmonth,-1,-1);
  var->get(p0,nmonth,ny,nx);
 
  long ila,ilo;
  float* npp = new float[nyear*nland];
  float* gdd = new float[nyear*nland];
  float* tann= new float[nland];
  float* pann= new float[nland];
  float* year= new float[nyear];
  float monthdays[12]={31,28.25,31,30,31,30,31,31,30,31,30,31};

  for (int i=0; i<nland*nyear; i++) {
    npp[i]=0;
    gdd[i]=0;
  }
 
  for (int i=0; i<nyear; i++) year[i]=yoffset+ystep*i;
  
  for (int y=0; y<nyear; y++) {
     var=nct.get_var("t2");
     var->set_cur(y*nmonth,-1,-1);
     var->get(tslice,nmonth,ny,nx);
     var=nct.get_var("lsp");
     var->set_cur(y*nmonth,-1,-1);
     var->get(pslice,nmonth,ny,nx);
     
     float tanmean=0;
     float panmean=0;
     for (int i=0; i<-nx*ny*nmonth; i++) {
       panmean+=abs(pslice[i]-p0[i]);
       tanmean+=abs(tslice[i]-t0[i]);
     }
     //cout << tanmean << " " << panmean << " " ;
     
     float nppmean=0;
     float gddmean=0;
     tanmean=0;
     panmean=0;
     for (int l=0;l<nland;l++) {
       pann[l]=0;
       tann[l]=0;
       ila=( latit[l]+(lat[2]-lat[1])/2.0-lat[0])/(lat[2]-lat[1]);
       ilo=(longit[l]+(lon[2]-lon[1])/2.0-lon[0])/(lon[2]-lon[1]);
       //cout << l ;
       for (int m=0; m<nmonth;m++)  {
         tyear[m*nland+l]=temp[m*nland+l]+tslice[(m*ny+ila)*nx+ilo]-t0[(m*ny+ila)*nx+ilo];
         pyear[m*nland+l]=prec[m*nland+l]+pslice[(m*ny+ila)*nx+ilo]-p0[(m*ny+ila)*nx+ilo];
         if (pyear[m*nland+l]<0) pyear[m*nland+l]=0;
         tann[l]+=tyear[m*nland+l]/12.0;
         pann[l]+=pyear[m*nland+l];
         gdd[y*nland+l]+=(tyear[m*nland+l]>=0?1:0)*monthdays[m];
         //cout << " " << temp[m*nland+l] << " " << tyear[m*nland+l];
       }
       npp[y*nland+l]=npp_lieth(tann[l],pann[l]);
       if (npp_lieth(tann[l],pann[l])<0) {
           cerr << l << " " << y << " " << tann[l] << " " << pann [l] << endl;
           return 1;
       }
       tanmean+=tann[l]/nland;
       panmean+=pann[l]/nland;
       nppmean+=npp[y*nland+l]/nland;
       gddmean+=gdd[y*nland+l]/nland;
       //cout << " " << tann[l] << " " << pann[l] << " " << npp[y*nland+l] << " " << gdd[y*nland+l] << endl;
     }      
     //cout << year[y] << " " << tanmean << " " << panmean << " " << nppmean << " " << gddmean << endl;
  }
  delete [] p0; delete [] t0;
  delete [] pslice; delete [] tslice;
  delete [] pann; delete [] tann;
  delete [] tyear; delete [] pyear;
 
  nct.close();
 
 
  NcFile ncfile(filename.c_str(), NcFile::Replace);
  if (!ncfile.is_valid()) return 1;
  
  time_t today;
  std::time(&today);
  string s1(asctime(gmtime(&today)));
  string monthstring=s1.substr(0,s1.find_first_of("\n"));
  
  ncfile.add_att("Conventions","CF-1.4");
  ncfile.add_att("title","GLUES netCDF regions ");
  ncfile.add_att("history","Created by nc_climateregions");
  ncfile.add_att("institution","GKSS-Forschungszentrum Geesthacht GmbH");
  ncfile.add_att("address","Max-Planck-Str 1, 21502 Geesthacht, Germany");
  ncfile.add_att("principal_investigator","Carsten Lemmen");
  ncfile.add_att("email","carsten.lemmen@gkss.de");
  ncfile.add_att("model_name","GLUES");
  ncfile.add_att("model_version","1.1.8");
  ncfile.add_att("source","GLUES model 1.1.8");
  ncfile.add_att("comment","Background climate provided by Plasim anomalies on IIASA database");
  ncfile.add_att("references","Wirtz & Lemmen, Climatic Change 2003; Lemmen, Geomorphologie 2009");
  ncfile.add_att("date_of_creation",monthstring.c_str());
  ncfile.add_att("filenames_output",filename.c_str());
 
  // Create month and region dimensions, copy all others
  // CF-Convention is T,Z,Y,X
  long nn=8;
  if (!(dim = ncfile.add_dim("time", 0))) return 1;
  if (!(dim = ncfile.add_dim("region", nland))) return 1;
  if (!(dim = ncfile.add_dim("neighbour", nn))) return 1;
  
  // Create coordinate variables
  if (!(var = ncfile.add_var("time", ncFloat, ncfile.get_dim("time")))) return 1;
  var->add_att("date_of_creation",monthstring.c_str());
  var->add_att("long_name","month");
  var->add_att("standard_name","year");
  var->add_att("units","years since 1");
  var->add_att("average","50 year average from denoted year");
  var->add_att("axis","T");

  if (!(var = ncfile.add_var("lat", ncFloat, ncfile.get_dim("region")))) return 1;
  var->add_att("date_of_creation",monthstring.c_str());
  var->add_att("long_name","latitude");
  var->add_att("standard_name","latitude");
  var->add_att("description","Latitude of region center");
  var->add_att("units","degree_north");
  
  if (!(var = ncfile.add_var("lon", ncFloat, ncfile.get_dim("region")))) return 1;
  var->add_att("date_of_creation",monthstring.c_str());
  var->add_att("long_name","longitude");
  var->add_att("standard_name","longitude");
  var->add_att("units","degree_east");
  var->add_att("description","Longitude of region center");
  
  if (!(var = ncfile.add_var("region", ncInt, ncfile.get_dim("region")))) return 1;
  var->add_att("date_of_creation",monthstring.c_str());
  var->add_att("long_name","region id");
  var->add_att("standard_name","region_id");
  var->add_att("description","Unique identifier of discrete region");
  // has no units attribute

  if (!(var = ncfile.add_var("neighbour", ncInt, ncfile.get_dim("neighbour")))) return 1;
  var->add_att("date_of_creation",monthstring.c_str());
  var->add_att("long_name","neighbour");
  var->add_att("standard_name","neighbour");
  var->add_att("description","neighbour enumeration {ww,nw,nn,ne,ee,se,ss,sw}");
  // has no units attribute

  if (!(var = ncfile.add_var("region_neighbour", ncInt, ncfile.get_dim("neighbour"), ncfile.get_dim("region")))) return 1;
  var->add_att("date_of_creation",monthstring.c_str());
  var->add_att("long_name","region neighbour");
  var->add_att("standard_name","region_neighbour");
  var->add_att("description","Region id of neighbours to 8 directions");
  
  if (!(var = ncfile.add_var("area", ncFloat, ncfile.get_dim("region")))) return 1;
  var->add_att("date_of_creation",monthstring.c_str());
  var->add_att("long_name","area");
  var->add_att("units","km^{2}");
  var->add_att("standard_name","region_area");
  var->add_att("description","Area of single region (gridcell)");
  
  if (!(var = ncfile.add_var("npp", ncShort, ncfile.get_dim("time"), ncfile.get_dim("region")))) return 1;
  var->add_att("date_of_creation",monthstring.c_str());
  var->add_att("long_name","net primary productivity");
  var->add_att("standard_name","net_primary_productivity");
  var->add_att("description","Net primary production of carbon");
  var->add_att("units","g m^-2 a^-1");
  
  if (!(var = ncfile.add_var("gdd", ncShort, ncfile.get_dim("time"),  ncfile.get_dim("region")))) return 1;
  var->add_att("date_of_creation",monthstring.c_str());
  var->add_att("long_name","growing degree days above zero");
  var->add_att("standard_name","growing_degree_days_above_zero");
  var->add_att("description","Number of days with mean temperature above zero");
  
  if (!(var = ncfile.add_var("region_continent", ncShort, ncfile.get_dim("region")))) return 1;
  var->add_att("date_of_creation",monthstring.c_str());
  var->add_att("long_name","region continent");
  var->add_att("standard_name","region_continent");
  var->add_att("description","Unique number of continuous landmass on which region is located");
    
  // Fill coordinate variables with values
  var=ncfile.get_var("time");
  for (int i=0; i<nyear; i++) var->put_rec(year+i,i);
  
  float neighbour[8]={1,2,3,4,5,6,7,8};
  ncfile.get_var("neighbour")->put(neighbour,nn);

  int* region=new int[nland];
  for (int i=0; i<nland; i++) region[i]=i+1;
  ncfile.get_var("region")->put(region,nland);

  // Fill  variables with values
  var=ncfile.get_var("lat");
  var->put(latit,nland);
  var=ncfile.get_var("lon");
  var->put(longit,nland);
  
  int ncol=720; 
  int nrow=360;
  float lly=-89.75;
  float llx=-179.75;

  int* ilat=new int[nland];
  int* ilon=new int[nland];
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
  
  // Calculate gridcell area
  float * area=new float[nland];
  float * fval=new float[nland];
  for (int i=0; i<nland; i++) area[i]=calc_gridcell_area(latit[i]);
  var=ncfile.get_var("area");
  var->put(area,nland);
 
  var=ncfile.get_var("npp");
  short * sh=new short[nland*nyear];
  for (int i=0; i<nland*nyear; i++) sh[i]=lrintf(npp[i]);
  var->put(sh,nyear,nland);
  for (int i=0; i<nland*nyear; i++) sh[i]=lrintf(gdd[i]);
  var=ncfile.get_var("gdd");
  var->put(sh,nyear,nland);
    
  /** Define continuous land masses */
  short int* continent=new short int[nland];
  for (int i=0; i<nland; i++) continent[i]=0;
  short int id=0;
  double s=0;
  for (int i=0; i<nland; i++) {
    if (continent[i]>0) continue;    
    id++;
    continent[i]=id;
    search_continent(&continent,&neigh,i,id,nland,nn); 
  }

  if (!(dim = ncfile.add_dim("continent",id))) return 1;
  
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
  
  for (int i=0; i<nland; i++) {
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

