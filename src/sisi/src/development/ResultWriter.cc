/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: ResultWriter.cc,v $	
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
//  $Revision: 1.16 $
//  $Date: 1998/08/18 09:06:29 $
//
//  Description
//    ResultWriter writes the result file automatically for you.
//    For further information please see the header file result.hh.
//
//
//  $Log: ResultWriter.cc,v $
//  Revision 1.16  1998/08/18 09:06:29  reinhard
//  Borland has problems with declaration of static members in class definition.
//
//  Revision 1.15  1998/08/11 09:02:34  kai
//  Bugfix: Timestart != 0 produces wrong output time steps.
//  Method setTimeStart added (emit C++ Code must be called for
//  simulations!!!)
//
//  Revision 1.14  1998/07/16 13:40:02  reinhard
//  MessageHandler callings changed.
//
//  Revision 1.13  1998/07/16 13:01:38  reinhard
//  Method close shows message.
//
//  Revision 1.12  1998/07/16 10:32:41  reinhard
//  Bugfix pointer _headerTable. Some error messages added. Method setTimeStep to
//  setTimeSteps changed. Method output modified.
//
//  Revision 1.11  1998/07/09 18:45:09  reinhard
//  Method setHeaderTable added. _headerTable is now a pointer.
//
//  Revision 1.10  1998/07/08 06:02:01  reinhard
//  // _resultFile->setf(ios::fixed, ios::floatfield);
//
//  Revision 1.9  1998/07/01 14:25:52  reinhard
//  Some informations in method open added.
//
//  Revision 1.8  1998/06/09 10:52:30  kai
//  Writing now header file (*.res) AND data file (*.rsd).
//
//  Revision 1.7  1998/04/16 08:54:51  kai
//  Bugfix: Use long instead of int.
//
//  Revision 1.6  1998/04/08 13:09:27  reinhard
//  output parameter testTimestep -> ignore Timestep changed.
//
//  Revision 1.5  1998/04/06 20:22:15  kai
//  Lot of changes (arrays now supported).
//
//  Revision 1.4  1998/03/10 07:51:13  kai
//  Adaption to Borland C++ Compiler 4.02.
//
//  Revision 1.3  1998/03/08 00:27:32  kai
//  *** empty log message ***
//
//  Revision 1.2  1998/03/05 08:01:19  kai
//  ResultElement moved to ResultElement.*.
//
//  Revision 1.1  1998/02/26 18:13:25  kai
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////

#include "cppinc.h"
#include "common/FilenameHandling.hh"
#include "development/MessageHandler.hh"
#include "development/ResultWriter.hh"


const char ResultWriter::SUFFIX_HEADERFILE[] = ".res";
const char ResultWriter::SUFFIX_DATAFILE[]   = ".rsd";

ResultWriter::ResultWriter(const char* filename)
  : _resultFile(NULL), _baseFilename("untitled"),
    _timeStep(1), _outputTimeStep(1), _outputTime(0),
    _deleteHeader(true)
{
  _headerTable = new TableParameter;
  if( filename )
    open(filename);
}
ResultWriter::ResultWriter(ostream& out)
  : _resultFile(NULL),
    _timeStep(1), _outputTimeStep(1), _outputTime(0),
    _deleteHeader(true)
{
  _headerTable = new TableParameter;
 _resultFile = &out;
}
ResultWriter::~ResultWriter() {
  close();
  if( _deleteHeader )
    delete _headerTable;
}

void ResultWriter::setFilename(const char* name) {
  _baseFilename = FilenameHandling::getPathWithoutSuffix(name);
}

