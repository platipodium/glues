/** @author Carsten Lemmen
    @date 2007-05-25
*/

#ifndef __asciitable_h__
#define __asciitable_h__

#include <iostream>
#include <string>
#include <vector>
using namespace std;

class AsciiTable{

 private:
    istream& instream;
    string separator,row;
    vector<std::string> field;
    int ncol;

    int splitRow();
    int isEol(char);    
  
 public:
    AsciiTable(istream& in=cin,string sep=" ") : instream(in),separator(sep) {}

    int getNCols() const { return ncol; }
    int getRow(std::string&);
    string getField(int); 

};

#endif

    
	     
    


		      
