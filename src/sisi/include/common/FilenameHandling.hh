/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: FilenameHandling.hh,v $	
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
//  $Revision: 1.12 $
//  $Date: 1998/08/18 13:10:00 $
//
//  Description
//    Handling filenames.
//
//  $Log: FilenameHandling.hh,v $
//  Revision 1.12  1998/08/18 13:10:00  reinhard
//  Method convertToPlatform added.
//
//  Revision 1.11  1998/07/01 14:23:43  reinhard
//  Bugfix in getPathWithoutSuffix.
//
//  Revision 1.10  1998/03/13 09:25:22  reinhard
//  Bugfix in getParent.
//
//  Revision 1.9  1998/02/26 15:06:12  kai
//  getPathWithoutSuffix added.
//
//  Revision 1.8  1998/02/26 14:54:29  kai
//  Platform dependend method isAbsolute moved to platform.
//
//  Revision 1.7  1998/02/22 22:41:52  kai
//  *** empty log message ***
//
//  Revision 1.6  1998/02/20 12:09:43  kai
//  getName() adapted to Java's File.getName(...).
//
//  Revision 1.5  1998/02/20 10:11:48  kai
//  isAbsolute adapted to Java's File.isAbsolute(...).
//
//  Revision 1.4  1998/02/20 09:38:55  kai
//  bool isAbsolutePath(const char* path) added.
//
//  Revision 1.3  1998/02/19 10:50:20  kai
//  String getFilenameWithoutSuffix(const char* path) added.
//
//  Revision 1.2  1998/02/15 23:02:32  kai
//  String getFilename(const char* path) added.
//
//  Revision 1.1  1998/02/15 12:42:58  kai
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////

#ifndef __FilenameHandling_hh__
#define __FilenameHandling_hh__

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include "platform.hh"
#include "datastructures/String.hh"

class FilenameHandling
{
public:
  /** Converts a given path to platform specific form by replacing all
   *  file separators '\' and '/' by the platform separator. */
  static String convertToPlatform(const char* path) {
    String result = path;
    if( FILE_SEPARATOR != '\\' )
      result = result.replace('\\', FILE_SEPARATOR);
    if( FILE_SEPARATOR != '/' )
      result = result.replace('/', FILE_SEPARATOR);
    return result;
  }
  /** Get the parent directory of the given path. If no file separator
   *  is given, then '.' will be returned. */
  static String getParent(const char* path) {
    String result = path;
    int pos = result.lastIndexOf(FILE_SEPARATOR);
    if( pos >= 0 )
      result = result.substring( 0, pos );
    else
      result = ".";
    return result;
  }
  /** Returns the name of the file represented by this object. The
   *  name is everything in the pathame after the last occurrence of
   *  the separator character. */
  static String getName(const char* path) {
    String result = path;
    int pos = result.lastIndexOf(FILE_SEPARATOR);
    if( pos >= 0 )
      result = result.substring( pos + 1 );
    return result;
  }
  /** Return the whole path without the suffix. */
  static String getPathWithoutSuffix(const char* path) {
    String result = path;
    int pos = result.lastIndexOf('.');
    if( pos >= 0 && pos > result.lastIndexOf(FILE_SEPARATOR) )
      result = result.substring( 0, pos );
    return result;
  }

  /** Extract the filename from the given path and returns it without
   *  the suffix. */
  static String getNameWithoutSuffix(const char* path) {
    return getPathWithoutSuffix( getName(path) );
  }

  /** Tests if the file represented by this File object is an absolute
   *  pathname. The definition of an absolute pathname is system
   *  dependent. For example, on UNIX, a pathname is absolute if its
   *  first character is the separator character. On Windows
   *  platforms, a pathname is absolute if its first character is an
   *  ASCII '\' or '/', or if it begins with a letter followed by a
   *  colon.
   *
   *  Returns: true if the pathname indicated by the File object is an
   *                absolute pathname;
   *           false otherwise. */
  static bool isAbsolute(const char* path) {
    if( path == NULL )
      return false;
    return FilenameHandling_isAbsolute(path);
  }
};

#endif // __FilenameHandling_hh__
