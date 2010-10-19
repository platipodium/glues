/* GLUES effective variable specification; this file is part of
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
   @date   2008-01-15
   @file EffectiveVariable.h
   @brief Declaration of abstract class EffectiveVariable.h
*/

#ifndef glues_effective_variable_h
#define glues_effective_variable_h

#include "Symbols.h"
#include <string>
#include <iostream>

namespace glues 
{
    class EffectiveVariable
	{
	    
	protected:
	    double value;
	    double minvalue;
	    double maxvalue;
	    double flexibility;
	    double gradient;
	    static double initialvalue;
	    std::string name;

	    EffectiveVariable(); 
	    EffectiveVariable(const std::string &);
	    EffectiveVariable(const std::string &, const double);
	    EffectiveVariable(const std::string &, const double, const double, const double);
	    
	    double Gradient() const {return gradient;};
	    double Gradient(const double d) {return gradient=d;}
	    
	    virtual ~EffectiveVariable() {}
	    virtual double Flexibility() {return 1;}
	    
	private:
	    virtual double CheckBounds(const double) const;
	    virtual double CheckBounds(const double, const double, const double) const;
	public:
	    static double InitialValue(const double);
	    double Value() const { return value; }
	    virtual double Value(const double);
	    virtual double Change() { return 0;}
	    friend std::ostream& operator<<(std::ostream& stream, const EffectiveVariable&);
	    EffectiveVariable& operator=(const EffectiveVariable&);
	    EffectiveVariable& operator+=(const double);

	    operator const std::string () { return name; }
	    operator const double () { return value; }
	    
	};

 }
#endif

