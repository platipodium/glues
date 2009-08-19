/************************************************************************
 *									
 * @file  GeoRegion.cc
 * @brief Definition of member functions for class GeoRegion
 * @author Carsten Lemmen <c.lemmen@fz-juelich.de>
 * @author Kai Wirtz <wirtz@icbm.de>
 * @date 2002-12-13
 * @date 2006-02-06
 * 
 * This file is part of GLUES, the Global Land Use 
 * and Environmental Change Simulator					 
 *
 ************************************************************************/

#include "GeoRegion.h"

/**
 * @brief Sets a subset of parameters to initial values
 * @param[in] i  Unique id of this region
 * @param[in] a  Area of this region in sqkm
 * @param[in] la Latitude of this region's center
 * @param[in] lo Longitude of this region's center
 * @param[in] ci Continent id of this region
 */
glues::GeoRegion::GeoRegion(unsigned int i,double a,
				       double la, double lo) {
  id = i;
  area = a;
  numneighbours = 0;
  border = 0;
  neighbour.clear();
  //  mapping = 0;
  latitude=la;
  longitude=lo;
  sahara=Sahara();
  continentid=ContinentId();
}

glues::GeoRegion::GeoRegion() {
    id = 0;
    area = 0;
    numneighbours = 0;
    border = 0;
    neighbour.clear();
    //    mapping = 0;
    latitude=0;
    longitude=0;
    sahara=false;
    continentid=0;
    
}

/**
 * @brief Gets region properties from input stream
 * @param[in] Input stream with id, numcells, area, lon, lat fields
 */
glues::GeoRegion::GeoRegion(std::istream& is) {

    static const unsigned int BUFSIZE=1024;
    static char charbuffer[BUFSIZE];
    
    is >> id >> numcells >> area >> longitude >> latitude;

    /*   longitude=x2lon((int)longitude);
	 latitude=x2lat((int)latitude);*/
    
    continentid=ContinentId();
    sahara=Sahara();
    //    mapping = 0;
    
    is.getline(charbuffer,BUFSIZE);
    neighbour.clear();
}

std::vector<glues::GeoNeighbour>& glues::GeoRegion::Neighbours() {
  return neighbour;
}

unsigned int glues::GeoRegion::NumNeighbours() const {
  return (unsigned int) neighbour.size();
}

bool glues::GeoRegion::Sahara() {
  if (longitude>-20 && longitude<51 && latitude<32 && latitude>17) return true;
  else return false;
}

/**
 * @brief Gets region properties from line
 * @param[in] string with id, numcells, area, lon, lat fields
 */
glues::GeoRegion::GeoRegion(const std::string& line)
{
  std::stringstream iss;
  iss << line;

  neighbour.clear();

  iss >> id >> numcells >> area >> longitude >> latitude;
  
  //longitude=x2lon((int)longitude);
  //latitude=x2lat((int)latitude);
  
  sahara=Sahara();
  continentid=ContinentId();

  //mapping = 0;

}

/**
 * @brief Copy constructor
 */
glues::GeoRegion::GeoRegion(const GeoRegion& gr) {
    id = gr.id;
    area = gr.area;
    numneighbours = gr.numneighbours;
    neighbour = gr.neighbour;
    border = gr.border;
    continentid=gr.continentid;
    //    mapping=gr.mapping;
    latitude=gr.latitude;
    longitude=gr.longitude;
    sahara=gr.sahara;
}

/**
 * @brief Ensures the destruction of allocated fields neighbour and mapping
 */
glues::GeoRegion::~GeoRegion(){

  /*
    if (mapping) {
	mapping->~RegionMapping();
	delete mapping;
	}*/
}

/* Implementation section, other Methods */

/**
 * @brief Adds a neighbour 
 * @param[in] reg Pointer to neighbour region to add as neighbour
 * @param[in] bound_length Common boundary length in km
 * @param[in] bound_ease   Ease of boundary 
 * @todo Check whether ease of boundary is used yet
 */

