/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: Random.cc,v $	
//
//  Project      SiSi
//               Wissenschaftliches Zentrum fuer
//		 Umweltsystemforschung Kassel
//               Germany
//
//               Umweltforschungszentrum Leipzig
//
//  Author       Kai Reinhard (reinhard@usf.uni-kassel.de)
//               Schoene Aussicht 39, 34317 Habichtswald, Germany
//               email: reinhard@usf.uni-kassel.de
//               URL  : http://www.usf.uni-kassel.de/~reinhard/
//
//  Copyright (C) 1997, 1998 by Kai Reinhard
//
//   This program is free software; you can redistribute it and/or modify
//   it under the terms of the GNU General Public License as published by
//   the Free Software Foundation; either version 2 of the License, or
//   (at your option) any later version.
//
//   This program is distributed in the hope that it will be useful,
//   but WITHOUT ANY WARRANTY; without even the implied warranty of
//   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//   GNU General Public License for more details.
//
//   You should have received a copy of the GNU General Public License
//   along with this program; if not, write to the Free Software
//   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
//
//  $Revision: 1.1 $
//  $Date: 1998/03/11 15:51:59 $
//
//  Description
//    Contains some functions returning random numbers (e.g. gaussian
//    distributed).
//    The function random::gaussian is derived from the function in
//    Numerical Recipes in Pascal, 1989, S. 225.
//
//
//  $Log: Random.cc,v $
//  Revision 1.1  1998/03/11 15:51:59  reinhard
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////


#include "math/Random.hh"

int Random::flag = 0;      // Initialisation (no random number in buffer).
double Random::buffer = 0; // Initialisation needs by compiler.
