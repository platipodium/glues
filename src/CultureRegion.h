/* GLUES  culture region class; this file is part of
   the Global Land Use and technological Evolution Simulator
   
   Copyright (C) 2001,2002,2003,2004,2005,2006,2007,2008
   Carsten Lemmen <carsten.lemmen@hzg.de>, Kai Wirtz <kai.wirtz@hzg.de>

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
   @author Kai Wirtz <kai.wirtz@hzg.de>
   @file  CulturePopulation.h
   @brief  Declaration  of culture region
   @date 2008-08-21
*/

#ifndef glues_culture_region_h
#define glues_culture_region_h

#include "Symbols.h"
#include "LandRegion.h"
#include <algorithm>

namespace glues {

    class CulturePopulation;

    class CultureRegion : public LandRegion {

    private:
	CulturePopulation* population;
    public:
	CultureRegion();
	CultureRegion(std::istream&);
	CultureRegion(const std::string&);
	CultureRegion(const CultureRegion&);
	~CultureRegion();

	CulturePopulation* Population()	const {return population;}
	
	friend std::ostream& operator<<(std::ostream& os, const CultureRegion& reg);
    
//	double CheckDistCenter();
	double DistanceToKnownCenters(const unsigned int, const double **);
    };
}
#endif 
