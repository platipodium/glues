/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: TwoWayListElement.hh,v $	
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
//  $Revision: 1.9 $
//  $Date: 1998/03/19 09:06:58 $
//
//  Description
//    Contains a list element for the two way list TwoWayList.
//
//  $Log: TwoWayListElement.hh,v $
//  Revision 1.9  1998/03/19 09:06:58  kai
//  const char* getClassName() added.
//
//  Revision 1.8  1998/03/18 13:48:20  reinhard
//  print -> printValue renamed.
//
//  Revision 1.7  1998/03/16 13:56:25  kai
//  virtual bool isFromClass(const char* name) and const char* className
//  added.
//
//  Revision 1.6  1998/03/05 13:35:55  kai
//  Substituted printValue -> print.
//
//  Revision 1.5  1998/02/27 09:03:33  reinhard
//  Borland doesn't own stream.h...
//
//  Revision 1.4  1998/02/19 11:01:45  kai
//  *** empty log message ***
//
//  Revision 1.3  1998/02/15 09:53:09  kai
//  virtual ~TwoWayListElement() added.
//
//  Revision 1.2  1998/02/15 09:08:31  kai
//  virtual printValue(ostream& out) added.
//
//  Revision 1.1  1998/02/13 17:21:12  reinhard
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _TwoWayListElement_hh_
#define _TwoWayListElement_hh_

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include "cppinc.h"

class TwoWayList;

class TwoWayListElement
{
public:
  /** Default constructor. */
  TwoWayListElement()
    : className("TwoWayListElement"), predecessor(0), successor(0)
  { }
  
  virtual ~TwoWayListElement() { }
  /** Print out the value to PrintStream. Prints first the given prefix. */
  virtual void printValue(ostream&, const char* = ""){
    cerr << "*** Internal Error in '" << __FILE__ << "', line " << __LINE__
	 << ", $Revision: 1.9 $ ***\n";
  }
  /** Tests if className is equal to the given name. */
  virtual bool isFromClass(const char* name) {
    return (strcmp(className, name) == 0);
  }
  /** Returns the className. */
  virtual const char* getClassName() {
    return className;
  }

protected:
  /** Compares TwoWayListElement's ID with the given String. */
  virtual bool compareTo(const char*) { return false; }
  /** Compares the class name of the TwoWayListElement with the given
   *  String. */
  const char* className;
private:
  TwoWayListElement* predecessor;
  TwoWayListElement* successor;

  friend class TwoWayList; // Modified by Jan: keyword class added
};

#endif // _TwoWayListElement_hh_
