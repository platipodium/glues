/************************************************************************
 *									
 * @file  GeoRegion.h
 * @brief Declaration of class GeoRegion
 * @author Carsten Lemmen <c.lemmen@fz-juelich.de>
 * @author Kai Wirtz <wirtz@icbm.de>
 * @date 2002-12-13
 * 
 * This file is part of GLUES, the Global Land Use 
 * and Environmental Change Simulator					 
 *									
 ************************************************************************/

#ifndef geo_region_h
#define geo_region_h

#include "Symbols.h"
#include <string>
#include <fstream>
#include <vector>
#include <sstream>
#include <cstdio>
#include <cmath>
#include "Constants.h"
#include "GeoNeighbour.h"
//#include "RegionMapping.

//class RegionMapping;

namespace glues {

/**
 * @brief GeoRegion describes an area located on the globe
 */
    class GeoNeighbour;

    class GeoRegion {
    protected:
	unsigned int id;                  /** Unique id of this region */
	std::string name;
	unsigned int numneighbours;       /** Number of neighbour regions */
	unsigned int continentid;             /** Index of continent */
	unsigned int numcells;            /** Number of cells on grid */
	bool sahara;              /** Member of Sahara desert */
       
	double area;                       /** Region area in sqkm */
	double border;             /** Total length of boundary */
	double latitude,longitude;         /** Center coordinates */
	
	//  enum continents = {Eurasia, SouthAmerica, NorthAmerica, Africa, Australia, Greenland, LargeIslands};
	
	/** 
	 * List of neighbours 
	 * @relates GeoNeighbour 
	 */

	std::vector<GeoNeighbour> neighbour;
	
///	RegionMapping* mapping;           
	
 public:
	GeoRegion(unsigned int,double,double,double);
	GeoRegion(std::istream&);
	GeoRegion(std::ifstream&);
	GeoRegion(const std::string&);
	GeoRegion(const GeoRegion&);
	GeoRegion();
	~GeoRegion();
	
	unsigned int Neighbour(GeoRegion *,double,double);

	
	unsigned int Id()         const  { return id; }
	std::string Name()        const  { return name; }
	
	unsigned int NewContId()  const;

	double Area()             const	{ return area;}
	double Length()	         const	{ return border;}
	double Longitude()        const	{ return longitude;}
	double Latitude()	 const  { return latitude;}
//  RegionMapping* Mapping() const  { return mapping;}
	
	std::vector<GeoNeighbour>& Neighbours() ; 
	
        unsigned int NumNeighbours() const;	  
       
	//int ReplaceMapping(unsigned int num,unsigned int* ids);
	//int Mapping(unsigned int num,unsigned int* ids);
  
	double DistanceTo(const GeoRegion& ) const;
    
	//double x2lat(unsigned int) const;
	//double x2lon(unsigned int) const;
	
	const static char* DataHeader();
	char*  DataValues() const;
	
	friend std::ostream& operator<<(std::ostream&,const GeoRegion&);

    private:
	unsigned int ContinentId();
	bool Sahara();
    };

    double operator-(const GeoRegion&,const GeoRegion&);
    bool operator==(const GeoRegion&, const GeoRegion&);
    bool operator!=(const GeoRegion&, const GeoRegion&);
}
#endif

/* EOF GeoRegion.h*/
