/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: MessageHandler.cc,v $
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
//  $Revision: 1.10 $
//  $Date: 1998/07/16 13:54:00 $
//
//  Description
//    This class prints messages to standard outputs and/or to specified
//    files.
//    (For further informations see header file.)
//
//  $Log: MessageHandler.cc,v $
//  Revision 1.10  1998/07/16 13:54:00  reinhard
//  *** empty log message ***
//
//  Revision 1.9  1998/07/16 13:41:11  reinhard
//  SISI_***_PREFIX added.
//
//  Revision 1.8  1998/07/16 13:29:39  reinhard
//  DEBUG_PREFIX, ERROR_PREFIX, INFO_PREFIX and WARNING_PREFIX added.
//
//  Revision 1.7  1998/07/16 13:09:33  reinhard
//  Added some usefull error messages.
//
//  Revision 1.6  1998/07/16 12:57:37  reinhard
//  Bugfix in finalize.
//
//  Revision 1.5  1998/07/09 20:06:11  reinhard
//  Method internalError added.
//
//  Revision 1.4  1998/07/08 07:18:46  reinhard
//  Uses now SUFFIX_OUTPUT, SUFFIX_ERROR and SUFFIX_DEBUG.
//
//  Revision 1.3  1998/06/02 16:41:16  reinhard
//  Method finalize changed.
//
//  Revision 1.2  1998/04/07 10:45:12  kai
//  deleteAllFiles added.
//
//  Revision 1.1  1998/04/07 10:00:52  kai
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////

#include "cppinc.h"
#include "development/MessageHandler.hh"
#include "common/date.hh"

ostream* MessageHandler::_debugFile = NULL;
ostream* MessageHandler::_errorFile = NULL;
ostream* MessageHandler::_infoFile  = NULL;

const char* MessageHandler::SUFFIX_OUTPUT = ".out";
const char* MessageHandler::SUFFIX_ERROR = ".err";
const char* MessageHandler::SUFFIX_DEBUG = ".dbg";

const char* MessageHandler::DEBUG_PREFIX = "::: ";
const char* MessageHandler::ERROR_PREFIX = "*** ";
const char* MessageHandler::INFO_PREFIX = "";
const char* MessageHandler::WARNING_PREFIX = "!!! ";

const char* MessageHandler::SISI_DEBUG_PREFIX = "::: SiSi: ";
const char* MessageHandler::SISI_ERROR_PREFIX = "*** SiSi: ";
const char* MessageHandler::SISI_INFO_PREFIX = "SiSi: ";
const char* MessageHandler::SISI_WARNING_PREFIX = "!!! SiSi: ";

String MessageHandler::_baseFilename   = "messages";
String MessageHandler::_modelPath      = "unknown";

