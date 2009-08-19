/* GLUES region mapping specification; this file is part of
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
   @date   2008-01-14
   @file GeoMapping.h
   @brief Declaration of class GeoMapping
*/

#ifndef glues_geo_mapping_h
#define glues_geo_mapping_h

#include "Symbols.h"
#include <vector>

namespace glues {

    class GeoMapping {
  
    private:
	unsigned int numcells;
	std::vector<unsigned int> cells;
	unsigned int Geo2Id(double,double) const;
	static double Id2Latitude(unsigned int id) const { return 90.0-(id/720)/2.0; }
	static double Id2Longitude(unsigned int id) const { return (id%720)/2.0-180.; }
	
 public:
	GeoMapping(unsigned int);
	GeoMapping(unsigned int, const std:vector<unsigned int>&);
	/*GeoMapping(unsigned int num, double* lats, double* lons);
	  GeoMapping(char* filename, unsigned int id);*/
	
	unsigned int  Number()  const { return numcells; }
	std::vector<unsigned int>& Cells() const { return cells; }
	unsigned int  CellId(unsigned int id)  const { return cells[id]; }
	std::vector<double>& Latitudes() const;
	std::vector<double>& Longitudes() const;
	//int Assign(unsigned int* ids);
	
	friend std::ostream& operator<<(std::ostream& stream, const GeoMapping&);
    };
}
#endif /* glues_region_mapping_h */
