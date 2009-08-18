/* GLUES  culture region class; this file is part of
   the Global Land Use and technological Evolution Simulator
   
   Copyright (C) 2001,2002,2003,2004,2005,2006,2007,2008
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
   @file  CulturePopulation.h
   @brief  Declaration  of culture region
   @date 2008-08-21
*/

#include "CultureRegion.h"

glues::CultureRegion::CultureRegion() : LandRegion() {
    population=0;
}

glues::CultureRegion::CultureRegion(std::istream& is) 
    : LandRegion(is),population(NULL) {}

glues::CultureRegion::CultureRegion(const std::string& line ) 
    : LandRegion(line),population(NULL)  {}  

glues::CultureRegion::CultureRegion(const CultureRegion& r) 
    : LandRegion(r) {
    population=r.population;
}

glues::CultureRegion::~CultureRegion() {
    population=0;
}

/* -------------------------------------------------- */
/*     Marks the beginning of "high development"      */
/*
int CultureRegion::CivStart(long tc) {
  int jid,i,j,ncp=0;
  GeographicalNeighbour* neigh;
  double diffdist,difftime,difftot;
  
  neigh=neighbour; //Neighbour();
  civstart = tc;

/* ---------------------------------------------- */
/*    Test for first wordwide occurance           */
/* 
  if(GlobCivStart<0) {
    if(tc<48000) GlobCivStart=tc;
    else GlobCivStart=48000;
    
    if(!VarActive)
      cout << "GlobCivStart at " << GlobCivStart << endl;
  }

/* ------------------------------------------------------- */
/*    Test for first civilization in the neighbourhood     */
/* 
  while (neigh) {
    jid   = neigh->Region()->Id()-0;
    if(regions[jid].CivStart()>0) {
      ncp=1;
      break;
    }
    neigh = neigh->Next();
  }


  difftime=tc-GlobCivStart;
  //   if(VarActive)
  //      RegPerf[id]+=1E3/(1E3+difftime); 
  
  difftime-=1E3*(data_agri_start[0][0]-data_agri_start[civind][0]);
  //   cout<<civind<<" :"<<data_agri_start[civind][0]<<endl;
  
  // Next line commented 2007-04-02, RegPerf not allocated
  // if(VarActive) RegPerf[id]+=TimeEnd-difftime; 
  if(ncp==0) {
    /* ---------------------------------------------------------- */
    /*    Calculates similarity index = inverse deviation from
	  observed global pattern of rising civs             */
    /* ---------------------------------------------------------- */
    /* ------------------------------------- */
    /*             distance error            */
    /* 
    diffdist=CheckDistCenter();
    if(diffdist<0) diffdist=0;
    
    /* -------------------------------------------- */
    /* timing error:                                */
    /*     offset=start of first civ (near east)    */
    /* 
    
    difftot=diffdist*Space2Time+fabs(difftime);
    
    /* -------------------------------------------- */
    /* supposing new hidden center for              */
    /*            "remote" but developed regions    */
    /* 
    if(diffdist>NewCivDist)
      /* --------------------------------------------- */
      /*      sort with respect to deviation values    */
      /* -
      for(i=0;i<=NewCivNum;i++)
	{
	  if(difftot>NewCivDev[i])
       {
       for(j=NewCivNum;j>=i;j--)
         {
         NewCivInd[j+1]=NewCivInd[j];
         NewCivTime[j+1]=NewCivTime[j];
         NewCivDev[j+1]=NewCivDev[j];
         }      
       NewCivInd[i]=id;
       NewCivTime[i]=tc;
       NewCivDev[i]=difftot;
       NewCivNum++;
       i=NewCivNum;
       break;
       }
     }
  else
   {
   GlobDev+=difftot;
   GlobDevNum++;
   OldCivHit[civind]=0;
   if(!VarActive & 0)
     {
     cout <<"Ind. CivStart "<<id<<" at "<<tc<<" near to "<<civind<<"\tw err ";
     cout <<diffdist*Space2Time<<"+"<<difftime<<"\t->"<<GlobDev<< endl;
     }
   }
  //  cout<<id<<" "<<populations[id-1].getCultIndex()<<" "<<populations[id-1].getQfarming()<<endl;

  return 1;
  }
else
  return 0;
}

double CultureRegion::CheckDistCenter() {
  unsigned int i;
  double r,dx,dy,rmin,longl,longr,latd,latu;
  double rad=sqrt(area/PI);
  for(i=0,rmin=9E9;i<RowsOfdata_agri_start;i++) {
    longl=data_agri_start[i][1];
    longr=data_agri_start[i][2];
    latd=data_agri_start[i][3];
    latu=data_agri_start[i][4];
    if(longitude<longl) dx=longl-longitude;
    else
      if(longitude>longr) dx=longitude-longr;
      else dx=0;
    if(latitude<latd) dy=latd-latitude;
    else
      if(latitude>latu) dy=latu-latitude;
      else dy=0;
    r=1-0.5*cos(dy*PI/180)-0.5*cos(dx*PI/180);
    if(r<0) r=0;
    if(r>1) r=1;
    r=2*RADIUS*asin(sqrt(r));
    
    if(r<rmin) rmin=r,civind=i;
  }
  rmin-=rad*0.75;
  return (rmin<0 ? 0:rmin);
}


/** DistanceToCenter calculates the distance to the neareast known c
    center of agriculture given by an external data set
    @param n number of centers
    @param data matrix of centers (time + geo coordinates) 
    @return distance to nearest center in km
*/

double glues::CultureRegion::DistanceToKnownCenters(const unsigned int n, const double** data) {
    double radius,dist,distmin=100000;
    double dx,dy,longl,longr,latd,latu;
    unsigned int i;
    
    radius=sqrt(area/glues::PI); /** radius of this region */
    for (i=0; i<n; i++) {
	longl=data[i][1];
	longr=data[i][2];
	latd=data[i][3];
	latu=data[i][4];
	dx=std::min(fabs(longl-longitude),fabs(longr-longitude));
	dy=std::min(fabs(latu-latitude),fabs(latd-latitude));
	
    
	dist=1-0.5*cos(dy*PI/180)-0.5*cos(dx*PI/180);
	if(dist<0) dist=0;
	else if(dist>1) dist=1;
	dist=2*glues::RADIUS*asin(sqrt(dist));
	if(dist<distmin) {
        distmin=dist;
        //civind=i;
	}
    }
    distmin-=radius*0.75;
    return (distmin<0 ? 0:distmin); 
}

std::ostream& glues::operator<<(std::ostream& os, const glues::CultureRegion& r) {
    return os << (LandRegion)r ;
}

/** EOF CultureRegion.cc */

