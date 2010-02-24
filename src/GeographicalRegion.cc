/************************************************************************
 *									
 * @file  GeographicalRegion.cc
 * @brief Definition of member functions for class GeographicalRegion
 * @author Carsten Lemmen <c.lemmen@fz-juelich.de>
 * @author Kai Wirtz <wirtz@icbm.de>
 * @date 2002-12-13
 * @date 2006-02-06
 * 
 * This file is part of GLUES, the Global Land Use 
 * and Environmental Change Simulator					 
 *
 ************************************************************************/

#include "GeographicalRegion.h"

/**
 * @brief Sets a subset of parameters to initial values
 * @param[in] i  Unique id of this region
 * @param[in] a  Area of this region in sqkm
 * @param[in] la Latitude of this region's center
 * @param[in] lo Longitude of this region's center
 * @param[in] ci Continent id of this region
 */
GeographicalRegion::GeographicalRegion(unsigned int i,unsigned int ci,float a,
				       float la, float lo) {
  index = 0;
  id = i;
  area = a;
  numneighbours = 0;
  boundarylength = 0;
  neighbour = 0;
  mapping = 0;
  latitude=la;
  longitude=lo;
  if (longitude>-20 && longitude<51 && latitude<32 && latitude>17) sahara=1;
  else sahara=0;
  contind=ci;

}

GeographicalRegion::GeographicalRegion() {
    index = 0;
    id = 0;
    area = 0;
    numneighbours = 0;
    boundarylength = 0;
    neighbour = 0;
    mapping = 0;
    latitude=0;
    longitude=0;
    sahara=0;
    contind=0;
}

/**
 * @brief Gets region properties from input stream
 * @param[in] Input stream with id, numcells, area, lon, lat fields
 */
GeographicalRegion::GeographicalRegion(std::istream& is) {

    static const unsigned int BUFSIZE=1024;
    static char charbuffer[BUFSIZE];

 neighbour=0;
  is >> id >> numcells >> area >> longitude >> latitude;

  longitude=x2lon((int)longitude);
  latitude=x2lat((int)latitude);
  if (longitude>-20 && longitude<51 && latitude<32 && latitude>17) sahara=1;
  else sahara=0;

  ContId(latitude,longitude);
  mapping = 0;


  is.getline(charbuffer,BUFSIZE);
}


/**
 * @brief Gets region properties from line
 * @param[in] string with id, numcells, area, lon, lat fields
 */
GeographicalRegion::GeographicalRegion(const std::string& line)
{
  std::stringstream iss;
  iss << line;

  neighbour=0;

  iss >> id >> numcells >> area >> longitude >> latitude;
  
  longitude=x2lon((int)longitude);
  latitude=x2lat((int)latitude);
  if (longitude>-20 && longitude<51 && latitude<32 && latitude>17) sahara=1;
  else sahara=0;
  
  ContId(latitude,longitude);
  mapping = 0;

  //cout << "GeoRegion " << id << ", Cells " << numcells <<
  // ", Area " << area << " at " << latitude << "?N " <<
  //  longitude << "?E\t" << contind << endl;

}

/**
 * @brief Copy constructor
 */
GeographicalRegion::GeographicalRegion(const GeographicalRegion& gr) {
    index = gr.index; 
    id = gr.id;
    area = gr.area;
    numneighbours = gr.numneighbours;
    neighbour = gr.neighbour;
    boundarylength = gr.boundarylength;
    contind=gr.contind;
    mapping=gr.mapping;
    latitude=gr.latitude;
    longitude=gr.longitude;
    sahara=gr.sahara;
}

/**
 * @brief Ensures the destruction of allocated fields neighbour and mapping
 */
GeographicalRegion::~GeographicalRegion(){
  if (neighbour) {
    neighbour->~GeographicalNeighbour();
    delete [] neighbour;
  }
  if (mapping) {
    mapping->~RegionMapping();
    delete mapping;
  }
}

