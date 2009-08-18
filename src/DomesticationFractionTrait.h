/* GLUES domestication fraction effective variable specification; this file is part of
   the Global Land Use and technological Evolution Simulator
   
   Copyright (C) 2008
   Carsten Lemmen <carsten.lemmen@gkss.de>

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
   @date   2008-01-16
   @file DomesticationfractionTrait.cc
   @brief Declaration of class DomesticationfractionTrait
*/

#ifndef glues_domestication_fraction_trait_h
#define glues_domestication_fraction_trait_h

#include "EffectiveVariable.h"

namespace glues 
{
    class DomesticationFractionTrait : public EffectiveVariable 
	{
	private:
	    double CheckBounds(const double) const;
	    double CheckBounds(const double, const double, const double) const;
	protected:
	    
	    const static double minvalue=glues::EPS;
	    const static double maxvalue=1-glues::EPS;
	    static double initialvalue;
	    static double flexibility;
	    
	public:
	    DomesticationFractionTrait(); 
	    DomesticationFractionTrait(const double);
	    
	    static double InitialValue(const double);
	    static double Flexibility(const double);

	    double Gradient(const double);
	    double Gradient() const;

	    double Change();
	    double Flexibility();
	    friend std::ostream& operator<<(std::ostream& stream, const DomesticationFractionTrait&);
	};

}

#endif
