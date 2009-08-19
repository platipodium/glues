/** @author Carsten Lemmen
    @date 2007-05-25
*/

#include "AsciiTable.h"

int AsciiTable::getRow(std::string& str) {
  char ch;
  row="";
  
  while(instream.get(ch) && !isEol(ch)) { row+=ch; };
  splitRow();
  str=row;
  return !instream.eof();
}

int AsciiTable::isEol(char ch) {
  int eol;
  
  eol = ( ch=='\n' || ch=='\r' );
  if (eol) {
    instream.get(ch);
    if (!instream.eof() && ch!='\n' && ch!='\r') instream.putback(ch);
  }
  return eol;
}

int AsciiTable::splitRow() {
  string entry;
  unsigned int i,j;

  ncol=0;
  if (row.length() == 0) return 0;
  
  for (i=0,j=0; ; j<row.length()) {
    
    while (j <= i+1) j=row.find_first_of(separator,j);
    entry=row.substr(i,j);
    ncol++;
    
    if (field.size() < (int)ncol) field[ncol]=entry;
    else field.push_back(entry);
    
    j=j+1;
  }
  
	// TODO: pgi complaines about unreachable statement here
  return ncol;
}

string AsciiTable::getField(int icol) {
  if (icol<0 || icol>ncol) return "";
  else return field[icol];
}
