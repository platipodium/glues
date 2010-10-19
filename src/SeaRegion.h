/* GLUES ocean specification; this file is part of
   the Global Land Use and technological Evolution Simulator
   
   Copyright (C) 2008
   Carsten Lemmen <carsten.lemmen@hzg.de>

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
   @author Carsten Lemmen <carsten.lemmen@hzg.de>
   @date   2008-08-06
   @file SeaRegion.h
   @brief Declaration of class SeaRegion
*/

#ifndef glues_sea_region_h
#define glues_sea_region_h

#include "GeoNeighbour.h"
#include <string>

namespace glues {
    
    class SeaRegion {
	
    private:
	unsigned int numcoasts;
	std::vector<GeoNeighbour> coasts;
	
    public:
    };
}
#endif
