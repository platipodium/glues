/* GLUES technology effective variable specification; this file is part of
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
   @file TechnologyTrait.cc
   @brief Declaration of class TechnologyTrait
*/

#ifndef glues_technology_trait_h
#define glues_technology_trait_h

#include "EffectiveVariable.h"

namespace glues 
{
    class TechnologyTrait : public EffectiveVariable 
	{
	protected:
	    
	    const static double minvalue=0.5;
	    const static double maxvalue=20.0;
	    static double flexibility;
	    static double initialvalue;
	    
	    double CheckBounds(const double) const;
	    double CheckBounds(const double, const double, const double) const;
	    
	public:
	    TechnologyTrait(); 
	    TechnologyTrait(const double); 
	    	    
	    static double Flexibility(const double);
	    static double InitialValue(const double);
	    double MinValue() const;

	    double Change();
	    double Gradient(const double);
	    double Gradient() const;
	    double Flexibility();
	    friend std::ostream& operator<<(std::ostream& stream, const TechnologyTrait&);
	};

}

#endif
