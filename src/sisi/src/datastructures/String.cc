/////////////////////////////////////////////////////////////////////////////
//
//  $RCSfile: String.cc,v $	
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
//  $Date: 1998/08/18 13:27:13 $
//
//  Description
//
//
//  $Log: String.cc,v $
//  Revision 1.9  1998/08/18 13:27:13  reinhard
//  Conversion operator char* added.
//
//  Revision 1.8  1998/08/18 09:04:30  reinhard
//  Borland has problems with method trim: return (...) ? ... : ...
//
//  Revision 1.7  1998/06/12 10:55:37  reinhard
//  Method trim added.
//
//  Revision 1.6  1998/06/11 13:10:00  kai
//  Method indexOf(char ch, int fromIndex) added.
//
//  Revision 1.5  1998/03/18 10:27:27  reinhard
//  Assigning of two Strings now possible.
//
//  Revision 1.4  1998/03/12 15:28:25  kai
//  int charAt(unsigned int index) const added and indexOf(char ch)
//  changed.
//
//  Revision 1.3  1998/03/11 13:44:22  reinhard
//  operator+=(const String& s) added.
//
//  Revision 1.2  1998/02/25 12:13:38  reinhard
//  Realization of all methods added.
//
//  Revision 1.1  1998/02/13 17:24:11  reinhard
//  Initial revision
//
/////////////////////////////////////////////////////////////////////////////

#include "cppinc.h"
#include "datastructures/String.hh"

String::String() {                  // Constructs a C-string
  _value = new char[1];
  _value[0] = 0;
}
String::String(const String& s) {   // Constructs a deep copy of s.
  _value = new char[strlen(s._value)+1];   // Allocate memory for the copy
  strcpy(_value, s._value);                // Copy the argument's characters.
}
String::String(const char* s ) {    // Constructs a deep copy of a C-string
  _value = new char[strlen(s) + 1];        // Leave room for the '\0'
  strcpy(_value, s);                       // Copy from s to info
}
String::~String() {                 // Deallocates String memory
  if( _value ) {
#ifdef __STRING_DESTRUCTOR_DEBUG__
    cout << "--- Destructor for String \"" << _value << "\" called.\n";
#endif
    delete [] _value;                      // Deallocate the array.
  }
}

const char* String::get() const {
  return _value;
}
long String::length(void) const {   // Return strlen(_value).
  return strlen(_value);
}
int String::compareTo(const char* str) const {
  if( str == NULL )
    return 1;
  return strcmp(_value, str);
}
int String::charAt(unsigned int index) const {
  if( index<strlen(_value) )
    return _value[index];
  else
    return -1;
}
int String::indexOf(char ch) const {
  for( unsigned int i=0; i<=strlen(_value); i++ ) {
    if( _value[i] == ch )
      return i;
  }
  return -1;
}
int String::indexOf(char ch, int fromIndex) const {
  for( unsigned int i=fromIndex; i<=strlen(_value); i++ ) {
    if( _value[i] == ch )
      return i;
  }
  return -1;
}
int String::lastIndexOf(char ch) const {
  for( int i=strlen(_value); i>=0; i-- ) {
    if( _value[i] == ch )
      return i;
  }
  return -1;
}
String String::substring(unsigned int beginIndex) const {
  if( beginIndex > strlen(_value) )
    return (String) "";
  String result = &_value[beginIndex];
  return result;
}
String String::substring(unsigned int beginIndex,
			 unsigned int endIndex) const {
  if( beginIndex >= endIndex )
    return (String) "";
  if( endIndex > strlen(_value) )
    return substring(beginIndex);
  String result = "";
  for( unsigned int i=beginIndex; i<endIndex; i++ )
    result = result + (char) _value[i];
  return result;
}
String String::toLowerCase() const {
  bool change = false;
  for( unsigned int i=0; i<strlen(_value) && !change; i++ )
    if( _value[i] != tolower(_value[i]) )
      change = true;
  if( change ) {
    String result = _value;
    for( unsigned int i=0; i<strlen(result._value); i++ )
      result._value[i] = tolower(result._value[i]);
    return result;
  }
  return *this;
}
String String::trim() {
  unsigned int count = strlen(_value);
  unsigned int len = count;
  unsigned int st = 0;
  while ((st < len) && (_value[st] <= ' ')) {
    st++;
  }
  while ((st < len) && (_value[len - 1] <= ' ')) {
    len--;
  }
  if ((st > 0) || (len < count))
    return substring(st, len);
  return *this;
}
String String::replace(char oldChar, char newChar) const {
  bool change = false;
  for( unsigned int i=0; i<strlen(_value) && !change; i++ )
    if( _value[i] == oldChar )
      change = true;
  if( change ) {
    String result = _value;
    for( unsigned int i=0; i<strlen(result._value); i++ ) {
      if( _value[i] == oldChar )
	result._value[i] = newChar;
    }
    return result;
  }
  else
    return _value;
}

