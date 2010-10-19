/* GLUES  population class; this file is part of
   the Global Land Use and technological Evolution Simulator
   
   Copyright (C) 2001,2002,2003,2004,2005,2006,2007,2008,2009,2010
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
   @author Kai Wirtz <kai.wirtz@hzg.de>
   @file   Population.cc
   @brief  Implementation of population
*/

#include "Population.h"

glues::Population::Population() : rgr(0),size(glues::EPS) {}
glues::Population::Population(const double s) : rgr(0) {
    if (s>EPS) size=s; 
    else size=EPS;
}

/**
   @todo Implementation of this constructor
*/
glues::Population::Population(std::istream & is) : rgr(0) {}

glues::Population::~Population() {}

double glues::Population::initialvalue=0.1;
double glues::Population::InitialValue(const double v) {
    return initialvalue=v;
}

double glues::Population::timestep=1.0;
double glues::Population::Timestep(const double t) {
    if (timestep>0) timestep=t;
    return timestep;
};

double glues::Population::birthcoefficient=1.0;
double glues::Population::deathcoefficient=1.0;
/*
  double glues::Population::SetCoefficients(const double b,const double d) {
  if (b>0) birthcoefficient=b;
  if (d>0) deathcoefficient=d;
  }
*/

double glues::Population::BirthCoefficient(const double b) {
    if (b>0) birthcoefficient=b;
    return birthcoefficient;
}
double glues::Population::DeathCoefficient(const double d) {
    if (d>0) deathcoefficient=d;
    return deathcoefficient;
}
  
/*

  if (change > RelChange) {
    nnew=ceil(1.0+change/RelChange);
    step=step/nnew;
    cout << "Iterating " << nnew << " times" << endl;
    for (i=0; i<nnew; i++) Develop(step);
    return 0; 
  }
*/

namespace glues {
std::ostream& operator<<(std::ostream& os, const Population& p) {
    return os << p.birthcoefficient << " " << p.deathcoefficient << " "
	      << p.size << " " << p.rgr << " " << p.size*p.rgr ;
}
}
/** EOF Population.cc */