/* Implementation section, other Methods */

/**
 * @brief Adds a neighbour 
 * @param[in] reg Pointer to neighbour region to add as neighbour
 * @param[in] bound_length Common boundary length in km
 * @param[in] bound_ease   Ease of boundary 
 * @todo Check whether ease of boundary is used yet
 */
int GeographicalRegion::AddNeighbour(GeographicalRegion *reg, float bound_length, float bound_ease) {
  GeographicalNeighbour * n;

  if (!neighbour) neighbour = new GeographicalNeighbour(reg,bound_length,bound_ease);
  else {
    n=neighbour;
    while (n->Next()) n=n->Next();
    n->Add(reg,bound_length,bound_ease);
  }
  boundarylength += bound_length;
  //if(id==-114)
//  cout << "\n...Adding to "<<id<<" as neighbour "<<reg<<" ("<<*reg<<")"<<bound_length;
  return 1;
}

float GeographicalRegion::DistanceTo(const GeographicalRegion& reg) const {
  float gplat = reg.Latitude();
  float gplon = reg.Longitude();
  float r=1-0.5*cos((latitude-gplat)*PI/180)-0.5*cos((longitude-gplon)*PI/180);
  if(r<0) r=0;
  if(r>1) r=1;
  return 2*RADIUS*asin(sqrt(r));
}

float GeographicalRegion::DistancePanAmTo(const GeographicalRegion& reg) const {
  float gplat = reg.Latitude();
  float gplon = reg.Longitude();
  float r=1-0.5*cos((latitude-gplat)*PI/180)-0.5*cos((longitude-gplon)*PI/180);
  if(r<0) r=0;
  if(r>1) r=1;
  return 2*RADIUS*asin(sqrt(r));
}

int GeographicalRegion::Write(FILE* resfile,unsigned int id) const {
  fprintf(resfile,"%3d\t",id);
  return 1;
}

std::ostream& operator<<(std::ostream& os, const GeographicalRegion& reg) {
  return os << "R["  	<< reg.Index() << "] " << reg.Id() << " ("
  	    << "A=" 	<< reg.Area() 
	    << " C=" << reg.Latitude() << "?N " << reg.Longitude() 
	    << "?E N=" << reg.Numneighbours() 
	    << " I=" << reg.ContId() << ")";
}	


float GeographicalRegion::x2lat(unsigned int index) const {
  return 90.0-index/2.0;
}

float GeographicalRegion::x2lon(unsigned int index) const {
  return index/2.0-180.;
}

int GeographicalRegion::Mapping(unsigned int num, unsigned int* ids) {

  if (mapping) {
    mapping->~RegionMapping();
    delete mapping;
  }
    
  mapping = new RegionMapping(num,ids);
  return 1;

}

/**
 * @brief Determines the continent
 * @todo This still needs work
 * 
 * Choices are
 * 1 Eurasia
 * 2 South America
 * 3 North America
 * 4 Africa (subsaharan)
 * 5 Australia
 * 6 Greenland
 * 7 Large Islands
 */
int GeographicalRegion::ContId(float la, float lo) {
  
  contind=7;
  if (la > 18.8 && ( lo > -15 || lo <= -170)) contind=1;
  if ((la > 18.8 && la < 60) && (lo > -30 & lo<=60)) contind=1;
  if (la > 0 && lo >  45) contind=1;
  if ((la > -10 && la < 60) && (lo > 60 && lo <= 120)) contind=1;
  if (la<=18.8 && (lo > -30 && lo <=60)) contind=4;
  if (la <15 && lo < -30) contind=2;
  if (la >15 && (lo < -30 && lo > -170)) contind=3;
  if (la <10 && lo > 110 && lo <180) contind=5;
  if (la >60 && lo<-15 && lo >-80) contind=6;
  return 1;
}

/** EOF GeographicalRegion.cc */

