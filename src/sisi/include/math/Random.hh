/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: Random.hh,v $	
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
//  $Date: 1998/03/11 15:51:53 $
//
//  Description
//    Contains some functions returning random numbers (e.g. gaussian
//    distributed).
//    The function random::gaussian is derived from the function in
//    Numerical Recipes in Pascal, 1989, S. 225.
//
//
//  $Log: Random.hh,v $
//  Revision 1.1  1998/03/11 15:51:53  reinhard
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _Random_hh_
#define _Random_hh_

#include "cppinc.h"
#include <math.h>

class Random
{
public:
  /** Initialize random generator. */
  static void initialize(unsigned int seed) { srand(seed); }
  /** Returns pseudo random number between 0 and 1. */
  static double number(void) { return (double) rand()/RAND_MAX; }
  /** Returns pseudo random number between min and max. */
  static double number(double min, double max) {
    return (double) rand()/RAND_MAX*(max-min)+min;
  }
  /** Returns pseudo random integer between min and max. */
  static long number(long min, long max) {
    long n;
    do
      n = (long) number( (double) min, (double) max + 1.0 );
    while( n<min || n>max ); // Maybe?! :-)
    return n;
  }
  /** Returns pseudo random numbers which are gaussian distributed with
   *  the mean value mean and standard deviation sd. */
  static double gaussian(double mean, double sd) {
    double fac,r,v1,v2;
    if( !flag ) {                  // We don't have an extra deviate handy, so
      do {
	v1 = number(-1.0,1.0);     // pick two uniform numbers in the
	v2 = number(-1.0,1.0);     // square extending from -1 to 1
	r  = v1*v1 + v2*v2;        // see if they are in the unit circle,
      }
      while( r>1.0 || r<0.0 );     // and if they are not, try again.
      fac = sqrt(-2.0*log(r)/r);   // Now make the Box-Muller transformation to
      buffer = v1*fac;             // get two normal deviates. Return one and 
      flag = 1;                    // save the other for next time.
      return sd*v2*fac + mean;     // Set flag.
    }
    else {
      flag=0;                      // We have an extra deviate handy,
      return sd*buffer + mean;     // so unset the flag and return it.
    }
  }
private:
  static int flag;                 // Have an extra deviate handy?
  static double buffer;            // Save second random number for next time.
};
#endif // _Random_hh_

