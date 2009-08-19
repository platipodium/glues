/* GLUES coast declaration; this file is part of
   the Global Land Use and technological Evolution Simulator
   
   Copyright (C) 2007,2008
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
   @date   2008-01-25
   @file Coast.h
   @brief Declaration of class Coast
*/
#ifndef glues_coast_h
#define glues_coast_h

#include "Symbols.h"
#include "GeoRegion.h"
#include "Sea.h"

namespace glues {

    class GeoRegion;
    class SeaRegion;

/**
 * @class Coast
 */

    class Coast {
    private:
	
	GeoRegion& land;
	SeaRegion& sea;
  
	double coastlength;
	double boundaryease;

    public:
  	GeoNeighbour(GeoRegion*,double,double);
  	GeoNeighbour();
  	~GeoNeighbour();
	
  	double Length() const {return boundarylength;}
  	double Ease()   const {return boundaryease; }
  	GeoRegion& Region() const {return region;}

  	int Add(GeoRegion*,double,double);
	friend std::ostream& operator<<(std::ostream& os, GeoNeighbour& reg);
    };
}
#endif
