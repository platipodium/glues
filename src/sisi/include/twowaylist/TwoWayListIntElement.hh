/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: TwoWayListIntElement.hh,v $	
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
//  $Revision: 1.6 $
//  $Date: 1998/08/21 07:34:30 $
//
//  Description
//    Derived from class TwoWayListElement and contains an integer list
//    element for the two way list TwoWayList.
//
//  $Log: TwoWayListIntElement.hh,v $
//  Revision 1.6  1998/08/21 07:34:30  reinhard
//  Variable className must be set in all constructors!
//
//  Revision 1.5  1998/03/18 13:48:16  reinhard
//  print -> printValue renamed.
//
//  Revision 1.4  1998/03/16 13:22:55  kai
//  TwoWayListElement::className is now set.
//
//  Revision 1.3  1998/03/05 13:37:15  kai
//  Substituted printValue -> print.
//
//  Revision 1.2  1998/02/19 11:27:51  kai
//  *** empty log message ***
//
//  Revision 1.1  1998/02/15 09:09:20  kai
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _TwoWayListIntElement_hh_
#define _TwoWayListIntElement_hh_

#include "twowaylist/TwoWayListElement.hh"

class TwoWayListIntElement: public TwoWayListElement
{
public:
  /** Default constructor. */
  TwoWayListIntElement()
    : _value(0) { 
      // Protected variable of TwoWayListElement for identification of class:
      className = "TwoWayListIntElement";
  }

  /** Initialize. */
  TwoWayListIntElement(long value)
    : _value(value) {
    className = "TwoWayListIntElement";
  }
  /** Returns the value. */
  long getValue() { return _value; }
  /** Sets the value. */
  void setValue(long value) { _value = value; }

  /** Print out the value to PrintStream. Prints first the given prefix. */
  void printValue(ostream& out, const char* prefix = "") {
    out << prefix << _value;
  }

protected:
  /** Returns false (identification not implemented!) */
  bool compareTo(String) {
    return false; // Avoid comparing ListElements.
  }

private:
  long _value;
};

#endif // _TwoWayListIntElement_hh_
