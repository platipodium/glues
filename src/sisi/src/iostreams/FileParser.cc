/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: FileParser.cc,v $	
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
//  $Revision: 1.11 $
//  $Date: 1998/08/21 21:08:45 $
//
//  Description
//   This class parses files. Comments beginning with hash-code ('#') until
//   end of line will overread. There are many functions available.
//   (For debugging please define __FILEPARSER_DEBUG__.)
//
//  $Log: FileParser.cc,v $
//  Revision 1.11  1998/08/21 21:08:45  reinhard
//  Method getFilename added.
//
//  Revision 1.10  1998/08/19 07:06:11  reinhard
//  Method overreadCommentsAndWhiteSpaces modified.
//
//  Revision 1.9  1998/08/18 14:40:37  reinhard
//  Now ignoring unkown escape sequences (e.g. "\e" will be unchanged).
//
//  Revision 1.8  1998/08/18 13:10:44  reinhard
//  Using method FilenameHandling::convertToPlatform.
//
//  Revision 1.7  1998/07/16 13:54:26  reinhard
//  MessageHandler callings changed.
//
//  Revision 1.6  1998/07/08 07:14:50  reinhard
//  Using now MessageHandler for error messages.
//
//  Revision 1.5  1998/06/11 14:18:51  kai
//  Method readString modified (considering escape seqences (see
//  StringHandler::insertEscapeSequences().
//
//  Revision 1.4  1998/04/06 13:15:00  kai
//  readSpecifier implemented (for reading name of parameters).
//
//  Revision 1.3  1998/04/03 12:14:51  reinhard
//  Debug Zeile rausgeschmissen.
//
//  Revision 1.2  1998/02/27 09:06:34  reinhard
//  Borland doesn't aim redeclaration of function parameters ...
//
//  Revision 1.1  1998/02/25 12:48:53  reinhard
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////


// #define __FILEPARSER_DEBUG__

#include "cppinc.h"
#include "common/CharacterHandler.hh"
#include "common/FilenameHandling.hh"
#include "datastructures/String.hh"
#include "development/MessageHandler.hh"
#include "iostreams/FileParser.hh"

/** Initializes FileParser and opens the file with the name filename. */
FileParser::FileParser(String filename) {
  _maxErrors             = 5;
  _suppressErrorMessages = false;
  _overreadComments      = true;
  _overreadWhiteSpaces   = true;
  _commentCharacter      = '#';
  
  _input                 = NULL;
  _line                  = 1;
  _errorCounter          = 0;
  _existsFormatError     = false;
  _formatErrorMessage    = "";
  if( filename != NULL )
    open(filename);
}

/** Destructor. */
FileParser::~FileParser() { close(); }

///////////////////////////////////////////////////////////////////////////
//
// public access:
//
/** Opens the file with the name filename. */
String FileParser::open(const char* filename) {
  if( _input != NULL )
    delete _input;
  _filename              = FilenameHandling::convertToPlatform(filename);
  
  std::cerr << filename << " *********** versus ********** " << _filename << std::endl;
  _directory             = FilenameHandling::getParent(_filename);
  _line                  = 1;
  _errorCounter          = 0;
  _existsFormatError     = false;
  _formatErrorMessage    = "";
  _input = new ifstream(_filename);
  if( _input == NULL || !good() )
    return (String) "Error while opening file \"" + _filename +
      "\" as readable (" + strerror(errno) + ")!";
  return "OK";
}

/** Closes the stream. */
void FileParser::close() {
  if( _input != NULL ) {
    delete _input;
    _input = NULL;            // Muss explizit Null gesetzt werden.
  }
  _filename  = "untitled";
  _directory = ".";
}

/** Return the filename of the opened file. */
String FileParser::getFilename() const { return _filename; }

/** Return the directory of the opened file. */
String FileParser::getDirectory() const { return _directory; }

/** Reads the next character as int from stream (overeads whitespaces
 *  and comments first). Returns -1 if an error occurs. */
int FileParser::readChar() {
  if( _overreadWhiteSpaces )
    overreadCommentsAndWhiteSpaces();              // Overreads comments.
  return _readChar();
}

/** Reads the next long value from stream (overeads whitespaces
 *  and comments first). If positive=true, then a positive number
 *  will be expected. Returns false if an error occurs. */
