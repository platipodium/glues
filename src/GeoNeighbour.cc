/**************************************************************
 *							      *
 * GLUES					 	      *
 * Global Land-Use and technological Evolution Simulator      *
 *							      *
 * \author Carsten Lemmen <mail@carsten-lemmen.de>	      *
 * \file GeoNeighbour.cc					      *
 *							      *
 * \brief implementation of Methods declared in GeoNeighbour.h   *
 * \date 7.08.2000					      *
 * Class GeoNeighbour is a list of regions & their relationships *
 *							      *
 *************************************************************/

/** PREPROCESSOR section **/

#include "GeoNeighbour.h"

glues::GeoNeighbour::GeoNeighbour() 
    : boundarylength(0),boundaryease(0),region(0) {}

glues::GeoNeighbour::GeoNeighbour(glues::GeoRegion* reg, const double bl, const double e) 
{
    boundarylength=bl;
    boundaryease = e;
    region = reg;
}

glues::GeoNeighbour::~GeoNeighbour() {
    region=0;
}

std::ostream& operator<<(std::ostream& os, const glues::GeoNeighbour& n) {
  return os << "Neighbour ("  << n.Region() << " L=" << n.Length() << "E=," << n.Ease() << ")";
}

/** EOF GeoNeighbour.cc */



