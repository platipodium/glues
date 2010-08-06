/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: FileParser.hh,v $	
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
//  $Revision: 1.13 $
//  $Date: 1998/08/21 21:08:25 $
//
//  Description
//   This class parses files. Comments beginning with hash-code ('#') until
//   end of line will overread. There are many functions available.
//   (For debugging please define __FILEPARSER_DEBUG__.)
//
//  $Log: FileParser.hh,v $
//  Revision 1.13  1998/08/21 21:08:25  reinhard
//  Method getFilename added.
//
//  Revision 1.12  1998/08/19 07:02:00  reinhard
//  Setting of _overreadComments and _overreadWhiteSpaces now possible.
//
//  Revision 1.11  1998/04/06 13:02:20  kai
//  readSpecifier implemented (for reading name of parameters).
//
//  Revision 1.10  1998/02/25 12:48:13  reinhard
//  Move realization of methods to FileParser.hh.
//
//  Revision 1.9  1998/02/25 08:47:17  reinhard
//  Adapting to Borland compiler and include stdlib.h.
//
//  Revision 1.8  1998/02/20 10:37:08  kai
//  _directory and getDirectory added. All get... functions renamed to
//  read...
//
//  Revision 1.7  1998/02/20 08:28:42  kai
//  Bugfix in open (_line and _error counter must be resetted)!
//
//  Revision 1.6  1998/02/19 11:23:44  kai
//  getString adapted to java version, some unused variables removed, ...
//
//  Revision 1.5  1998/02/19 09:28:46  kai
//  '\r' added to '\n' (MSDOS-EndOfLine).
//
//  Revision 1.4  1998/02/15 11:19:17  kai
//  open(const char* filename) changed.
//
//  Revision 1.3  1998/02/14 23:41:44  kai
//  String::concate by String::operator+(...) substituted.
//
//  Revision 1.2  1998/02/14 22:32:18  kai
//  bool getSingleChar(char& cvalue) and bool getBoolean(bool& bvalue)
//  added.
//
//  Revision 1.1  1998/02/13 17:21:56  reinhard
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _FileParser_hh_
#define _FileParser_hh_

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif
#include "cppinc.h"
#include "datastructures/String.hh"

class FileParser
{
public:
  ///////////////////////////////////////////////////////////////////////////
  //
  // Constructors:
  //
  /** Initializes FileParser and opens the file with the name filename. */
  FileParser(String filename="untitled");

  /** Destructor. */
  ~FileParser();

  ///////////////////////////////////////////////////////////////////////////
  //
  // public access:
  //
  /** Opens the file with the name filename. */
  String open(const char* filename);

  /** Closes the stream. */
  void close();

  /** Return the filename of the opened file. */
  String getFilename() const;
  /** Return the directory of the opened file. */
  String getDirectory() const;

  /** Reads the next character as int from stream (overeads whitespaces
   *  and comments first). Returns -1 if an error occurs. */
  int readChar();

  /** Reads the next long value from stream (overeads whitespaces
   *  and comments first). If positive=true, then a positive number
   *  will be expected. Returns false if an error occurs. */
  bool readLong(long& lvalue, bool positive=false);

  /** Reads the next double value from stream (overeads whitespaces
   *  and comments first). Returns false if an error occurs. */
  bool readDouble(double& dvalue);

  /** Reads the next character from stream encapsulated in '' (e.g.'A').
   *  (Overeads whitespaces and comments first). Returns false if
   *  an error occurs. */
  bool readSingleChar(char& cvalue);

  /** Reads the next String value from stream (overeads whitespaces
   *  and comments first). Strings must be encapsulated in quotationmarks
   *  ("...").<BR> Returns false if an error occurs. */
  bool readString(String& svalue);

  /** Reads the next boolean value from stream (false, true).<BR>
   *  (Overeads whitespaces and comments first).<BR> Returns false if
   *  an error occurs. */
  bool readBoolean(bool& bvalue);

  /** Reads the next sentence from stream (overeads whitespaces and
   *  comments first). A sentence ends with '\r', '\n', '\\' or the
   *  comment character.<BR> Returns false if an error occurs. */
  bool readSentence(String& svalue);

  /** Reads the rest of line from stream (removes white spaces from both ends).
   *  Returns false if an error occurs. */
  bool readLine(String& svalue);

  /** Reads next character and put it back to the stream (overeads whitespaces
   *  and comments first). */
  int peekChar();
  
  /** Puts character (int) c back to the stream (buffers it). */
  void putBack(int c);

  /** Puts String s back to the stream (buffers it). */
  void putBack(const char* s);

  /** Overreads comments beginning with '#' and ending with end of line. */
  void overreadCommentsAndWhiteSpaces();

  /** Reads the next command from stream to s (overeads whitespaces
   *  and comments first). Returns false if an error occurs. */
  bool readCommand(String& s);
  
  /** Reads the next identifier from stream to s (overeads whitespaces
   *  and comments first). Returns false if an error occurs. */
  bool readIdentifier(String& s);

  /** Reads the next specifier (see CharacterHandler) from stream to s
   *  (overeads whitespaces and comments first). Returns false if an
   *  error occurs. */
  bool readSpecifier(String& s);

  /** Is the fileParser Status OK? Return false, if stream is not
   *  readable. */
  bool good();

  /** Enables or disables overreading of white spaces. */
  void enableOverreadWhiteSpaces(bool b) {
    _overreadWhiteSpaces = b;
  }

  /** Enables or disables overreading of comments. */
  void enableOverreadComments(bool b) {
    _overreadComments = b;
  }
  
  /** Builds an error message with the causing String (readString or next
   *  String of stream).
   *  The stream will be closed, if number of maximum errors is reached. */
  String buildErrorMessage(const char* msg, const char* readString=NULL);

  /** Creates and puts out an error message. (String) readString is the
   *  String causing the error or the next word in the stream. */
  void error(const char* msg, const char* readString=NULL);

private:
  ///////////////////////////////////////////////////////////////////////////
  //
  // private access:
  //
  /** Reads next character and put it back to the stream (buffers it). */
  int _peekChar();

  /** Reads next character from stream. */
  int _readChar();

  /** Reads next word from stream.
   *  Words are ending with characters not allowed in identifiers. */
  String _readIdentifier();

  /** Reads next word from stream (but maximum (int) number characters).
   *  Words are ending with characters not allowed in identifiers. */
  String _readIdentifier(int number);

  // Controlling variables:
  short    _maxErrors;             // Maximum allowed errors.
  bool     _suppressErrorMessages; // Supress output of error messages?
  bool     _overreadComments;      // Overread comments?
  bool     _overreadWhiteSpaces;   // Overread white spaces?
  char     _commentCharacter;      // Comment character.

  // Intern variables:
  istream* _input;
  String   _filename;              // Name of the opened file.
  String   _directory;             // Directory of the opened file.
  String   _buffer;                // Buffer for peek and read methods.
  int      _line;                  // Actual line number.
  short    _errorCounter;          // Actual number of errors.
  bool     _existsFormatError;     // Does a format error occurs?
  String   _formatErrorMessage;    // The message for format error.

};

#endif // _FileParser_hh_