bool FileParser::readLong(long& lvalue, bool positive) {
  int c;
  
  lvalue =0;
  overreadCommentsAndWhiteSpaces();              // Overreads comments.
  c = _peekChar();
  
  if( positive && c=='-' ) {      // Negative Zahl?
    _existsFormatError = true;
    error("Positive long value expected");
    lvalue = -lvalue;
  }
  if( !isdigit(c) && c!='-' ) {   // Keine Ziffer, . oder -
    _existsFormatError = true;
    error("Long value has wrong format");
    return false;                 // Fehler!
  }
  if( good() )
    *_input >> lvalue;
#ifdef __FILEPARSER_DEBUG__
  cout << "FileParser: reads long: " << lvalue << endl;
#endif
  return true;
}

/** Reads the next double value from stream (overeads whitespaces
 *  and comments first). Returns false if an error occurs. */
bool FileParser::readDouble(double& dvalue) {
  int  c;
  dvalue = 0;
  overreadCommentsAndWhiteSpaces();       // Overreads comments.
  c = _peekChar();
  if( !isdigit(c) && c!='.' && c!='-' ) { // Keine Ziffer, . oder -
    _existsFormatError = true;
    error("Double value has wrong format");
    return false;                 // Fehler!
  }
  if( good() )
    *_input >> dvalue;
#ifdef __FILEPARSER_DEBUG__
  cout << "FileParser: reads double: " << dvalue << endl;
#endif
  return true;
}

/** Reads the next character from stream encapsulated in '' (e.g.'A').
 *  (Overeads whitespaces and comments first). Returns false if
 *  an error occurs. */
bool FileParser::readSingleChar(char& cvalue) {
  if( !good() )
    return false;
  overreadCommentsAndWhiteSpaces();          // Overreads comments.
  cvalue = '0';
  if( _peekChar() != '\'' ) {
    error("' expected before the single character");
    _existsFormatError = true;
    return false;           // Format error!
  }
  _readChar();               // Take '\'' from stream.
  cvalue = _readChar();
  if( _peekChar() != '\'' ) {
    error("' expected after the single character");
    _existsFormatError = true;
    return false;           // Format error!
  }
  _readChar();               // Take '\'' from stream.
#ifdef __FILEPARSER_DEBUG__
  cout << "FileParser: reads character: '" << cvalue << "'\n";
#endif
  return true;
}

/** Reads the next String value from stream (overeads whitespaces and
 *  comments first). Strings must be encapsulated in quotationmarks
 *  ("..."). Known Escapesequences: \\ for '\' and \" for '"'.<BR>
 *  Returns false if an error occurs. Considers escape seqences (see
 *  StringHandler.insertEscapeSequences().*/
bool FileParser::readString(String& svalue) {
  int  c, startLine;
  bool escapeRead = false; // At least '\' read?
  overreadCommentsAndWhiteSpaces();              // Overreads comments.
  svalue = "";
  if( (c=_peekChar()) !='\"' ) { // Beginnt der String mit \" ? //"
    error("'\"' expected at the beginnig of string");
    _existsFormatError = true;
    return false;           // Format error!
  }
  startLine = _line;
  _readChar(); // Reads '\"'. // "
  while( good() && (c=_readChar()) > -1 ) {
    if( escapeRead ) {                      // Was '\' before read?
      if( c!='\\' && c!='\"' )              // Unknonwn escape sequence:
	svalue += '\\';
      svalue += (char) c;
      escapeRead = false;
    }
    else if( c == '\"' )
      break;
    else if( c == '\\' )
      escapeRead = true;
    else
      svalue += (char) c;
  }
  if( c!= '\"' ) { //"
    putBack(c);
    error((String) "'\"' expected at the end of string beginning in line " +
	  startLine + ")");
    _existsFormatError = true;
    return false;           // Format error!
  }
#ifdef __FILEPARSER_DEBUG__
  cout << "FileParser: reads String: " << svalue << endl;
#endif
  return true;
}

/** Reads the next boolean value from stream (false, true).<BR>
 *  (Overeads whitespaces and comments first).<BR> Returns false if
 *  an error occurs. */
bool FileParser::readBoolean(bool& bvalue) {
  if( !good() )
    return false;
  String s, t;
  overreadCommentsAndWhiteSpaces();          // Overreads comments.
  
  s = _readIdentifier();
  t = s.toLowerCase();
  if( t.compareTo("true") == 0 )
    bvalue = true;
  else if ( t.compareTo("false") == 0 )
    bvalue = false;
  else {
    error("true or false expected", s);
    _existsFormatError = true;
    return false;           // Format error!
  }
#ifdef __FILEPARSER_DEBUG__
  cout << "FileParser: reads boolean: ";
  if( bvalue ) cout << "true\n";
  else         cout << "false\n";
#endif
  return true;
}

/** Reads the next sentence from stream (overeads whitespaces and
 *  comments first). A sentence ends with '\r', '\n', '\\' or the
 *  comment character.<BR> Returns false if an error occurs. */
