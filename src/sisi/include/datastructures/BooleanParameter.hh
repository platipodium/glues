/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: BooleanParameter.hh,v $
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
//  $Revision: 1.7 $
//  $Date: 1998/03/16 13:21:29 $
//
//  Description
//   Class BooleanParameter derived from class Parameter and manages
//   boolean variables.
//
//  $Log: BooleanParameter.hh,v $
//  Revision 1.7  1998/03/16 13:21:29  kai
//  TwoWayListElement::className is now set.
//
//  Revision 1.6  1998/03/14 17:20:41  kai
//  Read... and print... structure changed.
//
//  Revision 1.5  1998/03/13 10:44:55  reinhard
//  static String getTypeAsString(ParameterType) sustituted by
//  String asString().
//
//  Revision 1.4  1998/03/05 14:15:37  kai
//  prefix in output routines added.
//
//  Revision 1.3  1998/02/20 09:59:01  kai
//  FileParser changed (get->read)!
//
//  Revision 1.2  1998/02/15 10:18:11  kai
//  Destructor with debug message added.
//
//  Revision 1.1  1998/02/14 22:13:38  kai
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _BooleanParameter_hh_
#define _BooleanParameter_hh_

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include "datastructures/Parameter.hh"
#include "datastructures/ParameterType.hh"
#include "iostreams/FileParser.hh"

class BooleanParameter: public Parameter
{
public:
  /** Default constructor. */
  BooleanParameter()
    : Parameter(ParameterType::BOOLEAN) {
      // Protected variable of TwoWayListElement for identification of class:
      className = "BooleanParameter";
  }
  /** Sets the value to given boolean. */
  BooleanParameter(bool value)
    : Parameter(ParameterType::INT) {
      // Protected variable of TwoWayListElement for identification of class:
      className = "BooleanParameter";
      _value = value;
  }
  /** Delete the containing list and give the memory free. */
  ~BooleanParameter() {
#ifdef __DESTRUCTOR_DEBUG__
    cout << "- Destructor for "
	 << ParameterType::BOOLEAN->asString()
	 << " " << getName() << " called.\n";
#endif
  }

  /** Sets the value to the given boolean. */
  void setValue(bool value) { _value = value; }

  /** Returns the value. */
  bool getValue() { return _value; }

  /** Reads the integer value from an opened FileParser. */
  void readValue(FileParser& parser) {
    parser.readBoolean(_value);
  }

  /** Prints the value to the given stream. */
  void printValue(ostream& out, const char* prefix = "") {
    out << prefix;
    if( _value )
      out << "true";
    else
      out << "false";
    out << END_OF_LINE;
  }
private:
  bool _value;
};

#endif // _BooleanParameter_hh_
