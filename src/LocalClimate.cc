/* GLUES local climate specification; this file is part of
   the Global Land Use and technological Evolution Simulator
   
   Copyright (C) 2007,2008
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
   @author Kai W Wirtz <kai.wirtz@hzg.de
   @file  LandRegion.h
   @brief Definition of class LocalClimate (before:RegionalCimate)
   @date 2008-08-12
*/

#include "LocalClimate.h"

/** Static variables need to be defined,
    for gdd_opt choose temperate region value,
    this value should be changed set by the SISI:: environment 
*/
double glues::LocalClimate::gdd_opt=0.7; 

void glues::LocalClimate::Init(const double g) { gdd_opt=g; }

glues::LocalClimate::LocalClimate() : lai(0),npp(0),tlim(0) {}

glues::LocalClimate::LocalClimate(double l,double np,double tl) {
    lai = (l > 0 ? l : EPS);
    npp = (np >0 ? np: EPS);
    tlim = tl;
}

std::ostream& glues::operator<<(std::ostream& os,const glues::LocalClimate& lc)
{
    return os << lc.gdd_opt << " " << lc.lai << " " << lc.npp << " " << lc.tlim;
}
