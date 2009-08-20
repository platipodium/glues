/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: StringHandler.hh,v $	
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
//  $Revision: 1.2 $
//  $Date: 1998/08/21 21:07:08 $
//
//  Description
//    This class contains some method for testing and handling Strings.
//
//
//  $Log: StringHandler.hh,v $
//  Revision 1.2  1998/08/21 21:07:08  reinhard
//  Method convertToLaTeX added.
//
//  Revision 1.1  1998/06/11 13:09:31  kai
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _StringHandler_hh_
#define _StringHandler_hh_

#include "cppinc.h"
#include "datastructures/String.hh"

class StringHandler {
public:
  ///////////////////////////////////////////////////////////////////////////
  //
  // public static access:
  //
  /** Replaces some special characters by escape sequence understood by
   *  FileParser's method readString. ('"' -> '\"', '\' -> '\\'). //" */
  static String insertEscapeSequences(String s) {
    String tmp = "";
    int p1, p2;
    int n1 = 0;
    int n2 = 0;
    while ( true ) {
      p1 = s.indexOf('\"', n1);             // First occurance or -1. //"
      p2 = s.indexOf('\\', n1);             // First occurance or -1.
      if( p1 < 0 )                               // '"' doesn't occur.
	n2 = p2;
      else if( p2 < 0 )                          // '\' doesn't occur.
	n2 = p1;
      else
	n2 = p1 < p2 ? p1 : p2;                  // Which is the first?
      if( n2 < 0 )                               // No one occur.
	break;
      if( n2 == p1 )                             // '"' is the first.
	tmp += s.substring(n1,n2) + "\\\"";
      else                                       // '\' is the first.
	tmp += s.substring(n1,n2) + "\\\\";
      n1 = n2+1;
    }
    tmp += s.substring(n1);
    return tmp;
  }
  /** Replaces some special characters by LaTeX equivalents.
   *  '_' -> '\_'. */
  static String convertToLaTeX(String s) {
    String tmp = "";
    for( int i=0; i<s.length(); i++ ) {
      switch( s.charAt(i) ) {
      case '_' :
	tmp += "\\_";
	break;
      case '&' :
	tmp += "\\&";
	break;
      case '%' :
	tmp += "\\%";
	break;
      case '#' :
	tmp += "\\#";
	break;
      case '<' :
	if( i<s.length()-1 && !isgraph(s.charAt(i+1)) )
	  tmp += "\\docleft\\ ";
	else
	  tmp += "\\docleft ";
	break;
      case '>' :
	if( i<s.length()-1 && !isgraph(s.charAt(i+1)) )
	  tmp += "\\docright\\ ";
	else
	  tmp += "\\docright ";
	break;
      case '\\' :
	if( i<s.length()-1 && !isgraph(s.charAt(i+1)) )
	  tmp += "\\docbackslash\\ ";
	else
	  tmp += "\\docbackslash ";
	break;
      default:
	tmp += s.charAt(i);
      }
    }
    return tmp;
  }
};

#endif // _StringHandler_hh_
