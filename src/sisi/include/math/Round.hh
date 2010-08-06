/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: Round.hh,v $	
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
//  $Date: 1998/03/12 16:26:05 $
//
//  Description
//    Some round functions.
//
//  $Log: Round.hh,v $
//  Revision 1.4  1998/03/12 16:26:05  kai
//  Bugfix in doubleToString.
//
//  Revision 1.3  1998/03/12 15:55:47  kai
//  Precision of zero or negative returns x as String ignoring any
//  precision.
//
//  Revision 1.2  1998/03/12 15:26:11  kai
//  doubleToString added and round->doubleToLong.
//
//  Revision 1.1  1998/02/19 14:28:13  kai
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _Round_hh_
#define _Round_hh_

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif
#include "cppinc.h"
#include "datastructures/String.hh"

class Round {
public:
  static long doubleToLong(double x) {
    if(x < 0)
      x-=.5;
    else
      x+=.5;
    return (long) x;
  }

  /** Converts the given double to a String with the given precision
   *  and returns it.
   *  Examples: doubleToString(-1.23456,   3) -> -1.23
   *            doubleToString(-1.2,       3) -> -1.20
   *            doubleToString(-123456,    3) -> -123000
   *            doubleToString(-1.2345E23, 3) -> -1.23E23
   *            doubleToString(5.234,      3) -> 5.23
   *            doubleToString(5.999,      3) -> 6.00
   *            doubleToString(9.999,      3) -> 10.0
   *            doubleToString(99.99,      3) -> 100
   *            doubleToString(599,        3) -> 599
   *            doubleToString(599.5,      3) -> 600
   *            doubleToString(59988.7324, 3) -> 60000
   */
  static String doubleToString(double x, int precision) {
    if( precision<=0 )
      return (String) "" + x;
    String value       = "";
    String exponent    = "";
    String result      = "";
    String tmp         = "";
    String sign        = "";
    int    exponentPos;
    int    pos         = 0;
    int    p           = 0;
    int    l;
    char   c;
    bool   upRound     = true;
    bool   pointRead   = false;

    if( x < 0 ) {
      value = value + (-x);
      sign += '-';
    }
    else
      value = value + x;
    exponentPos = value.indexOf('e');
    if( exponentPos >= 0 ) {
      exponent = value.substring(exponentPos);
      value = value.substring(0,exponentPos);
    }

    l = value.length();
    for( p=0; p<precision; ) {
      if( pos<l )
	c = value.charAt(pos);
      else {
	if( !pointRead ) {
	  tmp += '.';
	  pos++;
	}
	pointRead = true;
	c = '0';
      }
      if( isdigit(c) )
	p++;
      else if( c == '.' )
	pointRead = true;
      pos++;
      tmp += c;
    }
    p = 0;
    while( !pointRead && pos+p < l ) {
      if( (c=value.charAt(pos+p++)) == '.' )
	pointRead = true;
      else {
	tmp += c;
	result += '0';
      }
    }
    l = value.length();
    if( upRound && pos < l ) {
      c = value.charAt(pos);
      if( isdigit(c) ) {
	if( c < '5' )
	  upRound = false;
      }
      else {                    // Point at this position!
	if( pos+1 < l && value.charAt(pos+1) < '5' )
	  upRound = false;
      }
    }
    else
      upRound = false;
    for( p = pos-1; p>=0; --p ) {
      c = tmp.charAt(p);
      if( isdigit(c) && upRound ) {
	if( c == '9' )
	  c = '0';
	else {
	  c++;
	  upRound = false;
	}
      }
      result = (String) "" + c + result;
    }
    if( upRound ) {
      result = (String) "1" + result;
      if( pointRead ) { // Remove last number, if point was read:
	result = result.substring(0, result.length()-1);
	if( result.lastIndexOf('.') == result.length()-1 ) // Ends with '.'?
	  result = result.substring(0, result.length()-1);
      }
    }
    return sign + result + exponent;
  }
};

#endif // _Round_hh_
