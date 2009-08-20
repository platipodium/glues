/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: ParameterType.hh,v $	
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
//  $Revision: 1.4 $
//  $Date: 1998/03/13 10:52:36 $
//
//  Description
//    Class ParameterType contains following types:
//     UNKNOWN, INT, FLOAT, CHAR, STRING, BOOLEAN, LIST, TABLE AND
//     COMMENT.
//
//  $Log: ParameterType.hh,v $
//  Revision 1.4  1998/03/13 10:52:36  reinhard
//  static String getTypeAsString(ParameterType) sustituted by
//  String asString().
//
//  Revision 1.3  1998/03/05 08:59:25  kai
//  Types RESULT and PARAMETER added.
//
//  Revision 1.2  1998/02/14 22:33:34  kai
//  CHAR and BOOLEAN added.
//
//  Revision 1.1  1998/02/13 17:19:52  reinhard
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _ParameterType_hh_
#define _ParameterType_hh_

#include "datastructures/String.hh"

class ParameterType
{
public:
  ///////////////////////////////////////////////////////////////////////////
  //
  // public static access:
  //
  /** Converts String s to ParamterType. */
  static ParameterType* getStringAsType(String s) {
    if( s.compareTo("int")       == 0 ) return INT;
    if( s.compareTo("float")     == 0 ) return FLOAT;
    if( s.compareTo("char")      == 0 ) return CHAR;
    if( s.compareTo("string")    == 0 ) return STRING;
    if( s.compareTo("boolean")   == 0 ) return BOOLEAN;
    if( s.compareTo("list")      == 0 ) return LIST;
    if( s.compareTo("array")     == 0 ) return ARRAY;
    if( s.compareTo("table")     == 0 ) return TABLE;
    if( s.compareTo("result")    == 0 ) return RESULT;
    if( s.compareTo("comment")   == 0 ) return COMMENT;
    if( s.compareTo("parameter") == 0 ) return PARAMETER;
    return UNKNOWN;
  }
  /** Contains the parameter types. */
  static ParameterType* UNKNOWN;
  static ParameterType* INT;
  static ParameterType* FLOAT;
  static ParameterType* CHAR;
  static ParameterType* STRING;
  static ParameterType* BOOLEAN;
  static ParameterType* LIST;
  static ParameterType* ARRAY;
  static ParameterType* TABLE;
  static ParameterType* RESULT;
  static ParameterType* COMMENT;
  static ParameterType* PARAMETER; // Only for SiSiParser!!!

  ///////////////////////////////////////////////////////////////////////////
  //
  // public access:
  //
  /** Converts ParamterType to String. */
  String asString() {
    switch( _type ) {
    case 1:
      return "int";
    case 2:
      return "float";
    case 3:
      return "char";
    case 4:
      return "string";
    case 5:
      return "boolean";
    case 6:
      return "list";
    case 7:
      return "array";
    case 8:
      return "table";
    case 9:
      return "result";
    case 10:
      return "comment";
    case 11:
      return "parameter";
    default:
      break;
    }
    return "unknown";
  }

private:
  ///////////////////////////////////////////////////////////////////////////
  //
  // private Constructor:
  //
  /** Private Constructor Parameter from parameter type type. */
  ParameterType(short type) {
    _type = type; }

  ///////////////////////////////////////////////////////////////////////////
  //
  // private access:
  //
  short _type;
};

#endif // _ParameterType_hh_
