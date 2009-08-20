/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: platform.cc,v $	
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
//  $Date: 1998/02/27 09:00:58 $
//
//  Description
//    Some platform dependend code.
//
//  $Log: platform.cc,v $
//  Revision 1.1  1998/02/27 09:00:58  reinhard
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////


#include "cppinc.h"
#include "platform.hh"

#ifdef __UNIX__

const char FILE_SEPARATOR = '/';
const char* END_OF_LINE   = "\n";

/** Please do not call this function! See FilenameHandling for further
 *  information. */
bool FilenameHandling_isAbsolute(const char* path) {
  if( strlen(path) < 1 )
    return false;
  return (path[0] == '/');
}

#else

const char FILE_SEPARATOR = '\\';
const char* END_OF_LINE   = "\r\n";

/** Please do not call this function! See FilenameHandling for further
 *  information. */
bool FilenameHandling_isAbsolute(const char* path) {
  if( strlen(path) < 2 )
    return false;
  return ( path[0]=='\\' || path[0]=='/' ||
	   (isalpha(path[0])&&path[1]==':') );
}

#endif