String::operator char*(void) const
{ return _value; }

String& String::operator= (const String& s) {
  if (this != &s ) {                        // Cover the case of s = s.
    if( _value )
      delete [] _value;                     // Deallocate the old buffer.
    _value = new char[strlen(s._value) +1]; // Alloc. memory for a new one.
    strcpy(_value, s._value);               // Copy the characters from the
  }                                         //  right side to the left.
  return *this;
}

String& String::operator= (const char* s) {
  if( _value )
    delete [] _value;                       // Deallocate the old buffer.
  _value = new char[strlen(s) +1];          // Alloc. memory for a new one.
  strcpy(_value, s);                        // Copy the characters.
  return *this;
}

String& String::operator+=(const char c) {
  int l = strlen(_value);
  char* t = new char[l + 2];
  strcpy(t, _value);                     // Copy the characters.
  t[l  ] = c;                            // Add character.
  t[l+1] = 0;                            // Termination character.
  if( _value )
    delete [] _value;                    // Deallocate the old buffer.
  _value = t;
  return *this;
}

String& String::operator+=(const String& s) {
  *this = *this + (const char*) s._value;
  return *this;
}

bool String::operator==(const String str) const {
  if( str == NULL || _value == NULL )
    return false;
  return ( strcmp(_value, str._value) == 0 );
}

bool String::operator!=(const String str) const {
  if( str == NULL || _value == NULL )
    return false;
  return ( strcmp(_value, str._value) != 0 );
}

bool String::operator<(const String str) const {
  if( str == NULL || _value == NULL )
    return false;
  return ( strcmp(_value, str._value) < 0 );
}

bool String::operator<=(const String str) const {
  if( str == NULL || _value == NULL )
    return false;
  return ( strcmp(_value, str._value) <= 0 );
}

bool String::operator>(const String str) const {
  if( str == NULL || _value == NULL )
    return false;
  return ( strcmp(_value, str._value) > 0 );
}

bool String::operator>=(const String str) const {
  if( str == NULL || _value == NULL )
    return false;
  return ( strcmp(_value, str._value) >= 0 );
}

bool String::operator==(const char* str) const {
  if( str == NULL || _value == NULL )
    return false;
  return ( strcmp(_value, str) == 0 );
}

bool String::operator!=(const char* str) const {
  if( str == NULL || _value == NULL )
    return false;
  return ( strcmp(_value, str) != 0 );
}

bool String::operator<(const char* str) const {
  if( str == NULL || _value == NULL )
    return false;
  return ( strcmp(_value, str) < 0 );
}

bool String::operator<=(const char* str) const {
  if( str == NULL || _value == NULL )
    return false;
  return ( strcmp(_value, str) <= 0 );
}

bool String::operator>(const char* str) const {
  if( str == NULL || _value == NULL )
    return false;
  return ( strcmp(_value, str) > 0 );
}

bool String::operator>=(const char* str) const {
  if( str == NULL || _value == NULL )
    return false;
  return ( strcmp(_value, str) >= 0 );
}

String String::operator+(const char* s) const {
  String result;
  if( result._value )
    delete [] result._value;
  result._value = new char[strlen(_value) + strlen(s) + 1];
  strcpy(result._value, _value);                      // Copy the characters.
  strcat(result._value, s);
  return result;
}

String String::operator+(const String& s) const {
  String result = *this + (const char*) s._value;
  return result;
}

String String::operator+(const char c) const {
  String result;
  if( result._value )
    delete [] result._value;
  int l = strlen(_value);
  result._value = new char[l + 2];
  strcpy(result._value, _value);         // Copy the characters.
  result._value[l  ] = c;                // Add character.
  result._value[l+1] = 0;                // Termination character.
  return result;
}

String String::operator+(const int i) const {
  ostringstream tmp;
  tmp << _value << i << ends;
  String result = tmp.str().c_str();
  return result;
}

String String::operator+(const unsigned i) const {
  ostringstream tmp;
  tmp << _value << i << ends;
  String result = tmp.str().c_str();
  return result;
}

String String::operator+(const long l) const {
  ostringstream tmp;
  tmp << _value << l << ends;
  String result = tmp.str().c_str();
  return result;
}

String String::operator+(const double d) const {
  ostringstream tmp;
  tmp << _value << d << ends;
  String result = tmp.str().c_str();
  return result;
}

ostream& operator<< (ostream& out, const String& s)
{
  out << (const char*) s;
  return out;
}

istream& operator>> (istream& in, String& s)
{
  char c;
  ostringstream tmp;
  while( in.good() && (c=in.get())!='"' && c!='\n' )
    tmp << c;
  tmp << ends;
  
  const char *cstr = tmp.str().c_str();
  int l=tmp.str().length();
  char* temp=new char[l];
  for (int i=0; i<tmp.str().length(); i++) temp[i]=cstr[i];
  s = (char*)temp;
  free(temp);       // Speicherbereich wieder freigeben.

  return in;
}
