/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: date.hh,v $	
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
//  $Date: 1998/03/05 14:58:01 $
//
//  Description
//    Some usefull functions for handling dates.
//
//
//  $Log: date.hh,v $
//  Revision 1.1  1998/03/05 14:58:01  kai
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _date_hh_
#define _date_hh_

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include "datastructures/String.hh"

class Date
{
public:
  static String NowAsString(); // Gets the date: "Wed Jun 30 21:49:08 1993"
};
#endif // _date_hh_
