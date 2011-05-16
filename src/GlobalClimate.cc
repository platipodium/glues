/* GLUES GlobalClimate implementation; this file is part of
   the Global Land Use and technological Evolution Simulator

   Copyright (C) 2008,2009,2010,2011
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
   @author Caleb K Taylor <calebt@users.sourceforge.net>
   @date   2011-02-10
   @file   GlobalClimate.cc
   @brief  Input and update of climate data
*/

#include "GlobalClimate.h"
#include "Globals.h"
#include "variables.h"
#include "IO.h"
#include <fstream>
#include <string>
#include <cassert>
#include <cmath>

static std::vector<double> npp_store;
static std::vector<double> gdd_store;

GlobalClimate::GlobalClimate(double time)
{
  timestamp = time;
  climate.resize( numberOfRegions );
  map.resize( MAPENTRIES, -1 );
}

GlobalClimate::~GlobalClimate() {
}


/**
    @brief Fills the static variables npp_store and gdd_store from files
    @param filename name of file on disk
 */

int GlobalClimate::InitRead(char* filename)
{
  std::string gddname;
  size_t charOffset = 0;

  unsigned int num=0,method=0;
  long unsigned int nrow=0,ncol=0,i=0,j=0;
  std::vector< std::vector<double> > vdata;

  // Read the number of rows
  std::ifstream ifs;
  ifs.open(filename,std::ios::in);
  if (ifs.bad()) {
    cerr << "\nERROR\tTried to open file " << filename << " and failed" << endl;
    return 0;  // The file does not exist
  }
  nrow=glues::IO<void>::count_ascii_rows(ifs);

  if (nrow < 1) {
      cerr << "\nERROR\tFile " << filename << " appears to have 0 rows" << endl;
      return 0;
  }

  // Read the number of columns
  ncol=glues::IO<void>::count_ascii_columns(ifs);
  ifs.close();
  if (ncol < 1) {
      cout << "\nERROR\tFile " << filename << " appears to have 0 columns" << endl;
      return 0;
  }
  std::cerr << "Rows by colums " << nrow << " x " << ncol << std::endl;

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

  if( npp_store.size() == 0 )
  {
      npp_store.resize( numberOfRegions*num );
  }
  if( gdd_store.size() == 0 )
  {
      gdd_store.resize( numberOfRegions*num );
  }

  cout << "Read NPP from " << filename;

  ifs.open(filename,std::ios::in);

  if (method==0) { // old data version nclim rows * nreg columns
      glues::IO<double>::read_ascii_table(ifs,vdata,0,joffset,0,0);
      for( i = 0; i < num; i++ )
      {
          for( j = 0; j < ncol-joffset; j++ )
          {
             // This assumes that npp_store has been adusted to correct size
              npp_store.at(j+numberOfRegions*i) = vdata.at(i).at(j);
          }
      }
  }
  else
  {
      glues::IO<double>::read_ascii_table(ifs,vdata,0,joffset,0,0);
      for( i = 0; i < nrow; i++ )
      {
          for( j = 0; j < ncol-joffset; j++ )
          {
              npp_store.at(i+numberOfRegions*j) = vdata.at(i).at(j);
          }
      }
  }
  ifs.close();
  std::cout << ", found " << nrow << " x " << ncol-joffset << " climates." << std::endl;

  gddname = filename;
  charOffset = gddname.find( "npp", 0 );
  gddname.replace( charOffset, 3, std::string("gdd") );
  cout << "Read GDD from " << gddname;

  ifs.open(gddname.c_str(),std::ios::in);
  if (ifs.bad()) {
    cout << "\nERROR\tTried to open file " << filename << " and failed" << endl;
    return 0;
  }

  if (method==0) { // old data version nclim rows * nreg columns

      glues::IO<double>::read_ascii_table(ifs,vdata,0,joffset,0,0);

      for( i = 0; i < num; i++ )
      {
          for( j = 0; j < ncol-joffset; j++ )
          {
              gdd_store.at(j+numberOfRegions*i) = vdata.at(i).at(j);
          }
      }
  }
  else
  { // new data version nreg rows * nclim columns
      glues::IO<double>::read_ascii_table(ifs,vdata,0,joffset,0,0);

      for( i = 0 ; i < nrow; i++ )
      {
          for( j = 0; j < ncol-joffset; j++ )
          {
              gdd_store.at(i+numberOfRegions*j) = vdata.at(i).at(j);
              //std::cerr << i << " " << num << " " << joffset << " " << j << " " << gdd_store.at(i+numberOfRegions*j)  << std::endl;
          }
      }
  }
  ifs.close();

  std::cout << ", found " << nrow << " x " << ncol-joffset << " climates." << std::endl;
  /*if ( num < nrow ) {
      std::cout << "Warning: only " << num << " climates used (check ClimateUpdateTimes parameter)" << std::endl;
  }*/

/** Establish time axis
// problem with static manner of this fucntion
  timeaxis = new double[num];
  for (int i=0; i<num; i++) {
    timeaxis[i]=TimeStart+(i+0.5)*((TimeEnd-TimeStart)/num);
    cout << timeaxis[i] << " ";
  }

  cout << endl;*/
  return num;
}

