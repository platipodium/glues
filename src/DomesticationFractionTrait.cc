/* GLUES domestication fraction effective variable specification; this file is part of
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
   @file DomesticationFractionTrait.cc
   @brief Implementation of class DomesticationFractionTrait
*/

#include "EffectiveVariable.h"
#include "DomesticationFractionTrait.h"


/** The default value is
    F_init=0.2 (WL03)
    F_init=0.25 (lbk simulation)
*/
double glues::DomesticationFractionTrait::initialvalue=0.25;

/** The default value is
    0<delta_F<1
    delta_F=1.0 (lbk simulation)
*/
double glues::DomesticationFractionTrait::flexibility=1.0;

double glues::DomesticationFractionTrait::InitialValue(const double v) { 
    if (v<minvalue) return initialvalue=minvalue;
    return initialvalue=v; 
}

glues::DomesticationFractionTrait::DomesticationFractionTrait() 
{ 
    value=initialvalue;
    gradient=0;
}

glues::DomesticationFractionTrait::DomesticationFractionTrait(const double val) 
{
    value=CheckBounds(val);
    gradient=0;
}

double glues::DomesticationFractionTrait::Gradient(const double g) { return gradient=g; }

double glues::DomesticationFractionTrait::Gradient() const { return gradient; }

double glues::DomesticationFractionTrait::Change()
{ 
    return gradient*flexibility;
}

std::ostream& glues::operator<<(std::ostream& os, const glues::DomesticationFractionTrait& t) {
//    return os << t.minvalue << " " << t.maxvalue  << " " << t.value << " " << t.flexibility;
    return os << t.value << " " << t.flexibility  <<  " " << t.gradient;
}

double glues::DomesticationFractionTrait::Flexibility() {
    return flexibility;
}

double glues::DomesticationFractionTrait::Flexibility(const double f) {
    if (f>0) flexibility=f;
    return flexibility;
}   


double glues::DomesticationFractionTrait::CheckBounds(const double v) const {
    if (v<minvalue) return minvalue;
    if (v>maxvalue) return maxvalue;
    return v;
}

double glues::DomesticationFractionTrait::CheckBounds(const double v, const double mi, const double ma) const {
    if (v<mi) return mi;
    if (v>ma) return ma;
    return v;
}