bool FileParser::readSentence(String& svalue) {
  ostrstream tmp;
  char* temp;
  int  c;
  overreadCommentsAndWhiteSpaces();              // Overreads comments.
  while( good() && (char)(c=_readChar())!='\r' && c!='\n' && c!='\\' &&
	 c!='#' )
    tmp << (char) c;
  putBack(c);
  tmp << ends;
  temp = tmp.str();
  svalue = temp;
  free(temp);       // Speicherbereich wieder freigeben.
#ifdef __FILEPARSER_DEBUG__
  cout << "FileParser: reads sentence: " << svalue << endl;
#endif
  return good() ? true : false;
}

/** Reads the rest of line from stream (removes white spaces from both ends).
 *  Returns false if an error occurs. */
bool FileParser::readLine(String& svalue) {
  ostrstream tmp;
  char* temp;
  int  c;
  
  while( good() && (char)(c=_readChar())!='\n' && c!='\r' )
    tmp << (char) c;
  putBack(c);
  tmp << ends;
  temp = tmp.str();
  svalue = temp;
  free(temp);       // Speicherbereich wieder freigeben.
#ifdef __FILEPARSER_DEBUG__
  cout << "FileParser: reads line: "<< svalue << endl;
#endif
  return good() ? true : false;
}

/** Reads next character and put it back to the stream (overeads whitespaces
 *  and comments first). */
int FileParser::peekChar() {
  if( _overreadWhiteSpaces )
    overreadCommentsAndWhiteSpaces();
  return _peekChar();
}

/** Puts character (int) c back to the stream (buffers it). */
void FileParser::putBack(int c) {
  if( c == '\n' )
    _line--;
  if( good() )
    _input->putback(c);
}

/** Puts String s back to the stream (buffers it). */
void FileParser::putBack(const char* s) {
  for( int i = strlen(s); i && good(); i-- )
    putBack(s[i-1]);
#ifdef __FILEPARSER_DEBUG__
  cout << "FileParser: Puts back: " << s << endl;
#endif
}

/** Overreads comments beginning with '#' and ending with end of line. */
void FileParser::overreadCommentsAndWhiteSpaces() {
  int c;
  while( good() ) {
    c = _readChar();
    if( _overreadComments && c==(int) '#' ) {
      while( (c=_readChar())!=-1 && c!=(int)'\n' )
	;
      putBack(c);
    }
    else if( isgraph(c) ) {
      putBack(c);
      return;
    }
  }
}

/** Reads the next command from stream to s (overeads whitespaces
 *  and comments first). Returns false if an error occurs. */
bool FileParser::readCommand(String& s) {
  int c;
  if( !good() ) {
    s = "";
      return false;
  }
  overreadCommentsAndWhiteSpaces();          // Overreads comments.
  _existsFormatError = false;
  c = _readChar();
  if( c != '\\' ) {
    putBack(c);
    s = _readIdentifier();
  }
  else
    s = (String) "\\" + _readIdentifier();
#ifdef __FILEPARSER_DEBUG__
  cout << "FileParser: reads command: " << s << endl;
#endif
  return true;
}

/** Reads the next identifier from stream to s (overeads whitespaces
 *  and comments first). Returns false if an error occurs. */
bool FileParser::readIdentifier(String& s) {
  if( !good() ) {
    s = "";
    return false;
  }
  _existsFormatError = false;
  overreadCommentsAndWhiteSpaces();          // Overreads comments.
  s = _readIdentifier();
#ifdef __FILEPARSER_DEBUG__
  cout << "FileParser: reads identifier: " << s << endl;
#endif
  return true;
}

/** Reads the next specifier (see CharacterHandler) from stream to s
 *  (overeads whitespaces and comments first). Returns false if an
 *  error occurs. */
bool FileParser::readSpecifier(String& s) {
  int c;
  String result = "";
  s = "";
  if( !good() )
    return false;
  overreadCommentsAndWhiteSpaces();          // Overreads comments.
  
  c = _readChar();
  // Determines if the specified character isn't permissible as the first
  // character in a C/C++ identifier (see class CharacterHandler):
  if( !CharacterHandler::isIdentifierStart((char) c) && _input!=NULL) {
    putBack(c);
    _existsFormatError = true;
    error("Specifier doesn't begin with an allowed character");
    return false;
  }
  result += (char) c;
  if( _input == NULL ) {
    s = result;
    return true;
  }
  // Determines if the specified character isn't permissible
  // in a C/C++ indentifier (see class CharacterHandler):
  while( good() && CharacterHandler::isSpecifierPart((char)(c=_readChar())) )
    result += (char) c;
  putBack(c);
  s = result;
#ifdef __FILEPARSER_DEBUG__
  cout << "FileParser: reads specifier: " << s << endl;
#endif
  return true;
}

