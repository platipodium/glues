/* GLUES land region specification; this file is part of
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
   @author Kai W Wirtz <kai.wirtz@gkss.de
   @file  LandRegion.h
   @brief Declaration of class LandRegion, based on the prior VegetatedRegion
   @date 2008-08-12
*/

#ifndef glues_land_region_h
#define glues_land_region_h

#include "Symbols.h"
#include <string>
#include "GeoRegion.h"
#include "GeoNeighbour.h"
#include "Continent.h"
#include "LocalClimate.h"
#include "Constants.h"
//#include "variables.h" // for variable kappa and regenerate
//# Globals.h for IceExtent

namespace glues {

    class LandRegion : public GeoRegion {
    protected:
        LocalClimate climate;
        double icefreefraction;
	glues::Continent* continent;
	std::vector<glues::GeoNeighbour> coasts;
	unsigned int numcoasts;
	static double iceextent[4];
	static double nppmaxfep;
 	static double nppmaxlae;
    public:

	LandRegion();
	LandRegion(std::istream&);
	LandRegion(const std::string&);
	LandRegion(const LandRegion&); 
	~LandRegion();

	/** Accessor methods */

	LocalClimate& Climate() {return climate;}
	static double NppMaxLae(const double);
	static double* IceExtent(const double*);
	static double* IceExtent() {return iceextent;}
	double IceFraction() ;
	
	LocalClimate& Climate(const LocalClimate& rc) {climate=rc;}
	LocalClimate& Climate(const double,const double, const double);
        //int  InterpolateClimate(int,int,int,const LocalClimate&,const LocalClimate&);
	
	double SuitableTemperature();
	double SuitableSpecies();
	double NaturalFertility(double);
	double FoodExtractionPotential();
	double LocalSpeciesDiversity();
	
    friend std::ostream& glues::operator<<(std::ostream&, const glues::LandRegion&);
	
    private:
	double hyper(double,double,unsigned int);
    };
}

#endif
