/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: SiSiParser.cc,v $	
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
//  $Date: 1998/08/18 12:48:04 $
//
//  Description
//   This class parses SiSi (parameter) files and stores
//   the parameters into a TwoWayList. It uses the FileParser.
//
//
//  $Log: SiSiParser.cc,v $
//  Revision 1.6  1998/08/18 12:48:04  reinhard
//  Bugfix with absolute filenames.
//
//  Revision 1.5  1998/03/18 13:13:15  reinhard
//  Now using the static function Parameter::newParameter( type ).
//
//  Revision 1.4  1998/03/14 15:55:24  kai
//  Parameter::readFromFileParser -> Parameter::read
//
//  Revision 1.3  1998/03/13 17:31:56  reinhard
//  Table now available.
//
//  Revision 1.2  1998/03/13 17:17:11  reinhard
//  includeFiles is now pointer to TwoWayList.
//
//  Revision 1.1  1998/03/05 14:56:11  kai
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////

#include "cppinc.h"
#include "platform.hh"
#include "common/FilenameHandling.hh"
#include "datastructures/ListParameter.hh"
#include "iostreams/FileParser.hh"
#include "iostreams/SiSiParser.hh"
#include "twowaylist/TwoWayListStringElement.hh"


String SiSiParser::parseSimulation(TwoWayList& list, const char* filename) {
  String path = FilenameHandling::getParent(filename);
  String file;
  FileParser parser;
  TwoWayList* includeFiles;
  Parameter* par = NULL;
  TwoWayListStringElement* el = NULL;
  cerr << filename << endl; 
  String message = parser.open(filename);
  if( message.compareTo("OK") != 0 )
    return message;
  message = read(list, parser);
  if( message.compareTo("OK") != 0 )
    return message;
  par = (Parameter*) list.getElement("IncludeFiles");
  if( par!=NULL && par->getType()==ParameterType::LIST )
    if( ((ListParameter*) par)->getTypeOfElements()==ParameterType::STRING )
      includeFiles = ((ListParameter*) par)->getValue();
    else
      return "The list \"IncludeFiles\" doesn't contain strings!\n";
  else
    return "Cannot find \"list IncludeFiles\"!\n";
  
  el = (TwoWayListStringElement*) includeFiles->resetIterator();
  while( el != NULL ) {
    file = el->getValue();
    if( !FilenameHandling::isAbsolute(file) )
      file = path + FILE_SEPARATOR + file;
    message = parser.open(file);
    if( message.compareTo("OK") != 0 )
      return message;
    message = read(list, parser);
    if( message.compareTo("OK") != 0 )
      return message;
    el = (TwoWayListStringElement*) includeFiles->nextElement();
  }
  
  return "OK";
}

String SiSiParser::parseFile(TwoWayList& list, const char* filename) {
  FileParser parser;
  String message = parser.open(filename);
  if( message.compareTo("OK") != 0 )
    return message;
  return read(list, parser);
}

Parameter* SiSiParser::parseParameter(FileParser& parser) {
  Parameter* el = NULL;
  ParameterType* type = NULL;
  String s;
  if( parser.readCommand(s) && s.length() > 0 ) {
#ifdef __SISSIPARSER_DEBUG__
    cout << "SiSiParser reads command: " << s << endl;
#endif
    type = ParameterType::getStringAsType(s);
    if ( type == ParameterType::UNKNOWN )
      parser.error( "Unknown command", s );
    else if ( type == ParameterType::PARAMETER )
      parser.error( "Unsupported type in this context", s );
    else
      el = Parameter::newParameter( type );
    if( el != NULL ) {
#ifdef __SISSIPARSER_DEBUG__
      cout << "SiSiParser reads parameter: ";
      el->print(cout);
#endif
      el->read(parser);
    }
  }
  return el;
}


String SiSiParser::read(TwoWayList& list, FileParser& parser) {
  Parameter* el = NULL;
  while ( parser.good() ) { // While FileParser is opened:
    el = parseParameter(parser);
    if( el != NULL ) {
      list.appendElement(el);
      el = NULL;
    }
  }
  parser.close();
  return "OK";
}
