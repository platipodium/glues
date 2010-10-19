/* GLUES farmingQuota effective variable specification; this file is part of
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
   @file FarmingQuotaTrait.cc
   @brief Implementation of class FarmingQuotaTrait
*/

#include "EffectiveVariable.h"
#include "FarmingQuotaTrait.h"


double glues::FarmingQuotaTrait::initialvalue=0.01;
double glues::FarmingQuotaTrait::InitialValue(const double v) { 
    if (v<minvalue) return initialvalue=minvalue;
    if (v>maxvalue) return initialvalue=maxvalue;
    return initialvalue=v; 
}

glues::FarmingQuotaTrait::FarmingQuotaTrait() 
      { 
    value=initialvalue;
    gradient=0;
    flexibility=Flexibility();
}

glues::FarmingQuotaTrait::FarmingQuotaTrait(const double val) 
     {
    value=CheckBounds(val);
    flexibility=Flexibility();
    gradient=0;
}

double glues::FarmingQuotaTrait::Gradient(const double g) { return gradient=g; }

double glues::FarmingQuotaTrait::Gradient() const { return gradient; }

double glues::FarmingQuotaTrait::Change()
{ 
    return gradient*Flexibility();
}

std::ostream& glues::operator<<(std::ostream& os, const glues::FarmingQuotaTrait& t) {
//    return os << t.minvalue << " " << t.maxvalue  << " " << t.value << " " << t.flexibility;
    return os << t.value << " " << t.flexibility  <<  " " << t.gradient;
}

double glues::FarmingQuotaTrait::Flexibility() {
    return flexibility=value*(1-value);
}


double glues::FarmingQuotaTrait::CheckBounds(const double v) const {
    if (v<minvalue) return minvalue;
    if (v>maxvalue) return maxvalue;
    return v;
}

double glues::FarmingQuotaTrait::CheckBounds(const double v, const double mi, const double ma) const {
    if (v<mi) return mi;
    if (v>ma) return ma;
    return v;
}