int GlobalClimate::UpdateNPP(int r, double npp) {
    assert( climate.size() > 0 );
    assert( r < climate.size() );
    assert( r >= 0 );
    climate.at(r).Npp(npp);
    //Here regions is extern.
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

    it=lrint(floor(t/ClimUpdateTimes[0]));
    if (it>=ClimUpdateTimes[1]) it=ClimUpdateTimes[1]-1;

    for (unsigned int r=0; r<numberOfRegions; r++) {

	climate.at(r).Lai(0);
	for(ci=0;ci<corrn;ci++)
	    if(r==corri[ci])
		break;
	if(ci<corrn)
	{
	    double fac=(1+0.1*corrv[ci]);
	    climate.at(r).Npp(fac * npp_store.at(r+it*numberOfRegions));
	    regions[r].Npp(fac * npp_store.at(r+it*numberOfRegions));
//     if(ci==5)
//     printf("%d %d\t%1.2f -> %1.1f %1.3f\n",it,r,fac,
//    fac*npp_store[r+0*numberOfRegions],gdd_store[r+it*numberOfRegions]/365);
	}
	else
	{
	    climate.at(r).Npp(npp_store.at(r+it*numberOfRegions));
	    //std::cerr << "<<::DEBUG::>> GlobalClimate var: " << r+it*numberOfRegions << endl;
	    //regions[r].Npp(npp_store[r+it*numberOfRegions]);
	    regions[r].Npp(npp_store.at(r+it*numberOfRegions));
//    if(r==1) cout << it<<" NPP[1]="<<npp_store[r+it*numberOfRegions]<<"\t"<<regions[1].Npp()<<endl;
	}
/*   if((ci<corrn && ci>=10) || r==82)
     tl=1.2*gdd_store[r+it*numberOfRegions]/365.0;
     else
     if(r>=195)
     tl=0.7*gdd_store[r+it*numberOfRegions]/365.0;
     else
*/
    climate.at(r).Gdd(gdd_store.at(r+it*numberOfRegions));
	tl = climate.at(r).Gdd()/365;
	climate.at(r).Tlim(tl);
	regions[r].Tlim(tl);

	//   cout << "Update Climate for " << regions[r]<<endl;
  }

    //cout << "Update Climate[" << it << "] for year " << it*ClimUpdateTimes[0] << " / " << t << endl;
    timestamp=it*ClimUpdateTimes[0];
    //timestamp=4*ClimUpdateTimes[0];
    return 1;
}

unsigned int GlobalClimate::geo2id(double lat,double lon) const {
    unsigned int dx,dy;
    dx=(unsigned int)((90.-lat)*2.);
    dy=(unsigned int)((lon+180.)*2.);
    return dx*720+dy;
}

/** EOF GlobalClimate.cc */

