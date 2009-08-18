/**************************************************************
 *							      *
 * GLUES					 	      *
 * Global Land-Use and technological Evolution Simulator      *
 *							      *
 * \author Carsten Lemmen <mail@carsten-lemmen.de>	      *
 * \file GeographicalNeighbour.cc					      *
 *							      *
 * \brief implementation of Methods declared in GeographicalNeighbour.h   *
 * \date 7.08.2000					      *
 * Class GeographicalNeighbour is a list of regions & their relationships *
 *							      *
 *************************************************************/

/** PREPROCESSOR section **/

#include "GeographicalNeighbour.h"

GeographicalNeighbour::GeographicalNeighbour() {
  boundarylength=0;
  boundaryease = 0;
  region = 0;
  next = 0;
}

GeographicalNeighbour::GeographicalNeighbour(GeographicalRegion* reg, double bl, double e) {
  boundarylength=bl;
  boundaryease = e;
  region = reg;
  next = 0;
}

GeographicalNeighbour::~GeographicalNeighbour() {
  GeographicalNeighbour* tmp;
  while (next) {
    tmp = next->Next();
    delete next;
    next = tmp;
  }
}

int GeographicalNeighbour::Add(GeographicalRegion* reg, double bl, double e) {
  next = new GeographicalNeighbour(reg,bl,e);
  return 1;
}

std::ostream& operator<<(std::ostream& os, GeographicalNeighbour& n) {
  return os << "Neighbour ("  << n.Region() << " L=" << n.Length() << "E=," << n.Ease() << ")";
}

/** EOF GeographicalNeighbour.cc */



