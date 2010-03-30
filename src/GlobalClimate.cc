/* GLUES GlobalClimate implementation; this file is part of
   the Global Land Use and technological Evolution Simulator
   
   Copyright (C) 2008,2009,2010
   Carsten Lemmen <carsten.lemmen@gkss.de>, Kai Wirtz <kai.wirtz@gkss.de>
   
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
   @author Kai Wirtz <kai.wirtz@gkss.de>
   @date   2010-03-30
   @file   GlobalClimate.cc
   @brief  Input and update of climate data
*/

#include "GlobalClimate.h"
#include "Globals.h"
#include "variables.h"
#include <cstdlib>
#include "IO.h"

static double *npp_store;
static double *gdd_store;

GlobalClimate::GlobalClimate(double time) 
{
  timestamp = time;
  climate = new glues::RegionalClimate[numberOfRegions];
//  map = new int[MAPENTRIES];
//  for (unsigned int i=0; i<MAPENTRIES; i++) map[i]=-1;
}

GlobalClimate::~GlobalClimate() {
  if (climate) delete [] climate;
  //if (map) delete [] map;
}


/** 
    Fills the static variables npp_store and gdd_store from files 
 */

int GlobalClimate::InitRead(char* filename) 
{
  char *charoffset,gddname[299];
  //char c;
  //unsigned int regionid=0;
  unsigned int num_up=0,num=0,method=0;
  long unsigned int nrow=0,ncol=0,i=0,j=0;
  double** data;

  //static const unsigned int BUFSIZE=40024;
  //static char charbuffer [BUFSIZE];
  ifstream ififsc,ifs;


  // Read the number of rows, make this stream a separate variable ifsr
  ifstream ifsr;
  ifsr.open(filename,ios::in);
  if (ifsr.bad()) {
    cout << "\nERROR\tTried to open file " << filename << " and failed" << endl;
    return 0;  // The file does not exist
  }
  nrow=glues::IO::count_ascii_rows(ifsr);
  ifsr.close();
  if (nrow < 1) {
      cout << "\nERROR\tFile " << filename << " appears to have 0 rows" << endl;
      return 0;
  }


  // Read the number of columns, make separate stream variable
  std::ifstream ifsc;
  ifsc.open(filename,ios::in);
  if (ifsc.bad()) {
    cout << "\nERROR\tTried to open file " << filename << " and failed" << endl;
    return 0;  
  }
  ncol=glues::IO::count_ascii_columns(ifsc);
  ifsc.close();
  if (ncol < 1) {
      cout << "\nERROR\tFile " << filename << " appears to have 0 columns" << endl;
      return 0;
  }

  // Create data field
  data=(double**)malloc(nrow*sizeof(double*));
  for (i=0; i<nrow; i++) {
      data[i]=(double*)malloc(ncol*sizeof(double));
      for (j=0; j<ncol; j++) data[i][j]=0;
  }

  unsigned long int joffset=0;

  if (nrow==numberOfRegions) {
      // New files with 1 line per region
      joffset = 2;
      method=1;
      num=ncol;
      if (ncol==1)
	  cout << "Using static climate" << endl;
  }
  else if (ncol==numberOfRegions) {
      // Old files with 1 line per climate
      num=nrow;
      if (nrow==1)
	  cout << "Using static climate" << endl;
  }
  else {
      cerr << "\nERROR: number of rows (" << nrow << ") or columns (" << ncol ;
      cerr << ") must match number of regions (" << numberOfRegions << ")\n";
      return 0;
  }
  
  if (npp_store == NULL) npp_store  =new double[numberOfRegions*num];
  if (gdd_store == NULL) gdd_store  =new double[numberOfRegions*num];

  cout << "Read NPP from " << filename;

  ifs.open(filename,ios::in);

  if (method==0) { // old data version nclim rows * nreg columns
      glues::IO::read_ascii_table(ifs,data,0,joffset,0,0);
      for (i=0; i<num; i++) 
	  for (j=0; j<ncol-joffset; j++) {
 	      if (npp_store + j + numberOfRegions*i == NULL)
	      {
		  cerr << "ERROR: Memory not allocated in GlobalClimate::npp_store" << endl;
		  return 0;
	      }
	      npp_store[j+numberOfRegions*i]=data[i][j];
	  }
  }
  else 
  {
      glues::IO::read_ascii_table(ifs,data,0,joffset,0,0);
      for (i=0; i<num; i++) 
	  for (j=0; j<ncol-joffset; j++) {
	      if (npp_store + i + numberOfRegions*j == NULL)
	      {
		  cerr << "ERROR: Memory not allocated in GlobalClimate::npp_store" << endl;
		  return 0;
	      }
	      npp_store[i+numberOfRegions*j]=data[i][j];
	  }
  } 
  ifs.close();
   std::cout << ", found " << nrow << " x " << ncol-joffset << " climates." << std::endl;


  strcpy(gddname,filename);
  charoffset=strstr(gddname,"npp");
  strncpy(charoffset,"gdd",3);

  cout << "Read GDD from " << gddname;

  ifs.open(gddname,ios::in);
  if (ifs.bad()) {
    cout << "\nERROR\tTried to open file " << filename << " and failed" << endl;
    return 0;
  }

  if (method==0) { // old data version nclim rows * nreg columns
      glues::IO::read_ascii_table(ifs,data,0,joffset,0,0);
      for (i=0; i<num; i++) 
	  for (j=0; j<ncol-joffset; j++) {
	      if (gdd_store + j + numberOfRegions*i == NULL)
	      {
		  cerr << "ERROR: Memory not allocated in GlobalClimate::gdd_store" << endl;
		  return 0;
	      }
	      gdd_store[j+numberOfRegions*i]=data[i][j];
	  }
  }
  else 
  {
      glues::IO::read_ascii_table(ifs,data,0,joffset,0,0);
      for (i=0; i<num; i++) 
	  for (j=0; j<ncol-joffset; j++) {
	      if (gdd_store + i + numberOfRegions*j == NULL)
	      {
		  cerr << "ERROR: Memory not allocated in GlobalClimate::gdd_store" << endl;
		  return 0;
	      }
	      gdd_store[i+numberOfRegions*j]=data[i][j];
	  }
  } 
  ifs.close();

  /*for (unsigned int j=numberOfRegions-10; j<numberOfRegions; j++) {
      cout << regions[j].Index() ;
      for (unsigned int i=0; i<num; i++)
	  fprintf(stdout," %f",gdd_store[j+numberOfRegions*i]);
      cout << endl;
      }*/

  std::cout << ", found " << nrow << " x " << ncol-joffset << " climates." << std::endl;
  if ( num < nrow ) {
      std::cout << "Warning: only " << num << " climates used (check ClimateUpdateTimes parameter)" << std::endl;
  }

  return num;
}

