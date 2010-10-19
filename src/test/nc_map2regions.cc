/* GLUES nc_map2regions; this file is part of
   the Global Land Use and technological Evolution Simulator
   
   Copyright (C) 2010
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
   @date   2010-10-19
   @file nc_map2regions.cc
   @description This program converts the mapping information added to the climate region file
   (created by nc_climateregions and subsequent nc_add_map), and scales all info on the climateregions to the new map
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

float sind(float);
float cosd(float);
float calc_geodesic(float,float,float,float);
float calc_gridcell_area(float clat,float dlon=0.5,float dlat=0.5,float radius=6378.137);
float npp_lieth(float,float);
double search_continent(short int**,int**,int, short int,int,int);
bool is_var(NcFile*, std::string);

int main(int argc, char* argv[]) 
{

#ifndef HAVE_NETCDF_H
    std::cout << " No netcdf interface defined. FAIL" << std::endl;
    return 1;
#else
  
  /** You may need to run nc_climateregions to get regions_*.nc grid file
      You may need to rund nc_add_map to have mapid information in file
   */
  std::string cellfilename="regions_11k-2.nc";
  std::string filename="regions_11k-2_685.nc";
 
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
  int *neigh = new int[nland*nn];
  ncc.get_var("region_neighbour")->get(neigh,nn,nland);
  int* numneigh=new int[nland];

  if (!is_var(&ncc,"map_id")) {
    std::cerr << "Please add map_id information by running nc_add_map." << std::endl;
    return 1;
  }
  int * regionid=new int[nland];
  ncc.get_var("map_id")->get(regionid,nland);

  assert(gdd != NULL);
  assert(npp != NULL);
    
  int * ilat=new int[nland];
  int * ilon=new int[nland];
  int minreg=nland;
  int maxreg=0;
  for (int i=0; i<nland; i++) {
    if (minreg>=regionid[i] && regionid[i]>0) minreg=regionid[i];
    if (maxreg<=regionid[i] && regionid[i]>0) maxreg=regionid[i];
    //cout << minreg << " " << maxreg << endl;
  }
  
  int nreg=maxreg-minreg+1;
  int* reg=new int[nreg];
  int* regn=new int[nreg];
  int* regnn=new int[nreg];
  float* reglon=new float[nreg];
  float* reglat=new float[nreg];
  float* regarea=new float[nreg];
  float* reggdd=new float[nyear*nreg];
  float* regnpp=new float[nyear*nreg];
  int nnmax=30; /* Assume at most 30 neighbour regions */
  int* regneigh=new int[nreg*nnmax];  
  int* regboundary=new int[nreg*nnmax];  
  float dx=0.5;
  float dy=0.5;
  
  for (int i=0; i<nreg; i++) {
    reg[i]=i+1;
    regn[i]=0;
    regnn[i]=0;
    reglat[i]=0;
    reglon[i]=0;
    reggdd[i]=0;
    regnpp[i]=0;
    for (int j=0; j<nnmax; j++) {
      regneigh[j*nreg+i]=0;
      regboundary[j*nreg+i]=0;
    } 
  }

  NcFile ncfile(filename.c_str(), NcFile::Replace);
  if (!ncfile.is_valid()) return 1;

  for (int i=0; i<nland; i++) {
    numneigh[i]=0;
    reglon[regionid[i]-1]+=longit[i];
    reglat[regionid[i]-1]+=latit[i];
    regarea[regionid[i]-1]+=area[i];
    regn[regionid[i]-1]++;
    for (int j=0; j<nyear; j++) {
      reggdd[j*nreg+regionid[i]-1]+=gdd[j*nland+i];
      regnpp[j*nreg+regionid[i]-1]+=npp[j*nland+i];
    }
    for (int j=0; j<nn; j++) {
      if (neigh[j*nland+i]>0) numneigh[i]++;
    }
  }  

 for (int i=0; i<nland; i++) {
    if (regionid[i]<1) continue;
    //std::cout << "r[" << i << "]=" << region[i] << " (" << numneigh[i] << "):" ; 
//    std::cout << "r[" << i << "]=" << regionid[i] << " " << longit[i] << "|" << latit[i]; 
 
    if (numneigh[i]<1) continue;
    int k,n;
 	for (int j=0; j<nn; j++) {
      //int neighid=neigh[j*nland+i];
 	  int neighid=neigh[j*nland+i];
 	  if (neighid<1) continue;         // break if neighbour not labeled (zero value)
 	  if (regionid[neighid-1]<1) continue; // break if neighbour is sea
 	  
 	  /* Check for mutual neighbour relationship 
 	  if not, fix this in the the creating program */
 	  if (neigh[((j+4)%8)*nland+neighid-1] != region[i]) {
 	    std::cout << "r[" << i << "]=" << region[i] << " (" << j << ") n[" 
 	              << neighid-1 << "]=" << neigh[((j+4)%8)*nland+neighid-1] << std::endl;
 	  }
 	  //std::cout << " " << j << ":" << neighid << ":" << neigh[((j+4)%8)*nland+neighid-1];
 	  
 	  if (regionid[neighid-1]==regionid[i]) continue; // break if neighbour same id 
 	  /* Find neighbour in this region */
 	  n=regnn[regionid[i]-1];
 	  k=0;
 	  //cout << " " << neighid <<  "[" << j << "]="  << longit[neighid-1] << "|" << latit[neighid-1]; //regionid[neighid-1];
 	  //while (k<n && regneigh[(regionid[i]-1)*nnmax+k]!=regionid[neighid-1] ) {
 	  while (k<n && regneigh[k*nreg+(regionid[i]-1)]!=regionid[neighid-1] ) {
 	    //cout << " " << k << "/" << n; 
 	    k++;
 	  }
 	  if (k>=nnmax) {
 	    std::cerr << "Insufficent size of nnmax, please increase in source code.\n";
 	    return 1;
 	  }
 	  
 	  /** Calc boundary */
 	  int edge=1/20.0;  // Allow diagonally adjacent gridcells a connection of length edge
 	  float boundary=calc_geodesic(longit[neighid-1],latit[neighid-1],longit[i],latit[i]);
 	  if (j%2>0) boundary*=edge;
 	  regboundary[k*nreg+(regionid[i]-1)]+=boundary;
      
      /** Add neighbour if new otherwise skip this*/
 	  if (k<n) continue; 
 	  regnn[regionid[i]-1]++;
 	  //regneigh[(regionid[i]-1)*nnmax+k]=regionid[neighid-1];
 	  regneigh[k*nreg+(regionid[i]-1)]=regionid[neighid-1];
 	  //cout << regionid[i] << " " << longit[i] << " " << longit[neighid-1];
 	  //assert(fabs( latit[i]- latit[neighid-1])<=0.5);
 	  //assert(fabs(longit[i]-longit[neighid-1])<=0.5);
   }
   //   cout << " " << regnn[regionid[i]-1] << endl;
   //if (i > 20) break;
  //std::cout << std::endl;
}

  delete [] npp, gdd, area, latit, longit, ilat, ilon, neigh;

  nn=0;
  int maxregn=0;
  for (int i=0; i<nreg; i++) {
    for (int j=0; j<nyear; j++) {
      regnpp[j*nreg+i]/=1.0*std::max(1,regn[i]);
      reggdd[j*nreg+i]/=1.0*std::max(1,regn[i]);
    }
    reglon[i]/=regn[i];
    reglat[i]/=regn[i];
    if (regnn[i]>nn) nn=regnn[i];
    if (regn[i]>maxregn) maxregn=regn[i];
//    std::cout << i << " " << regn[i] << " " << reggdd[i] << " " << regnpp[i] << endl;
  }
  
  /** Copy regneigh [nreg*nnmax] into new neigh[nreg*nn] 
      and swap arrays after copying */
  neigh=new int[nn*nreg];
  for (int i=0; i<nreg; i++) {
    std::cout << reg[i] << " " << regn[i] << " " << reglon[i] 
              << "|" << reglat[i] << " " << regnn[i];
    for (int j=0; j<regnn[i]; j++) {
      //neigh[i*nn+j]=regneigh[i*nnmax+j];
      //neigh[j*nreg+i]=regneigh[i*nnmax+j];
      neigh[j*nreg+i]=regneigh[j*nreg+i];
      std::cout << " " << regneigh[j*nreg+i];
    }
    std::cout << std::endl;
  } 
  delete [] regneigh;
  regneigh=neigh;
  delete [] neigh;
 
 
 /** get the back-mapping into cells array */
  int * ncell = new int [nreg];
  int * cells = new int [nreg*maxregn];
  int r,p;
  for (int i=0; i<nreg; i++) ncell[i]=0;
  for (int i=0; i<nland; i++) {
    r=regionid[i];
    if (r<1) continue;
    cells[(r-1)*maxregn+ncell[r-1]]=region[i];
    ncell[r-1]++;
  }
 
 
 /** Create new file */
  if (!ncfile.is_valid()) return 1;
  
  time_t today;
  time(&today);
  std::string s1(asctime(gmtime(&today)));
  std::string monthstring=s1.substr(0,s1.find_first_of("\n"));
  
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
     else if (!strncmp(dim->name(),"neighbour",6)) ncfile.add_dim(dim->name(), nn); // TODO
     else if (!strncmp(dim->name(),"continent",6)) ncfile.add_dim(dim->name(), ncont); // TODO
     else ncfile.add_dim(dim->name(), dim->size());
  }
  ncfile.add_dim("cell",maxregn);

  for (int i=0; i<ncc.num_vars(); i++) {
    var=ncc.get_var(i);
    if (!strncmp(var->name(),"map_id",6)) continue;
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
   // cout << "added varialbe " << var->name() << endl;
    
  }

  if (!(var = ncfile.add_var("number_of_gridcells", ncInt, ncfile.get_dim("region")))) return 1;
  var->add_att("date_of_creation",monthstring.c_str());
  var->add_att("long_name","number_of_gridcells");
  var->add_att("description","number of half degree grid cells associated with this region");

  if (!(var = ncfile.add_var("gridcells", ncInt, ncfile.get_dim("region"),ncfile.get_dim("cell")))) return 1;
  var->add_att("date_of_creation",monthstring.c_str());
  var->add_att("long_name","gridcells");
  var->add_att("description","ids of grid cells associated with this region");
  
  var=ncfile.add_var("number_of_neighbours",ncFloat,ncfile.get_dim("region"));
  var->add_att("date_of_creation",monthstring.c_str());
  var->add_att("long_name","number_of_neighbours");
  var->add_att("description","number of neighbours to this region");
  
  var=ncfile.add_var("region_boundary",ncFloat,ncfile.get_dim("neighbour"),ncfile.get_dim("region"));
  var->add_att("date_of_creation",monthstring.c_str());
  var->add_att("long_name","region_boundary");
  var->add_att("description","Length of boundaries to neighbours");
  var->add_att("units","km");
  
  /** Fill values */
  ncfile.get_var("time")->put(year,nyear);
  ncfile.get_var("number_of_gridcells")->put(regn,nreg);
  ncfile.get_var("region")->put(reg,nreg);
  ncfile.get_var("lon")->put(reglon,nreg);
  ncfile.get_var("lat")->put(reglat,nreg);
  ncfile.get_var("area")->put(regarea,nreg);
  short* sh=new short[nyear*nreg];
  for (int i=0; i<nyear*nreg; i++) sh[i]=lrintf(regnpp[i]);
  //for (int i=0; i<nreg; i++)  std::cout << i << " " << regnpp[i] << " " << sh[i] << std::endl;
  ncfile.get_var("npp")->put(sh,nyear,nreg);
  for (int i=0; i<nyear*nreg; i++) sh[i]=lrintf(reggdd[i]);
  ncfile.get_var("gdd")->put(sh,nyear,nreg);
  ncfile.get_var("region_neighbour")->put(regneigh,nn,nreg);
  ncfile.get_var("region_boundary")->put(regboundary,nn,nreg);
  ncfile.get_var("number_of_neighbours")->put(regnn,nreg);
  ncfile.get_var("gridcells")->put(cells,nreg,maxregn);
  
 
  ncc.close();
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
  return std::min(npp_p,npp_t);
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


bool is_var(NcFile* ncfile, std::string varname) {

  int n=ncfile->num_vars();
  NcVar* var;
 
  for (int i=0; i<n; i++) {
    var=ncfile->get_var(i);
    std::string name(var->name());
    if (name==varname) return true;
  }

  std::cerr << "NetCDF file does not contain variable \"" << varname << "\".\n";    
  return false;
}


/** Calculats the boundary length of gridcells at mean latitude
    @return boundary length along great arc
*/
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