void MessageHandler::setBaseFilename(const char* baseFile) {
  _baseFilename = baseFile;
}
void MessageHandler::setModelPath(const char* modelPath) {
  _modelPath = modelPath;
}
void MessageHandler::deleteAllFiles() {
  remove(_baseFilename + SUFFIX_DEBUG);
  remove(_baseFilename + SUFFIX_ERROR);
  remove(_baseFilename + SUFFIX_OUTPUT);
}
void MessageHandler::finalize() {
  if( _debugFile && _debugFile!=&cout ) {              // _debugFile opened?
    delete _debugFile;
    _debugFile = NULL;
  }
  if( _errorFile && _errorFile!=&cerr ) {              // _errorFile opened?
    delete _errorFile;
    _errorFile = NULL;
  }
  if( _infoFile && _infoFile!=&cout ) {                // _infoFile opened?
    _infoFile = NULL;
    delete _infoFile;
  }
}
void MessageHandler::debug(String msg, const char* prefix) {
  if( !_debugFile ) {                                  // _debugFile opened?
    _debugFile = new ofstream(_baseFilename +
			      SUFFIX_DEBUG);           // Open debug file.
    if( !_debugFile || !_debugFile->good() ) {
      _debugFile = &cout;                              // Open failed.
      error((String) "Could not debug messages to debugfile '" +
	    _baseFilename + SUFFIX_DEBUG + "'!", SISI_ERROR_PREFIX);
    }
    else {                                             // Print header:
      printInformation(*_debugFile, "Debug");
      if( !_debugFile->good() )                        // Printing failed.
	_debugFile = &cout;
    }
  }
  *_debugFile << prefix << msg << endl;
  if( _debugFile != &cout )                            // Additional to cout:
    cout << prefix << msg << endl;
}
void MessageHandler::error(String msg, const char* prefix) {
  if( !_errorFile ) {                                  // _errorFile opened?
    _errorFile = new ofstream(_baseFilename +
			      SUFFIX_ERROR);           // Open error file.
    if( !_errorFile || !_errorFile->good() ) {
      _errorFile = &cerr;                              // Open failed.
      error((String) "Could not write error messages to errorfile '" +
	    _baseFilename + SUFFIX_ERROR + "'!", SISI_ERROR_PREFIX);
    }
    else {                                             // Print header:
      printInformation(*_errorFile, "Error and warning");
      if( !_errorFile->good() )                        // Printing failed.
	_errorFile = &cerr;
    }
  }
  *_errorFile << prefix << msg << endl;
  if( _errorFile != &cerr )                            // Additional to cerr:
    cerr << prefix << msg << endl;
}
void MessageHandler::internalError(String msg, const char* file, long line,
				   const char* version) {

  if( !_errorFile ) {                                  // _errorFile opened?
    _errorFile = new ofstream(_baseFilename +
			      SUFFIX_ERROR);           // Open error file.
    if( !_errorFile || !_errorFile->good() ) {
      _errorFile = &cerr;                              // Open failed.
      error((String) "Could not write error messages to errorfile '" +
	    _baseFilename + SUFFIX_ERROR + "'!", SISI_ERROR_PREFIX);
    }
    else {                                             // Print header:
      printInformation(*_errorFile, "Error and warning");
      if( !_errorFile->good() )                        // Printing failed.
	_errorFile = &cerr;
    }
  }
  *_errorFile << ERROR_PREFIX << "Internal Error in '" << file << "', line "
	      << line << ", version: " << version << " "
	      << ERROR_PREFIX << END_OF_LINE
	      << ERROR_PREFIX << msg << END_OF_LINE;
  if( _errorFile != &cerr )                            // Additional to cerr:
    cerr << ERROR_PREFIX << "Internal Error in '" << file << "', line " << line
	 << ", version: " << version << " " << ERROR_PREFIX << END_OF_LINE
	 << ERROR_PREFIX << msg << END_OF_LINE;
}
void MessageHandler::information(String msg, const char* prefix) {
  if( !_infoFile ) {                                   // _infoFile opened?
    _infoFile = new ofstream(_baseFilename +
			     SUFFIX_OUTPUT);           // Open info file.
    if( !_infoFile || !_infoFile->good() ) {
      _infoFile = &cout;                               // Open failed.
      error((String) "Could not write output messages to outputfile '" +
	    _baseFilename + SUFFIX_OUTPUT + "'!", SISI_ERROR_PREFIX);
    }
    else {                                             // Print header:
      printInformation(*_infoFile, "Information");
      if( !_infoFile->good() )                         // Printing failed.
	_infoFile = &cout;
    }
  }
  *_infoFile << prefix << msg << endl;
  if( _infoFile != &cout )                             // Additional to cout:
    cout << prefix << msg << endl;
}
void MessageHandler::warning(String msg, const char* prefix) {
  error(msg, prefix);
}

void MessageHandler::printInformation(ostream& out, const char* prefix) {
  out << "# " << prefix << " messages for model '"
      << _modelPath << "'." << endl
      << "# Date of creation: " << Date::NowAsString() << endl << endl;
}