unsigned int glues::GeoRegion::Neighbour(glues::GeoRegion *gr, double length, double ease) {

    std::vector<glues::GeoNeighbour>::iterator it,jt;
    glues::GeoNeighbour gn(gr,length,ease);

    if (*gr==*this) {
	cout << "Region " << id << " cannot be neighbour of itself" << endl;
	return (unsigned int)numneighbours;
    }

    for (it=neighbour.begin() ; it<neighbour.end(); it++) {
	if (*(it->Region())==*gr) {
	    clog << "Region " << it->Region()->Id() << " is already a neighbour" << endl;
	    return (unsigned int)numneighbours;
	}
    }
#ifdef DEBUG
    clog << "Adding to " << id << " neighbour with id " << gr->Id() << endl;
#endif
    neighbour.push_back(gn);
    border=border+length;
    numneighbours=neighbour.size();

    for (it=neighbour.begin() ; it<neighbour.end(); it++) {
	for (jt=it->Region()->Neighbours().begin() ; jt<it->Region()->Neighbours().end(); jt++) {
	    
	    if (*(jt->Region())==*this) {
		clog << "Region " << jt->Region()->Id() << " already has " << id << " as neighbour" << endl;
		return (unsigned int)numneighbours;
	    }
	}
    }
#ifdef DEBUG
    clog << "Adding to neighbour " << gr->Id() << " my id " << id << endl;
#endif
    gr->Neighbour(this,length,ease);
    
    return (unsigned int) numneighbours;
}

double glues::GeoRegion::DistanceTo(const GeoRegion& reg) const {
    double gplat = reg.Latitude();
    double gplon = reg.Longitude();
    double r=1-0.5*cos((latitude-gplat)*PI/180.)-0.5*cos((longitude-gplon)*PI/180.);
    if(r<0) r=0;
    if(r>1) r=1;
    return 2*RADIUS*asin(sqrt(r));
}


std::ostream& glues::operator<<(std::ostream& os, const glues::GeoRegion& gr) {
  return os << gr.id << " " << gr.area << " " 
	    << gr.latitude << " " << gr.longitude << " "
	    << gr.NumNeighbours() << " " <<gr.continentid  << " "
	    << gr.sahara << " " << gr.NewContId() << " "
	    << gr.border ;
}	


/*double glues::GeoRegion::x2lat(unsigned int index) const {
  return 90.0-index/2.0;
}

double glues::GeoRegion::x2lon(unsigned int index) const {
  return index/2.0-180.;
}
*/
/*
int glues::GeoRegion::Mapping(unsigned int num, unsigned int* ids) {

  if (mapping) {
    mapping->~RegionMapping();
    delete mapping;
  }
    
  mapping = new RegionMapping(num,ids);
  return 1;

}
*/

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

unsigned int glues::GeoRegion::ContinentId() {
  
  double la=latitude;
  double lo=longitude;
 
  continentid=7;
  if (la > 18.8 && ( lo > -15 || lo <= -170)) continentid=1;
  if ((la > 18.8 && la < 60) && (lo > -30 & lo<=60)) continentid=1;
  if (la > 0 && lo >  45) continentid=1;
  if ((la > -10 && la < 60) && (lo > 60 && lo <= 120)) continentid=1;
  if (la<=18.8 && (lo > -30 && lo <=60)) continentid=4;
  if (la <15 && lo < -30) continentid=2;
  if (la >15 && (lo < -30 && lo > -170)) continentid=3;
  if (la <10 && lo > 110 && lo <180) continentid=5;
  if (la >60 && lo<-15 && lo >-80) continentid=6;
  return continentid;
}


/**
 * @brief Determines the Old world / new world
 * 
 * Choices are
 * 1 Old World (Eurasia + Africa)
 * 2 New World (Greenland, South + North America)
 * 5 Australia
 * 7 Large Islands
 */
unsigned int glues::GeoRegion::NewContId()  const {
  if(continentid==3 ||continentid==6) return 2;
  if(continentid==4) return 1;
  return continentid;
}


double glues::operator-(const glues::GeoRegion& gr1, const glues::GeoRegion& gr2) {
    return gr1.DistanceTo(gr2);
}

bool glues::operator==(const glues::GeoRegion& gr1, const glues::GeoRegion& gr2) {
    if (gr1.Id()==gr2.Id() && gr1.Latitude()==gr2.Latitude() && gr1.Longitude()==gr1.Longitude()) return true;
    else return false;
}

bool glues::operator!=(const glues::GeoRegion& gr1, const glues::GeoRegion& gr2) {
    return !(gr1==gr2);
}

/** EOF GeoRegion.cc */

