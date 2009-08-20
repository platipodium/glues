/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: LogFile.hh,v $	
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
//  $Revision: 1.7 $
//  $Date: 1998/07/16 13:40:45 $
//
//  Description
//    Writes the logFile and updates the status of progress.
//
//  $Log: LogFile.hh,v $
//  Revision 1.7  1998/07/16 13:40:45  reinhard
//  Useful error message added.
//
//  Revision 1.6  1998/06/11 13:26:08  kai
//  Using now method StringHandler.insertEscapeSequences.
//
//  Revision 1.5  1998/04/09 10:13:53  kai
//  Programm -> Program substituted.
//
//  Revision 1.4  1998/04/07 10:45:51  kai
//  MessageHandler::deleteAllFiles() instead of remove from stdio.h.
//
//  Revision 1.3  1998/03/12 16:03:35  kai
//  round changed to Round::doubleToLong.
//
//  Revision 1.2  1998/03/11 10:59:20  reinhard
//  round.hh moved to math/
//
//  Revision 1.1  1998/03/05 14:23:28  kai
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _LogFile_hh_
#define _LogFile_hh_

#include "cppinc.h"
#include "Version.hh"
#include "common/date.hh"
#include "common/StringHandler.hh"
#include "common/FilenameHandling.hh"
#include "math/Round.hh"
#include "datastructures/String.hh"
#include "development/MessageHandler.hh"

class LogFile
{
public:
  /////////////////////////////////////////////////////
  // Constructors:

  /** Constructor: Don't forget to call initialize!!! */
  LogFile()
    : _progressTime(-1), _progressPercent(0), _initialize(false)
  { }
  /** Initialize with logfile called filename.log and prgname. */
  LogFile(const char* filename, const char* prgname)
    : _progressTime(-1), _progressPercent(0), _initialize(false)
  { (void) initialize(filename, prgname); }

  /////////////////////////////////////////////////////
  // public methods:

  /** Initialize with logfile called filename.log and prgname.
   *  Returns false if an error occurs. */
  bool initialize(const char* filename, const char* prgname) {
    _logFilename = (String) filename + ".log";
    String errFilename = (String) filename + ".err";
    _program   = prgname;
    ofstream file(_logFilename);
    _startTime = Date::NowAsString();
    if( file && file.good() ) {
      _header(file);
      _initialize = true;
      MessageHandler::deleteAllFiles(); // Removes old error and info files.
    }
    else
      MessageHandler::error((String) "Could not write status to logfile '" +
			    _logFilename + "'!",
			    MessageHandler::SISI_ERROR_PREFIX);
    return _initialize;
  }

  /** Writes progress (s/e) to logfile. */
  void progress(double s, double e) {
    if( Round::doubleToLong(s) < _progressTime -1) // changed 28/02/2002 by kw: new run
       { _progressTime = _progressPercent = 0;
       _initialize = true;
  /*      cout << "New progress log \n";   */
        }
    if( // Round::doubleToLong(s) > _progressTime          // Ignore same time.
	// && changed 28/02/2002 by kw
	100*Round::doubleToLong(s)/Round::doubleToLong(e) -
	_progressPercent >= 1// Ignore same percent.
	&& _initialize ) {
      _progressTime = Round::doubleToLong(s);
      _progressPercent = 100*_progressTime/Round::doubleToLong(e);
      ofstream file(_logFilename);
      if( file ) {
	_header(file);
	file << "Progress        \"" << _progressTime << "/"
	     << Round::doubleToLong(e) << " (" << _progressPercent << "%)\""
	     << END_OF_LINE;
      }
    }
  }
  /** Writes "Aborted" to logfile. */
  void abort() {
    if( _initialize ) {
      ofstream file(_logFilename);
      if( file ) {
	_header(file);
	file << "Aborted" << END_OF_LINE;
      }
    }
  }
  /** Writes finishing time to logfile. */
  void finish() {
    if( _initialize ) {
      ofstream file(_logFilename);
      if( file ) {
	_header(file);
	file << "SimulationEnd   \"" << Date::NowAsString() << "\""
	     << END_OF_LINE;
      }
    }
  }
private:
  /////////////////////////////////////////////////////
  // private methods:

  /** Prints header. */
  void _header(ostream& out) {
    out << "# Logfile for simulations written by " << Version::Program
	<< END_OF_LINE
	<< "Program         \""
	<< StringHandler::insertEscapeSequences(_program) << "\""
	<< END_OF_LINE
	<< "SimulationStart \"" << _startTime << "\"" << END_OF_LINE;
  }
  long   _progressTime;              // Time of last progress(...) call.
  long   _progressPercent;           // Percent of last progress(...) call.
  String _logFilename;               // Name of log file.
  String _program;                   // Name of simulation program.
  String _startTime;                 // The time of starting simulation.
  bool   _initialize;                // Is LogFile correctly initialized?
};

#endif // _LogFile_hh_
