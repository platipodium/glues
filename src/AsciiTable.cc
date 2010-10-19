/** @author Carsten Lemmen
    @date 2007-05-25
*/

/*
Caleb T.
10/19/2010

Modification to line in which for() loop test condition
was placed improperly.

Signed/unsigned mismatch 
"if (field.size() < (int)ncol)"
size_t is a typedef which can change from 32 to 64 bit
platforms, and is returned by .size() for vectors and strings, etc.

Other minor modifications also, I think this will work as expected.
*/
#include "AsciiTable.h"
#include <sstream>
#include <algorithm>

bool AsciiTable::getRow(std::string& str) {
  char ch;
  row.clear();

  while(instream.get(ch))
  {
	  if( !isEol(ch) )
		  row.push_back(ch);
	  else
		  break;
  }
  splitRow();
  str=row;
  return !instream.eof();
}

bool AsciiTable::isEol(char ch) {
  
	bool eol;
	eol = ( ch=='\n' || ch=='\r' );

	if (eol)
	{
		//Verify next character(s) also not eol.
		while( instream.good() )
		{
			instream.get(ch);
			if (!instream.eof() && ch!='\n' && ch!='\r')
			{
				//ch is not eol, put back.
				instream.putback(ch);
				break;
			}
		}
	}
	return eol;
}

size_t AsciiTable::splitRow() {
  std::string entry;
  size_t i,j;

  ncol=0;
  if (row.size() == 0) return 0;
  
  //Updated.
  j = i = 0;
  while( i < row.size() && j < row.size() )
  {
	  //Replace separator with whitespace for
	  //extraction with the extraction operator.
	  //Hopefully this will be more robust.
	  j = row.find( separator, i );
	  if( j == std::string::npos )
		  break;
	  std::fill_n( row.begin()+j, separator.size(), ' ' );
	  i=j+1;
  }

  std::stringstream ss(row);
  while( ss >> entry )
  {
	  //Extract entries & insert into vector<string> field.
	  ncol++;
	  if( field.size() >= ncol)
		  field.at(ncol-1) = entry;
	  else
		  field.push_back( entry );
  }

  return ncol;
}

std::string AsciiTable::getField(size_t icol)
{
	//icol is unsigned.
	if( (ncol == 0) || (icol > (ncol-1)) )
	{
		return "";
	}
	else
	{
		return field.at(icol);
	}
}
