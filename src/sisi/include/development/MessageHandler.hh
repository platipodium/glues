/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: MessageHandler.hh,v $
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
//  $Revision: 1.6 $
//  $Date: 1998/07/16 13:41:24 $
//
//  Description
//    This class prints messages to standard outputs and/or to specified
//    files.
//    Usage: MessageHandler.error("Oh dear, ...");
//           MessageHandler.warning((String) "File " + file + " not found!");
//
//  $Log: MessageHandler.hh,v $
//  Revision 1.6  1998/07/16 13:41:24  reinhard
//  SISI_***_PREFIX added.
//
//  Revision 1.5  1998/07/16 13:29:14  reinhard
//  DEBUG_PREFIX, ERROR_PREFIX, INFO_PREFIX and WARNING_PREFIX added.
//
//  Revision 1.4  1998/07/09 20:01:45  reinhard
//  Method internalError added.
//
//  Revision 1.3  1998/07/08 07:18:14  reinhard
//  Method getNameOfErrorFile() added.
//
//    Usage: MessageHandler.error("Oh dear, ...");
//           MessageHandler.warning((String) "File " + file + " not found!");
//
//  $Log: MessageHandler.hh,v $
//  Revision 1.6  1998/07/16 13:41:24  reinhard
//  SISI_***_PREFIX added.
//
//  Revision 1.5  1998/07/16 13:29:14  reinhard
//  DEBUG_PREFIX, ERROR_PREFIX, INFO_PREFIX and WARNING_PREFIX added.
//
//  Revision 1.4  1998/07/09 20:01:45  reinhard
//  Method internalError added.
//
//  Revision 1.3  1998/07/08 07:18:14  reinhard
//  Method getNameOfErrorFile() added.
//
//  Revision 1.2  1998/04/07 10:45:28  kai
//  deleteAllFiles added.
//
//  Revision 1.1  1998/04/07 10:00:45  kai
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _MessageHandler_hh_
#define _MessageHandler_hh_

#include "cppinc.h"
#include "datastructures/String.hh"

class MessageHandler {
public:
  ///////////////////////////////////////////////////////////////////////////
  //
  // public static access:
  //
  static const char* SUFFIX_OUTPUT;
  static const char* SUFFIX_ERROR;
  static const char* SUFFIX_DEBUG;

  static const char* DEBUG_PREFIX;
  static const char* ERROR_PREFIX;
  static const char* INFO_PREFIX;
  static const char* WARNING_PREFIX;

  /** These are only for SiSi's internal usage: */
  static const char* SISI_DEBUG_PREFIX;
  static const char* SISI_ERROR_PREFIX;
  static const char* SISI_INFO_PREFIX;
  static const char* SISI_WARNING_PREFIX;

  /** Sets the path of the base filename (without suffix). The debug, error
   *  and info file will be set to base filename plus suffix. */
  static void setBaseFilename(const char* baseFile);

  /** Sets the path of simulation for information in output files. */
  static void setModelPath(const char* modelPath);

  /** Removes all old message files if exists. Don't forget to set base
   *  filename first! */
  static void deleteAllFiles();

  /** Closes all opened ofstreams. */
  static void finalize();

  /** Prints debug messages to standard output and/or to the debug file. */
  static void debug(String msg, const char* prefix = DEBUG_PREFIX);

  /** Prints error messages to standard error output and/or to error file. */
  static void error(String msg, const char* prefix = ERROR_PREFIX);

  /** Prints internal error messages to standard error output and/or to the
   *  error file. */
  static void internalError(String msg, const char* file, long line,
			    const char* version = "(unknown)");

  /** Prints information messages to standard output or to the information
   *  window. */
  static void information(String msg, const char* prefix = INFO_PREFIX);

  /** Prints warning messages to standard output or to the warning
   *  window. */
  static void warning(String msg, const char* prefix = WARNING_PREFIX);

  /** Returns the name of the errorFile if exists. Otherwise "" will be
   *  returned. */
  static String getNameOfErrorFile() {
    if( _errorFile == NULL && _errorFile != &cerr )
      return "(no errorfile)";
    return _baseFilename + SUFFIX_ERROR;
  }

  ///////////////////////////////////////////////////////////////////////////
  //
  // private static access:
  //
private:
  static void printInformation(ostream& out, const char* prefix);
  static ostream* _debugFile;
  static ostream* _errorFile;
  static ostream* _infoFile;
  static String   _baseFilename;
  static String   _modelPath;
};

#endif // _MessageHandler_hh_
