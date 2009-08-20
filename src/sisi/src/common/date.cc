/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: date.cc,v $	
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
//  $Date: 1998/03/13 15:43:45 $
//
//  Description
//    Some usefull functions for handling dates.
//
//  $Log: date.cc,v $
//  Revision 1.1  1998/03/13 15:43:45  reinhard
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////

#include "common/date.hh"
#include "cppinc.h"

const char DayName  [ 7][4] = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri",
			       "Sat" };
const char MonthName[12][4] = {"Jan", "Feb", "Mar", "Apr", "May", "Jun",
			       "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};

String Date::NowAsString()
{
  String result;
  time_t* clock = new time_t;
  time(clock);
  tm* date = localtime(clock);

  result = (String) DayName[date->tm_wday] + " " + MonthName[date->tm_mon] +
    " ";
  if( date->tm_mday < 10 )
    result += '0';
  result = result + date->tm_mday + " ";
  if( date->tm_hour < 10 )
    result += '0';
  result = result + date->tm_hour + ":";
  if( date->tm_min < 10 )
    result += '0';
  result = result + date->tm_min + ":";
  if( date->tm_sec < 10 )
    result += '0';
  result = result + date->tm_sec + " " + (date->tm_year+1900);

  return result;
}
