/************************************************************************
 *									
 * @file  GeographicalNeighbour.h
 * @brief Declaration of class GeographicalNeighbour
 * @author Carsten Lemmen <c.lemmen@fz-juelich.de>
 * @author Kai Wirtz <wirtz@icbm.de>
 * @date 2002-12-13
 * 
 * This file is part of GLUES, the Global Land Use 
 * and Environmental Change Simulator					 
 *									
 ************************************************************************/

#ifndef geo_neighbour_h
#define geo_neighbour_h

#include "Symbols.h"
#include "GeoRegion.h"

namespace glues {
  
/**
 * @class GeoNeighbour
 */

    class GeoRegion;

    class GeoNeighbour {
    private:
	GeoRegion* region;
	double boundarylength;
	double boundaryease;
    public:
	GeoNeighbour(GeoRegion*,const double, const double);
	GeoNeighbour();
	~GeoNeighbour();
	
	double Length() const {return boundarylength;}
	double Ease()   const {return boundaryease; }
	GeoRegion* Region() const {return region;}
	
	friend std::ostream& operator<<(std::ostream& os, const GeoNeighbour& reg);
    };
}
#endif

/** EOF GeoNeighbour.h */


