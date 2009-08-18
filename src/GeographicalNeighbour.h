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

#ifndef geographical_neighbour_h
#define geographical_neighbour_h

#include "Symbols.h"
#include "GeographicalRegion.h"

//namespace glues {

class GeographicalRegion;

/**
 * @class GeographicalNeighbour
 */

class GeographicalNeighbour {
  private:
  	GeographicalRegion* region;
  	double boundarylength;
  	double boundaryease;
  	GeographicalNeighbour* next;
  public:
  	GeographicalNeighbour(GeographicalRegion*,double,double);
  	GeographicalNeighbour();
  	~GeographicalNeighbour();

  	double Length() const {return boundarylength;}
  	double Ease()   const {return boundaryease; }
  	GeographicalRegion* Region() const {return region;}
  	GeographicalNeighbour* Next() const	{return next; }

  	int Add(GeographicalRegion*,double,double);
	friend std::ostream& operator<<(std::ostream& os, GeographicalNeighbour& reg);
};
//}
#endif

/** EOF Neighbour.h */


