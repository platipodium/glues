/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: String.hh,v $	
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
//  $Revision: 1.20 $
//  $Date: 1998/08/18 13:27:09 $
//
//  Description
//   Handles Strings.
//   (Supports __STRING_DESTRUCTOR_DEBUG__)
//
//
//  $Log: String.hh,v $
//  Revision 1.20  1998/08/18 13:27:09  reinhard
//  Conversion operator char* added.
//
//  Revision 1.19  1998/06/12 10:55:25  reinhard
//  Method trim added.
//
//  Revision 1.18  1998/06/11 13:09:56  kai
//  Method indexOf(char ch, int fromIndex) added.
//
//  Revision 1.17  1998/03/18 10:27:17  reinhard
//  Assigning of two Strings now possible.
//
//  Revision 1.16  1998/03/12 15:28:13  kai
//  int charAt(unsigned int index) const added and indexOf(char ch)
//  changed.
//
//  Revision 1.15  1998/03/12 12:05:20  kai
//  int indexOf(int ch) added.
//
//  Revision 1.14  1998/03/11 13:40:50  reinhard
//  operator+=(const String& s) added.
//
//  Revision 1.13  1998/02/27 09:02:34  reinhard
//  Borland needs definition of bool (platform.hh)...
//
//  Revision 1.12  1998/02/25 12:13:22  reinhard
//  Move realization of methods to String.cc.
//
//  Revision 1.11  1998/02/19 12:49:42  kai
//  Operators ==, !=, <, <=, > and => added.
//
//  Revision 1.10  1998/02/19 11:28:55  kai
//  String& operator+=(const char c) added.
//
//  Revision 1.9  1998/02/19 11:00:04  kai
//  Some ints to unsigned ints changed.
//
//  Revision 1.8  1998/02/16 14:41:42  reinhard
//  operator+(const unsigned i) const added.
//
//  Revision 1.7  1998/02/15 23:15:54  kai
//  replace(char oldChar, char newChar) added and defining most method as
//  const methods.
//
//  Revision 1.6  1998/02/15 22:06:46  kai
//  Bugfixes in operator+(...).
//
//  Revision 1.5  1998/02/15 12:44:37  kai
//  lastIndexOf(char ch), substring(int beginIndex) and substring(int
//  beginIndex, int endIndex) added. Bugfix in operator+(const char c).
//
//  Revision 1.4  1998/02/15 09:37:31  kai
//  __STRING_DESTRUCTOR_DEBUG__ inserted.
//
//  Revision 1.3  1998/02/14 23:31:14  kai
//  concate substituted by plus operators!
//
//  Revision 1.2  1998/02/14 22:12:27  kai
//  String toLowerCase() added.
//
//  Revision 1.1  1998/02/13 17:19:22  reinhard
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _String_hh_
#define _String_hh_

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include "cppinc.h"
#include "platform.hh"

class String
{
public:
  // Constructors and destructor
  String();                   // Constructs a C-string
  String(const String& s);    // Constructs a deep copy of s.
  String(const char* s );     // Constructs a deep copy of a C-string
  ~String();                  // Deallocates String memory
  
  const char* get() const;
  long length(void) const;    // Return strlen(_value).
  int compareTo(const char* str) const;


  // Returns the character at the specified index. An index ranges
  // from 0 to length() - 1.
  // Parameters: index - the index of the character. 
  // Returns: the character at the specified index of this
  //          string. The first character is at index 0.
  //          Returns -1 if index is out of bounds.
  
  int charAt(unsigned int index) const;
  
  // Returns the index within this string of the first occurrence of
  // the specified character.
  // Parameters: ch - a character. 
  // Returns: the index of the first occurrence of the character in
  //          the character sequence represented by this object, or
  //          -1 if the character does not occur.
  int indexOf(char ch) const;
  
  // Returns the index within this string of the first occurrence of
  // the specified character, starting the search at the specified
  // index.
  // Parameters: ch - a character. 
  //             fromIndex - the index to start the search from. 
  // Returns: the index of the first occurrence of the character in
  //          the character sequence represented by this object that
  //          is greater than or equal to fromIndex, or -1 if the
  //          character does not occur.
  int indexOf(char ch, int fromIndex) const;

  // Returns the index within this string of the last occurrence of
  // the specified character. The String is searched backwards
  // starting at the last character.
  // Parameters: ch - a character.
  // Returns: the index of the last occurrence of the character in the
  //          character sequence represented by this object, or -1 if the
  //          character does not occur.
  int lastIndexOf(char ch) const;

  // Returns a new string that is a substring of this string. The
  // substring begins at the specified index and extends to the end of
  // this string.
  // Parameters: beginIndex - the beginning index, inclusive.
  // Returns: the specified substring.
  String substring(unsigned int beginIndex) const;

  // Returns a new string that is a substring of this string. The
  // substring begins at the specified beginIndex and extends to the
  // character at index endIndex - 1.
  // Parameters: beginIndex - the beginning index, inclusive. 
  //             endIndex - the ending index, exclusive. 
  // Returns: the specified substring. 
  String substring(unsigned int beginIndex, unsigned int endIndex) const;

  // Converts this String to lowercase.
  // If no character in the string has a different lowercase version,
  // based on calling the tolower method, then the original string is
  // returned.
  // Otherwise, a new string is allocated, whose length is identical
  // to this string, and such that each character that has a different
  // lowercase version is mapped to this lowercase equivalent.
  String toLowerCase() const;

  // Removes white space from both ends of this string. 
  // All characters that have codes less than or equal to 
  // ' ' (the space character) are considered to be white space. 
  // Returns: this string, with white space removed from the front and end.

  String trim();
  
  // Returns a new string resulting from replacing all occurrences of
  // oldChar in this string with newChar.  If the character oldChar
  // does not occur in the character sequence represented by this
  // object, then this string is returned.

  // Parameters: oldChar - the old character. 
  //             newChar - the new character.
  // Returns: a string derived from this string by replacing every
  //          occurrence of oldChar with newChar. 
  String replace(char oldChar, char newChar) const;

  operator char*(void) const;

  // Assigns a deep copy of s:
  String& operator= (const String& s);
  // Assigns a deep copy of s.
  String& operator= (const char* s);
  String& operator+=(const char c);
  String& operator+=(const String& s);

  bool operator==(const String str) const;
  bool operator!=(const String str) const;
  bool operator<(const String str) const;
  bool operator<=(const String str) const;
  bool operator>(const String str) const;
  bool operator>=(const String str) const;

  bool operator==(const char* str) const;
  bool operator!=(const char* str) const;
  bool operator<(const char* str) const;
  bool operator<=(const char* str) const;
  bool operator>(const char* str) const;
  bool operator>=(const char* str) const;
  // Defining operator +:
  String operator+(const char* s) const;
  String operator+(const String& s) const;
  String operator+(const char c) const;
  String operator+(const int i) const;
  String operator+(const unsigned i) const;
  String operator+(const long l) const;
  String operator+(const double d) const;

  friend ostream& operator<<(ostream& out, const String &s);
  //      Writes the C-string equivalent to out.
  friend istream& operator>>(istream& in, String &s);
  //      Reads string up to the next newline or '"' from in.
  //      The termination character is extracted but not assigned.

private:
  char *_value;
};

#endif // _String_hh_