/** Is the fileParser Status OK? Return false, if stream is not
 *  readable. */
bool FileParser::good() { return ( _input && _input->good() ); }
  
/** Builds an error message with the causing String (readString or next
 *  String of stream).
 *  The stream will be closed, if number of maximum errors is reached. */
String FileParser::buildErrorMessage(const char* msg,
				     const char* readString) {
  ostrstream tmp;
  ostrstream result;
  String r;
  char* temp;
  result << "File " << _filename << " (line " << _line << "): "
	 << msg;
  if( readString == NULL ) {
    int c = 0, i;
    for( i=0; i<17; i++ ) {
      c = _readChar();
      // Determines if the specified character isn't permissible
      // in a identifier:
      if( !good() || isspace(c) || c == '#' ) {
	putBack(c);
	break;
      }
      tmp << (char) c;
    }
    if( i==0 )
      tmp << (char) c << "(" << c << ")";
  }
  else
    tmp << readString;
  tmp << ends;
  temp = tmp.str();
  if( strlen(temp) > 0 )
    result << ": \"" << temp << "\"";
  free(temp);       // Speicherbereich wieder freigeben.
  _errorCounter++;
  if( _errorCounter >= _maxErrors )
    close();
  result << ends;
  temp = result.str();
  r = temp;
  free(temp);
  return r;
}
/** Creates and puts out an error message. (String) readString is the
 *  String causing the error or the next word in the stream. */
void FileParser::error(const char* msg, const char* readString) {
  // If reaching maximum erros, the file will be closed and called untitled.
  String filename = _filename;
  _formatErrorMessage = buildErrorMessage(msg, readString);
  if( !_suppressErrorMessages ) {
    if( _errorCounter==1 )
      MessageHandler::error((String) "Errors while parsing file: \"" +
			   filename + "\":",
			    MessageHandler::SISI_ERROR_PREFIX);
    MessageHandler::error(_formatErrorMessage,
			  MessageHandler::SISI_ERROR_PREFIX);
    if( _errorCounter >= _maxErrors ) {
      MessageHandler::error((String) "Two many errors while parsing " +
			    "file: \"" + filename + "\"",
			    MessageHandler::SISI_ERROR_PREFIX);
      MessageHandler::error("Bailing out ...",
			    MessageHandler::SISI_ERROR_PREFIX);
    }
  }
}

///////////////////////////////////////////////////////////////////////////
//
// private access:
//
/** Reads next character and put it back to the stream (buffers it). */
int FileParser::_peekChar() {
  int c = -1;
  if( good() )
    c = _input->peek();
  return c;
}
/** Reads next character from stream. */
int FileParser::_readChar() {
  int c = -1;
  if( good() ) {
    c = _input->get();
    if( !good() ) {
      _input = NULL;
      c = -1;
    }
    else if( c == '\n' ) {
      _line++;
#ifdef __FILEPARSER_DEBUG__
      cout << "FileParser: Enter to line " << _line << endl;
#endif
    }
  }
  return c;
}
/** Reads next word from stream.
 *  Words are ending with characters not allowed in identifiers. */
String FileParser::_readIdentifier() {
  return _readIdentifier(0);
}
/** Reads next word from stream (but maximum (int) number characters).
 *  Words are ending with characters not allowed in identifiers. */
String FileParser::_readIdentifier(int number) {
  String result;
  ostrstream tmp;
  char* temp;
  int counter = 0;
  int c;
  
  c = _readChar();
  // Determines if the specified character isn't permissible as the first
  // character in a identifier:
  if( !isalpha(c) && c!='_' && good() ) {
    putBack(c);
    _existsFormatError = true;
    error("Command or name doesn't begin with an allowed character");
    return "";
  }
  if( !good() )
    return "";
  tmp << (char) c;
  do {
    c = _readChar();
    // Determines if the specified character isn't permissible
    // in a identifier:
    if( !good() || (!isalnum(c) && c!='_') ) {
      putBack(c);
      tmp << ends;
      temp = tmp.str();
      result = temp;
      free(temp);       // Speicherbereich wieder freigeben.
      return result;
    }
    tmp << (char) c;
  }
  while( number==0 || ++counter<number );
  tmp << ends;
  temp = tmp.str();
  result = temp;
  free(temp);       // Speicherbereich wieder freigeben.
  return result;
}
