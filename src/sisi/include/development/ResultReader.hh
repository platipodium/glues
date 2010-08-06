/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: ResultReader.hh,v $	
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
//  $Revision: 1.5 $
//  $Date: 1998/07/27 18:56:14 $
//
//  Description
//    ResultReader reads result files.
//
//
//  $Log: ResultReader.hh,v $
//  Revision 1.5  1998/07/27 18:56:14  reinhard
//  Method hasMoreElements added.
//
//  Revision 1.4  1998/07/11 13:42:25  kai
//  Method getHeadParameter(const char* name) added.
//
//  Revision 1.3  1998/07/08 06:12:54  reinhard
//  Method increaseColumnIterators() returns now bool.
//
//  Revision 1.2  1998/07/08 05:40:10  reinhard
//  Method getNameOfColumn added.
//
//  Revision 1.1  1998/06/09 10:53:09  kai
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _ResultReader_hh_
#define _ResultReader_hh_

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif
#include "platform.hh"
#include "datastructures/String.hh"
#include "datastructures/TableParameter.hh"
#include "development/ResultElement.hh"
#include "iostreams/FileParser.hh"
#include "twowaylist/TwoWayList.hh"


class ResultReader
{
public:
  /** Initialize ResultReader with a filename.  ResultReader will read
   *  results from the given file. */
  ResultReader(const char* filename = NULL);
  /** NOT realized. */
  ResultReader(const ResultReader&);
  ~ResultReader();

  /** Sets default filename. */
  void setFilename(const char* name);

  /** Open 'filename', return status.  return "OK" or errormessage. */
  String open(const char* filename = NULL );

  /** Close stream. */
  void close();

  /** Reads the whole table data. */
  void readTable();

  /** Gets the type of the given column. */
  ParameterType* getTypeOfColumn(const char* name);

  /** Gets the head parameter. This is usefully for complex containing
   *  types, e.g. arrays for get the dimension and so on. */
  Parameter* getHeadParameter(const char* name);
 
  /** Resets all column iterators. */
  void resetColumnIterators();

  /** Returns true if all iterators has successors. */
  bool hasMoreElements();

  /** Increases all column iterators. */
  bool increaseColumnIterators();

  /** Gets the actual element of the given column to which the
   *  iterator points. */
  TwoWayListElement* getElement(const char* name,
				ParameterType* type = NULL);

  /** Gets the name of the column with the given number. */
  String getNameOfColumn(int number);

private:
  FileParser            _resultFile;     // FileParser.
  String                _resultFilename; // Name of the resultfile.
  TableParameter*       _resultTable;    // All input parameters.
};

#endif // _ResultReader_hh_
