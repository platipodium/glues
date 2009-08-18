/************************************************************************
 *									
 * @file  PopulatedRegion.cc
 * @brief Definitions for methods in  class PopulatedRegion
 * @author Carsten Lemmen <c.lemmen@fz-juelich.de>
 * @author Kai Wirtz <wirtz@icbm.de>
 * @date 2002-12-13
 * 
 * This file is part of GLUES, the Global Land Use 
 * and Environmental Change Simulator					 
 *
 ************************************************************************/

/** PREPROCESSOR section **/
#include "PopulatedRegion.h"
#include "Globals.h"
#include "Constants.h"

class GeographicalNeighbour;

/** Implementation section, Constructors and  Destructor **/
/** Vollst?ndiger Konstruktor */
PopulatedRegion::PopulatedRegion() : VegetatedRegion() {
    civstart=0;
    population=0;
}

PopulatedRegion::PopulatedRegion(std::istream& is) 
    : VegetatedRegion(is) {
    civstart=0;
    population=0;
}

PopulatedRegion::PopulatedRegion(const std::string& line) 
    : VegetatedRegion(line) {
    civstart=0;
    population=0;
}

PopulatedRegion::PopulatedRegion(const PopulatedRegion& pr) 
    : VegetatedRegion(pr) {
    civstart=pr.civstart;
    population=pr.population;
}

PopulatedRegion::~PopulatedRegion() {
    delete [] neighbour;
}

/** Implementation section, other Methods **/


/* -------------------------------------------------- */
/*     Marks the beginning of "high development"      */
/* -------------------------------------------------- */
int PopulatedRegion::CivStart(long tc) {
  int jid,i,j,ncp=0;
  GeographicalNeighbour* neigh;
  double diffdist,difftime,difftot;
  
  neigh=neighbour; //Neighbour();
  civstart = tc;

/* ---------------------------------------------- */
/*    Test for first wordwide occurance           */
/* ---------------------------------------------- */
  if(GlobCivStart<0) {
    if(tc<48000) GlobCivStart=tc;
    else GlobCivStart=48000;
    
    if(!VarActive)
      cout << "GlobCivStart at " << GlobCivStart << endl;
  }

/* ------------------------------------------------------- */
/*    Test for first civilization in the neighbourhood     */
/* ------------------------------------------------------- */
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
    /* ------------------------------------- */
    diffdist=CheckDistCenter();
    if(diffdist<0) diffdist=0;
    
    /* -------------------------------------------- */
    /* timing error:                                */
    /*     offset=start of first civ (near east)    */
    /* -------------------------------------------- */
    
    difftot=diffdist*Space2Time+fabs(difftime);
    
    /* -------------------------------------------- */
    /* supposing new hidden center for              */
    /*            "remote" but developed regions    */
    /* -------------------------------------------- */
    if(diffdist>NewCivDist)
      /* --------------------------------------------- */
      /*      sort with respect to deviation values    */
      /* --------------------------------------------- */
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

double PopulatedRegion::CheckDistCenter() {
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

 double PopulatedRegion::DistanceToKnownCenters(unsigned int n, double** data) {
  double radius,dist,distmin=100000;
  double dx,dy,longl,longr,latd,latu;
  unsigned int i;
  
  radius=sqrt(area/PI); /** radius of this region */
  for (i=0; i<n; i++) {
    longl=data[i][1];
    longr=data[i][2];
    latd=data[i][3];
    latu=data[i][4];
    dx=min(abs(longl-longitude),abs(longr-longitude));
    dy=min(abs(latu-latitude),abs(latd-latitude));
    
    
    dist=1-0.5*cos(dy*PI/180)-0.5*cos(dx*PI/180);
    if(dist<0) dist=0;
    else if(dist>1) dist=1;
    dist=2*RADIUS*asin(sqrt(dist));
    if(dist<distmin) {
        distmin=dist;
        civind=i;
    }
  }
  distmin-=radius*0.75;
  return (distmin<0 ? 0:distmin); 
 }


int PopulatedRegion::Write(FILE* resfile,unsigned int id) {
  unsigned int civid;
  double ndompot=ContNdommax()*SuitableSpecies()*SuitableTemp();
  double fert=NatFertility(1.0)*climate.Tlim(),npp=climate.Npp();
  double dist=CheckDistCenter();
  //  npp-=100;
  // if (npp>700 || npp<0) npp=0;
  if(dist<EPS) civid=(8-civind)*20+1;
  else civid=1;
  fprintf(resfile,"%4d %1.2f %1.2f\t%1.1f\t%1.2f %1.2f\n",id,ndompot,fert,npp,climate.Tlim(),ice_fac);
  //fprintf(resfile,"%1.2f\t%1.2f\t",(float)civid,ndompot);
  //fprintf(resfile,"%1.2f\t%1.2f\n",npp,tlim);
  return 0;
}

int PopulatedRegion::Write(FILE* resfile) const {
  fprintf(resfile,"%5d %7.2f %7.2f %8.0f %8.0f %4d %2d %1d\n",id,latitude,longitude,area,boundarylength,numneighbours,contind,sahara);
  return 0;
}

ostream& operator<<(ostream& os, const PopulatedRegion& reg) {
  return os << "R "  	<< reg.Id()
  	    << " (npp=" << reg.Climate().Npp()
  	    << "|T="	<< reg.Climate().Tlim()
  	    << "|A=" 	<< reg.Area() << ")";
}

/** EOF PopulatedRegion.cc */

