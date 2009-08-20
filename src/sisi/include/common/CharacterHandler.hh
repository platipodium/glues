/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: CharacterHandler.hh,v $	
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
//  $Date: 1998/04/06 13:15:39 $
//
//  Description
//    This class contains some method for testing and handling Characters.
//
//
//  $Log: CharacterHandler.hh,v $
//  Revision 1.1  1998/04/06 13:15:39  kai
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _CharacterHandler_hh_
#define _CharacterHandler_hh_

#include "cppinc.h"
#include "platform.hh"

class CharacterHandler {
public:
  ///////////////////////////////////////////////////////////////////////////
  //
  // public static access:
  //
  /** Determines if the specified character is permissible as the
   *  first character in a C/C++ identifier. C/C++ identifiers start with a
   *  letter or an underscore. */
  static bool isIdentifierStart(char c) {
    if( c == '_' )
      return true;
    return isalpha(c);
  }
  /** Determines if the specified character may be part of a C/C++
   *  identifier as other than the first character.  C/C++ identifiers
   *  consist of letters, digits (not at start) and/or underscores. */
  static bool isIdentifierPart(char c) {
    if( isIdentifierStart(c) )
      return true;
    return isdigit(c);
  }
  /** Determines if the specified character may be part of a C/C++
   *  specifier (method or variable in a class or struct) as other
   *  than the first character.  C/C++ specifiers consist of letters,
   *  digits (not at start), underscores, '.', "::" and/or "->".<BR>
   *  (e.g. bike::wheel (static method), horse.head, horsepointer->head) */
  static bool isSpecifierPart(char c) {
    if( c=='.' || c==':' || c=='-' || c=='>' )
      return true;
    return isIdentifierPart(c);
  }
};

#endif // _CharacterHandler_hh_
