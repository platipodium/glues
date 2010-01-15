/* GLUES effective variable specification; this file is part of
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
   @date   2008-01-15
   @file EffectiveVariable.cc
   @brief Implementation of class EffectiveVariable.h
*/

#include "EffectiveVariable.h"

double glues::EffectiveVariable::initialvalue=0.5;
double glues::EffectiveVariable::InitialValue(const double v) { initialvalue=v; }

glues::EffectiveVariable::EffectiveVariable() { 
    EffectiveVariable("Unnamed");
}

glues::EffectiveVariable::EffectiveVariable(const std::string& nam) {
    EffectiveVariable(nam,initialvalue);
}

glues::EffectiveVariable::EffectiveVariable(const std::string& nam, const double val) {
    EffectiveVariable(name,val,glues::EPS,1-glues::EPS);
}

glues::EffectiveVariable::EffectiveVariable(const std::string& nam, const double val, const double mi, const double ma)
{
    name.assign(nam);
    minvalue=mi;
    maxvalue=ma;
    value=CheckBounds(val);
}

double glues::EffectiveVariable::Value(const double v) {
    return value=CheckBounds(v);
}

glues::EffectiveVariable& glues::EffectiveVariable::operator=(const EffectiveVariable& ev) {
    return *this;
}

glues::EffectiveVariable& glues::EffectiveVariable::operator+=(const double d) {
    value=CheckBounds(value+=d);
    return *this;
}

namespace glues {
std::ostream& operator<<(std::ostream& os, const EffectiveVariable& ev) {
    return os << ev.name << " " << ev.initialvalue << " " << ev.minvalue << " "
	      << ev.value << " " << ev.maxvalue ;
}
}

double glues::EffectiveVariable::CheckBounds(const double v) const {
    if (v<minvalue) return minvalue;
    if (v>maxvalue) return maxvalue;
    return v;
}

double glues::EffectiveVariable::CheckBounds(const double v, const double mi, const double ma) const {
    if (v<mi) return mi;
    if (v>ma) return ma;
    return v;
}

