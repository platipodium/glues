/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: ResultElement.hh,v $
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
//  $Revision: 1.5 $
//  $Date: 1998/04/16 08:54:45 $
//
//  Description
//    Manages a result entry.
//    A negative precision means to put the value out without any
//    precision changings.
//
//
//  $Log: ResultElement.hh,v $
//  Revision 1.5  1998/04/16 08:54:45  kai
//  Bugfix: Use long instead of int.
//
//  Revision 1.4  1998/04/06 20:22:41  kai
//  Lot of changes (arrays now supported).
//
//  Revision 1.3  1998/03/12 15:53:25  kai
//  DEFAULT_PRECISION added.
//
//  Revision 1.2  1998/03/08 00:27:16  kai
//  *** empty log message ***
//
//  Revision 1.1  1998/03/05 14:22:06  kai
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _ResultElement_hh_
#define _ResultElement_hh_

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif
#include "datastructures/ArrayParameter.hh"
#include "datastructures/FloatParameter.hh"
#include "datastructures/IntParameter.hh"
#include "datastructures/ResultParameter.hh" // For DEFAULT_PRECISION (MAX).
#include "datastructures/String.hh"
#include "twowaylist/TwoWayList.hh"

class ResultElement : public TwoWayListElement
{
public:
  ResultElement();
  /** Constructor for int variable. */
  ResultElement(long* value, IntParameter* par,
		int precision = DEFAULT_PRECISION);
  /** Constructor for float variable. */
  ResultElement(double* value, FloatParameter* par,
		int precision = DEFAULT_PRECISION);
  /** Constructor for one dimensional array from type int. */
  ResultElement(long** array, ArrayParameter* par,
		int precision = DEFAULT_PRECISION);
  /** Constructor for one dimensional array from type float. */
  ResultElement(double** array, ArrayParameter* par,
		int precision = DEFAULT_PRECISION);
  /** Delete the containing array and give the memory free. */
  ~ResultElement();
  String getName();
  void setPrecision(int p);
  Parameter* getHeadParameter();
  void headerOutput(ostream& out);
  void valueOutput(ostream& out);
private:
  Parameter* _headParameter; // Stores informations about containing element.
  union
  {
    long*    _intValue;
    double*  _floatValue;
    long**   _intArray;
    double** _floatArray;
  };
  int       _precision;   // Precision of output.
};

#endif // _ResultElement_hh_
