/* GLUES technology effective variable specification; this file is part of
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
   @date   2008-01-16
   @file TechnologyTrait.cc
   @brief Implementation of class TechnologyTrait
*/

#include "EffectiveVariable.h"
#include "TechnologyTrait.h"

double glues::TechnologyTrait::flexibility=0.15;

double glues::TechnologyTrait::initialvalue=1.0;
double glues::TechnologyTrait::InitialValue(const double v) { 
    if (v<minvalue) return initialvalue=minvalue;
    if (v>maxvalue) return initialvalue=maxvalue;
    return initialvalue=v; 
}

glues::TechnologyTrait::TechnologyTrait() {
    value=initialvalue;
}

glues::TechnologyTrait::TechnologyTrait(const double val) 
{
    value=CheckBounds(val);
}


double glues::TechnologyTrait::Gradient(const double g) { return gradient=g; }

double glues::TechnologyTrait::Gradient() const { return gradient; }

    
double glues::TechnologyTrait::Change()
{ 
    return gradient*flexibility;
}

std::ostream& glues::operator<<(std::ostream& os, const glues::TechnologyTrait& t) {
    // return os << t.minvalue << " "  << t.maxvalue <<  " " << t.value << " " << t.flexibility;
    return os << t.value << " " << t.flexibility <<  " "  << t.gradient;
}

double glues::TechnologyTrait::Flexibility(const double f) {
    if (f>0) flexibility=f;
    return flexibility;
}   

double glues::TechnologyTrait::Flexibility() {
    return flexibility;
}

double glues::TechnologyTrait::CheckBounds(const double v) const {
    if (v<minvalue) return minvalue;
    if (v>maxvalue) return maxvalue;
    return v;
}

double glues::TechnologyTrait::MinValue() const {
    return minvalue;
}

double glues::TechnologyTrait::CheckBounds(const double v, const double mi, const double ma) const {
    if (v<mi) return mi;
    if (v>ma) return ma;
    return v;
}