int GlobalClimate::UpdateNPP(int r, double npp) {
    climate[r].Npp(npp);
    regions[r].Npp(npp);
return 1;
}

int GlobalClimate::Update(double t) {
    double tl;
	//double tlm=0.65;
    //int tt=0;
	int ci,corrn=-13;
    int   corri[16]={89,55,39,124,85,150,104,114,179,74,73,75,175};
    double corrv[16]={-2,1 ,1 ,-1,-2.7,-1.3,2.7,-1,2 ,-2,6 ,6,2 };

    unsigned long int it;
    
    it=floor(t/ClimUpdateTimes[0]);
    if (it>=ClimUpdateTimes[1]) it=ClimUpdateTimes[1]-1;
    

    for (unsigned int r=0; r<numberOfRegions; r++) {
	
	climate[r].Lai(0);
	for(ci=0;ci<corrn;ci++)
	    if(r==corri[ci])
		break;
	if(ci<corrn)
	{
	    double fac=(1+0.1*corrv[ci]);
	    climate[r].Npp(fac*npp_store[r+it*numberOfRegions]);
	    regions[r].Npp(fac*npp_store[r+it*numberOfRegions]);
//     if(ci==5)
//     printf("%d %d\t%1.2f -> %1.1f %1.3f\n",it,r,fac,
//    fac*npp_store[r+0*numberOfRegions],gdd_store[r+it*numberOfRegions]/365);
	}
	else
	{
	    climate[r].Npp(npp_store[r+it*numberOfRegions]);
	    regions[r].Npp(npp_store[r+it*numberOfRegions]);
//    if(r==1) cout << it<<" NPP[1]="<<npp_store[r+it*numberOfRegions]<<"\t"<<regions[1].Npp()<<endl;
	}
/*   if((ci<corrn && ci>=10) || r==82)
     tl=1.2*gdd_store[r+it*numberOfRegions]/365;
     else
     if(r>=195)
     tl=0.7*gdd_store[r+it*numberOfRegions]/365;
     else
*/
	tl=gdd_store[r+it*numberOfRegions]/365;
/*    tl=(2*tlm-tl)*tl/(tlm*tlm);*/
/*    tl=2*tlm*tl/(tlm*tlm+tl*tl);*/
	climate[r].Tlim(tl);
	regions[r].Tlim(tl);
	
	//   cout << "Update Climate for " << regions[r]<<endl;
  }
    
    /// cout << "Update Climate[" << it << "] for year " << it*ClimUpdateTimes[0]<< endl;
    timestamp=it*ClimUpdateTimes[0];
    //timestamp=4*ClimUpdateTimes[0];
//  cout << "SUCCESS\n";
    return 1;
}

unsigned int GlobalClimate::geo2id(double lat,double lon) const {
    unsigned int dx,dy;
    dx=(unsigned int)((90.-lat)*2.);
    dy=(unsigned int)((lon+180.)*2.);
    return dx*720+dy;
}


/** EOF GlobalClimate.cc */
