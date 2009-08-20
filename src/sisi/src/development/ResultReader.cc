/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: ResultReader.cc,v $	
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
//  $Revision: 1.9 $
//  $Date: 1998/07/27 18:56:27 $
//
//  Description
//    ResultReader reads result files.
//
//
//  $Log: ResultReader.cc,v $
//  Revision 1.9  1998/07/27 18:56:27  reinhard
//  Method hasMoreElements added.
//
//  Revision 1.8  1998/07/16 13:54:21  reinhard
//  MessageHandler callings changed.
//
//  Revision 1.7  1998/07/11 13:42:12  kai
//  Method getHeadParameter(const char* name) added.
//
//  Revision 1.6  1998/07/10 10:59:28  reinhard
//  Error message in method getTypeOfColumn added.
//
//  Revision 1.5  1998/07/09 19:29:05  reinhard
//  getNameOfColumn produces now error message if out of range.
//
//  Revision 1.4  1998/07/08 06:12:48  reinhard
//  Method increaseColumnIterators() returns now bool.
//
//  Revision 1.3  1998/07/08 05:40:19  reinhard
//  Method getNameOfColumn added.
//
//  Revision 1.2  1998/06/15 08:10:08  kai
//  Bugfix in readTable.
//
//  Revision 1.1  1998/06/09 10:53:21  kai
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////


#include "development/MessageHandler.hh"
#include "development/ResultReader.hh"


ResultReader::ResultReader(const char* filename)
  : _resultFilename("untitled.res"), _resultTable(NULL) {
  if( filename )
    open(filename);
}
ResultReader::~ResultReader() {
#ifdef __DESTRUCTOR_DEBUG__
  cout << "- Destructor for ResultReader called ..." << END_OF_LINE;
#endif
  if( _resultTable != NULL )
    delete _resultTable;
#ifdef __DESTRUCTOR_DEBUG__
  cout << "- Destructor for ResultReader done." << END_OF_LINE;
#endif
  close();
}

void ResultReader::setFilename(const char* name) { _resultFilename = name; }

String ResultReader::open(const char* filename) {
  String name;
  String s;

  // First: Open the FileParser ...
  if( filename != NULL )
    _resultFilename = filename;
  String message = _resultFile.open(_resultFilename);
  if( message.compareTo("OK") != 0 )
    return message;
  _resultFile.readCommand(s);
  if( s != "table" ) {
    _resultFile.error( "keyword 'table' expected", s);
    return "ERROR";
  }
  return "OK";
}

void ResultReader::close() {
  _resultFile.close();
  _resultFilename = "untitled.res";
}

void ResultReader::readTable() {
  // Read the header of the result table ...
  if( _resultTable != NULL )
    delete _resultTable;
  _resultTable = new TableParameter;
  _resultTable->read(_resultFile);    // Reads the whole table.
  (void) _resultTable->getValue();    // Force reading data from external file,
  //                                     if given (e.g. file "xyz.dat").
  _resultTable->resetColumnIterators();
}

ParameterType* ResultReader::getTypeOfColumn(const char* name) {
  ParameterType* type = _resultTable->getTypeOfColumn(name);
  if( type == ParameterType::UNKNOWN )
    MessageHandler::error((String) "'" + name + "' not found in '" + 
			  _resultFilename + "' or type is unknown!",
			  MessageHandler::SISI_ERROR_PREFIX);
  return type;
}

/** Gets the head parameter. This is usefully for complex containing
 *  types, e.g. arrays for get the dimension and so on. */
Parameter* ResultReader::getHeadParameter(const char* name) {
  Parameter* par = _resultTable->getHeadParameter(name);
  if( par == NULL )
    MessageHandler::error((String) "'" + name + "' not found in '" + 
			  _resultFilename + "'",
			  MessageHandler::SISI_ERROR_PREFIX);
  return par;
}

void ResultReader::resetColumnIterators() {
  _resultTable->resetColumnIterators();
}

bool ResultReader::increaseColumnIterators(){
  return _resultTable->increaseColumnIterators();
}

bool ResultReader::hasMoreElements() {
  return _resultTable->hasMoreElements();
}

TwoWayListElement* ResultReader::getElement(const char* name,
					    ParameterType* type){
  TwoWayListElement* el = _resultTable->getElement(name);
  if( !el )
    MessageHandler::error((String) "'" + name + "' not found in '" + 
			  _resultFilename + "'",
			  MessageHandler::SISI_ERROR_PREFIX);
  else if( type!=NULL && _resultTable->getTypeOfColumn(name) != type ) {
    MessageHandler::error((String) "'" + name + "' isn't from type '" +
			  type->asString() + "' in '" + _resultFilename + "'",
			  MessageHandler::SISI_ERROR_PREFIX);
    el = NULL;
  }
  return el;
}
String ResultReader::getNameOfColumn(int number) {
  String result = _resultTable->getNameOfColumn(number);
  if( result.length() <= 0 )
    MessageHandler::error((String) "Table has less than " + (number+1) +
			  " columns in '" + _resultFilename + "'",
			  MessageHandler::SISI_ERROR_PREFIX);
  return result;
}