String ResultWriter::open(const char* filename)
{
  String name;
  String message;
  if( filename == NULL )
    name = _baseFilename + SUFFIX_HEADERFILE;
  else {
    _baseFilename = FilenameHandling::getPathWithoutSuffix(filename);
    name = (String) filename + SUFFIX_HEADERFILE;
  }
  if( _resultFile )             // File schliessen, falls bereits geoffnet.
    close();
  _resultFile = new ofstream(name, ios::out);
  if( !_resultFile || !_resultFile->good() ) {
    message = (String) "Could not open file '" + name + "' as writeable!";
    MessageHandler::error(message, MessageHandler::SISI_ERROR_PREFIX);
    close();
    return message;
  }
  _resultFilename = name;
  MessageHandler::information((String) "Result file '" + name + "' opened.",
			      MessageHandler::SISI_INFO_PREFIX);
  *_resultFile << "table\tResults" << END_OF_LINE;
  _headerTable->setFilename(FilenameHandling::getName(_baseFilename) +
			    SUFFIX_DATAFILE);
  _headerTable->printHeader(*_resultFile);
  if( !_resultFile || !_resultFile->good() ) {
    message = (String) "Error while writing to result file '" + name + "'!";
    MessageHandler::error(message, MessageHandler::SISI_ERROR_PREFIX);
    close();
    return message;
  }
  close();

  name = _baseFilename + SUFFIX_DATAFILE;
  _resultFile = new ofstream(name, ios::out);
  if( !_resultFile || !_resultFile->good() ) {
    message = (String) "Could not open result data file '" + name +
      "' as writeable!";
    MessageHandler::error(message, MessageHandler::SISI_ERROR_PREFIX);
    close();
    return message;
  }
  //  _resultFile->setf(ios::fixed, ios::floatfield);
  _resultFilename = name;
  MessageHandler::information((String) "Result data file '" + name +
			      "' opened.", MessageHandler::SISI_INFO_PREFIX);
  return "OK";
}

void ResultWriter::close()
{
  if(_resultFile) {
    if( _resultFilename.length() > 0 ) {
      MessageHandler::information((String) "Result file '" + _resultFilename +
				  "' closed.",
				  MessageHandler::SISI_INFO_PREFIX);
      _resultFilename = "";
    }
    delete _resultFile;
    _resultFile = NULL;         // Muss explizit Null gesetzt werden.
  }
}

void ResultWriter::setTimeStart(double timeStart) { _outputTime = timeStart; }

void ResultWriter::setTimeSteps(double timeStep, double outputTimeStep) {
  if( timeStep > 0 )
    _timeStep = timeStep;
  else {
    _timeStep = 1;
    MessageHandler::error((String) "ResultWriter: Timestep of simulation " +
			  "must be greater than zero (setting " + timeStep +
			  " to zero)!", MessageHandler::SISI_ERROR_PREFIX);
  }
  if( outputTimeStep > 0 )
    _outputTimeStep = outputTimeStep;
  else {
    _outputTimeStep = 1;
    MessageHandler::error((String) "ResultWriter: Timestep of output must " +
			  "be greater than zero (setting " + outputTimeStep +
			  " to zero)!", MessageHandler::SISI_ERROR_PREFIX);
  }
}
void ResultWriter::appendElement(ResultElement* resultElement) {
  _outputElements.appendElement(resultElement);
  _headerTable->appendColumnHeader(resultElement->getHeadParameter());
}

void ResultWriter::appendElement(long& value, IntParameter* par,
				 int precision)
{
  ResultElement* el;
  el = new ResultElement(&value, par, precision);
  _outputElements.appendElement(el);
  _headerTable->appendColumnHeader(par);
}
void ResultWriter::appendElement(double& value, FloatParameter* par,
				 int precision)
{
  ResultElement* el;
  el = new ResultElement(&value, par, precision);
  _outputElements.appendElement(el);
  _headerTable->appendColumnHeader(par);
}

void ResultWriter::appendElement(long** array, ArrayParameter* par,
				 int precision)
{
  ResultElement* el;
  el = new ResultElement(array, par, precision);
  _outputElements.appendElement(el);
  _headerTable->appendColumnHeader(par);
}

void ResultWriter::appendElement(double** array, ArrayParameter* par,
				 int precision)
{
  ResultElement* el;
  el = new ResultElement(array, par, precision);
  _outputElements.appendElement(el);
  _headerTable->appendColumnHeader(par);
}

void ResultWriter::output(double time, bool ignoreTimestep)
{
  if( _resultFile )
    if( ignoreTimestep || time + _timeStep/2 >= _outputTime ) {
      _outputTime += _outputTimeStep;
      ResultElement* el = NULL;
      el = (ResultElement*) _outputElements.resetIterator();
      while( el ) {
	*_resultFile << "\t";
	el->valueOutput(*_resultFile);
	el = (ResultElement*) _outputElements.nextElement();
      }
      *_resultFile << END_OF_LINE;
      if( !_resultFile || !_resultFile->good() ) {
	MessageHandler::error((String) "Error while writing to result data " +
			      "file '" + _baseFilename + SUFFIX_DATAFILE +
			      "'!", MessageHandler::SISI_ERROR_PREFIX);
	close();
      }
    }
}
void ResultWriter::setHeaderTable(TableParameter* table) {
  if( _headerTable != NULL )
    delete _headerTable;
  _headerTable = table;
  _deleteHeader = false;
}
