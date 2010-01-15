/* GLUES population class; this file is part of
   the Global Land Use and technological Evolution Simulator
   
   Copyright (C) 2001,2002,2003,2004,2005,2006,2007,2008,2009
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
   @date   2008-08-21
   @file   Population.h
   @brief  Definition of population
*/

#ifndef glues_population_h
#define glues_population_h

#include "Symbols.h"
#include <iostream>

namespace glues {
    class Population {
    protected:
	double size;          /** Size of population */
	double rgr;           /** relative growth rate */
	double birthrate,deathrate; 

	static double birthcoefficient;
	static double deathcoefficient;
	static double timestep;
	static double initialvalue;

    public:
	Population();
	Population(double);
	Population(std::istream& is);
	~Population();

	static double InitialValue(const double);
	static double BirthCoefficient(const double);
	static double BirthCoefficient() {return birthcoefficient; }
	static double DeathCoefficient(const double);
	static double DeathCoefficient() {return deathcoefficient;}
	static double Timestep() {return timestep;}
	static double Timestep(const double);

	double Birthrate() const {return birthrate;}
	double Deathrate() const {return deathrate;}
	double Growthrate() const {return rgr*size;}
	double Size() const { return size; }

	inline double RelativeGrowthrate() {
	    rgr=birthcoefficient*BirthFunction()-deathcoefficient*DeathFunction()*size;
	    return rgr;
	}
	
 	inline double Grow();
   protected:
	inline double BirthFunction() { return 1.0; }
	inline double DeathFunction() { return 1.0; }
	inline double Change() {
	    return rgr*size*timestep;
	}

    friend std::ostream& glues::operator<<(std::ostream&, const glues::Population&);
	
    };
}

inline double glues::Population::Grow() {

    rgr=RelativeGrowthrate();
    size=size+Change();
 
    if (size<EPS) {
	size=EPS;
    }
    return size;
}

#endif

/** EOF Population.h */



