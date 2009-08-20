/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: platform.hh,v $	
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
//  $Revision: 1.3 $
//  $Date: 1998/08/18 10:42:14 $
//
//  Description
//    Some platform dependent definitions
//
//
//  $Log: platform.hh,v $
//  Revision 1.3  1998/08/18 10:42:14  reinhard
//  #  define String SiSi_String added.
//
//  Revision 1.2  1998/08/18 10:27:59  reinhard
//  #define __DOSSISI__ added.
//
//  Revision 1.1  1998/03/13 15:42:13  reinhard
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////


#ifndef _platform_hh_
#define _platform_hh_

// Define bool for older Borland Compiler:

#ifdef __BORLANDC__
#  if __BORLANDC__ < 0x500
     typedef unsigned char bool;
#    define true  ((bool) 1)
#    define false ((bool) 0)
#  endif
#endif

// Next line will be uncomment for DOSSiSi Distribution:
//#define __DOSSISI__

// Uncomment this, if your compiler already defines String:
#ifdef __DOSSISI__
#  define String SiSi_String
#endif

extern const char FILE_SEPARATOR;
extern const char* END_OF_LINE;

/** Please do not call this function! See common/FilenameHandling.hh
 *  for further information. */
extern bool FilenameHandling_isAbsolute(const char* path);

#endif // _platform_hh_
