/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: ResultWriter.hh,v $	
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
//  $Revision: 1.15 $
//  $Date: 1998/08/18 09:06:37 $
//
//  Description
//    ResultWriter writes the result file automatically for you.
//
//    example:
//      Headerfile:
//        #include "development/ResultWriter.hh" 
//      Declaration:
//        ResultWriter resultWriter;          // Declaration.
//      Initialization:
//        resultWriter.open(SiSi::resultFile);// Opens result file.
//      Usage in simulation function:
//        resultWriter.output(time);          // Puts time step to result file.
//        resultWriter.output(time, true);    // Test outputTimeStep first.
//      Finalization:
//        resultWriter.close();               // Closes result file.
//
//    For additional features the below.
//
//
//  $Log: ResultWriter.hh,v $
//  Revision 1.15  1998/08/18 09:06:37  reinhard
//  Borland has problems with declaration of static members in class definition.
//
//  Revision 1.14  1998/08/11 09:02:57  kai
//  Bugfix: Timestart != 0 produces wrong output time steps.
//  Method setTimeStart added (emit C++ Code must be called for
//  simulations!!!)
//
//  Revision 1.13  1998/07/16 13:40:16  reinhard
//  MessageHandler callings changed.
//
//  Revision 1.12  1998/07/16 10:54:58  reinhard
//  Method setTimeStep added again as deprecated method.
//
//  Revision 1.11  1998/07/16 10:33:45  reinhard
//  Some member variables substituted. Method setTimeStep to setTimeSteps
//  changed.
//
//  Revision 1.10  1998/07/09 18:45:18  reinhard
//  Method setHeaderTable added. _headerTable is now a pointer.
//
//  Revision 1.9  1998/07/01 12:14:18  reinhard
//  Method getStream added.
//
//  Revision 1.8  1998/06/09 10:52:46  kai
//  Writing now header file (*.res) AND data file (*.rsd).
//
//  Revision 1.7  1998/04/16 08:54:48  kai
//  Bugfix: Use long instead of int.
//
//  Revision 1.6  1998/04/08 13:08:22  reinhard
//  output parameter testTimestep -> ignore Timestep changed.
//
//  Revision 1.5  1998/04/06 20:22:35  kai
//  Lot of changes (arrays now supported).
//
//  Revision 1.4  1998/03/08 00:27:53  kai
//  *** empty log message ***
//
//  Revision 1.3  1998/03/05 08:01:46  kai
//  ResultElement moved to ResultElement.*.
//
//  Revision 1.2  1998/03/05 00:32:06  kai
//  Unit added.
//
//  Revision 1.1  1998/02/26 18:13:33  kai
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _ResultWriter_hh_
#define _ResultWriter_hh_

#include "cppinc.h"
#include "platform.hh"
#include "datastructures/ResultParameter.hh" // For DEFAULT_PRECISION (MAX).
#include "datastructures/String.hh"
#include "datastructures/TableParameter.hh"
#include "development/ResultElement.hh"
#include "twowaylist/TwoWayList.hh"


class ResultWriter
{
public:
  static const char SUFFIX_HEADERFILE[];
  static const char SUFFIX_DATAFILE[];
  /** Initialize ResultWriter with a filename.  ResultWriter will write
   *  results to the given file. */
  ResultWriter(const char* filename = NULL);
  /** Initialize ResultWriter with a ostream, for writing to other
   *  ostreams than to ofstream.  ResultWriter(ostream& out); */
  ResultWriter(ostream& out);
  /** NOT realized. */
  ResultWriter(const ResultWriter&);
  ~ResultWriter();

  /** Sets default filename. */
  void setFilename(const char* name);

  /** Gets the actual ostream. Use this function only if you are know
   *  what you are doing. If no ostream is opened, then NULL will be
   *  returned. */
  ostream* getStream() { return _resultFile; }

  /** Open 'filename', return status.  return "OK" or errormessage. */
  String open(const char* filename = NULL );

  /** Close stream. */
  void close();

  /** Sets time start. */
  void setTimeStart(double timeStart);
  /** Sets intervall of outputs. */
  void setTimeStep(double) {
   }

  void setTimeSteps(double timeStep, double outputTimeStep);
  /** Appends resultElement to list. */
  void appendElement(ResultElement* resultElement);
  /** Appends variable with name to list. */
  void appendElement(long& variable, IntParameter* par,
		     int precision = DEFAULT_PRECISION);
  /** Appends variable with name to list. */
  void appendElement(double& value, FloatParameter* par,
		     int precision = DEFAULT_PRECISION);
  /** Appends array from type int with the given length and name to list. */
  void appendElement(long** array, ArrayParameter* par,
		     int precision = DEFAULT_PRECISION);

  /** Appends array from type double with the given length and name to list. */
  void appendElement(double** array, ArrayParameter* par,
		     int precision = DEFAULT_PRECISION);

  /** Puts parameters out, if ignoreTimestep == true or
   *  if time+_timeStep/2 >= _outputTime. */
  void output(double time, bool ignoreTimestep=false);

  /** Overwrites headerTable. Deletes old headerTable. This function is used
   *  by manipdata. */
  void setHeaderTable(TableParameter* table);
  /** This function is deprecated! */

  void getNamelist() {
  ResultElement* el;

      el = (ResultElement*) _outputElements.resetIterator();
      while( el ) {
        MessageHandler::information(el->getName());
	el = (ResultElement*) _outputElements.nextElement();
      }

    }
 
private:
  ostream*              _resultFile;     // Output stream.
  String                _resultFilename; // Name of the actual opened file.
  String                _baseFilename;   // Name of resultfile without suffix.
  double                _timeStep;       // TimeStep of the simulation.
  double                _outputTimeStep; // Intervall of outputs in years.
  double                _outputTime;     // Time of last output.
  TableParameter*       _headerTable;    // All headers of output parameters.
  TwoWayList            _outputElements; // All output parameters.
  bool                  _deleteHeader;   // Delete _headerTable in destructor?
};

#endif // _ResultWriter_hh_
