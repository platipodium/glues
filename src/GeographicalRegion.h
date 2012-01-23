/************************************************************************
 *									
 * @file  GeographicalRegion.h
 * @brief Declaration of class GeographicalRegion
 * @author Carsten Lemmen <c.lemmen@fz-juelich.de>
 * @author Kai Wirtz <wirtz@icbm.de>
 * @date 2002-12-13
 * 
 * This file is part of GLUES, the Global Land Use 
 * and Environmental Change Simulator					 
 *									
 ************************************************************************/

#ifndef geographical_region_h
#define geographical_region_h

#include "Symbols.h"
#include <cstring>
#include <fstream>
#include <sstream>
#include <cstdio>
#include <cmath>
#include "Constants.h"
#include "GeographicalNeighbour.h"
#include "RegionMapping.h"

class GeographicalNeighbour;
class RegionMapping;

//namespace glues {

/**
 * @brief GeographicalRegion describes an area located on the globe
 */
class GeographicalRegion {
 protected:
  unsigned int id;                  /** Unique id of this region */
  unsigned int index;               /** zero based index in vector of regions */
  unsigned int numneighbours;       /** Number of neighbour regions */
  unsigned int contind;             /** Index of continent */
  unsigned int numcells;            /** Number of cells on grid */
  unsigned int sahara;              /** Member of Sahara desert */
  float area;                       /** Region area in sqkm */
  float boundarylength;             /** Total length of boundary */
  float latitude,longitude;         /** Center coordinates */

  //  enum continents = {Eurasia, SouthAmerica, NorthAmerica, Africa, Australia, Greenland, LargeIslands};
 
  /** 
   * List of neighbours 
   * @relates GeographicalNeighbour 
   */
  GeographicalNeighbour* neighbour;
  RegionMapping* mapping;           
	
 public:
  GeographicalRegion(unsigned int,unsigned int,float,float,float);
  GeographicalRegion(std::istream&);
  GeographicalRegion(const std::string&);
  GeographicalRegion(const GeographicalRegion&);
  GeographicalRegion();
  ~GeographicalRegion();
  int AddNeighbour(GeographicalRegion *reg, float bound_length, float bound_ease);
  
  /* Accessor methods to retrieve data */
  unsigned int Index()      const  { return index; }
  unsigned int Id()         const  { return id; }
  unsigned int ContId()     const  { return contind; }
  unsigned int Sahara()     const  { return sahara; }
  unsigned int CellNumber() const  { return numcells; }
  unsigned int Numneighbours()	const {return numneighbours;}
  unsigned int NewContId()  const	
    {
      if(contind==3 ||contind==6) return 2;
      if(contind==4) return 1;
      return contind;
    }
  float Area()             const	{ return area;}
  float Length()	         const	{ return boundarylength;}
  float Longitude()        const	{ return longitude;}
  float Latitude()	 const  { return latitude;}
  RegionMapping* Mapping() const  { return mapping;}
  GeographicalNeighbour* Neighbour() const {return neighbour;}
  
  /* Accessor methods to change data */
  int  Area(float a)	{area = a; return 1; }
  int Length(float l)	{boundarylength = l; return 1; }
  int Numneighbours(int n)   {numneighbours = n; return 1;}
  int ReplaceMapping(unsigned int num,unsigned int* ids);
  int Mapping(unsigned int num,unsigned int* ids);
  int CellNumber(unsigned int num) { numcells=num; return 1; }
  unsigned int Sahara(double,double);
  int Index(unsigned int i) {index = i; return 0;}
  
  /* Further methods */
  float DistanceTo(const GeographicalRegion& ) const ;
  float DistancePanAmTo(const GeographicalRegion& ) const;
  int    Write(FILE* ,unsigned int ) const;
  float x2lat(unsigned int) const;
  float x2lon(unsigned int) const;
  unsigned int lat2x(float) const;
  unsigned int lon2x(float) const;
  
  const static char* DataHeader();
  char*  DataValues() const;
  
  friend std::ostream& operator<<(std::ostream& os,const GeographicalRegion& reg);
 private:
  int ContId(float,float);
  
};
//}
#endif

/* EOF GeographicalRegion.h*/
