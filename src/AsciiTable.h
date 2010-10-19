/** @author Carsten Lemmen
    @date 2007-05-25
*/

/* Caleb T.
Changed some types,
avoided signed/unsigned bugs.

Added bool return types where int
is used as a boolean value.

Fixed bug where calling getField(#)
will subscript a vector out of range
due to not initializing ncol to 0 in the
constructor.
*/

#ifndef __asciitable_h__
#define __asciitable_h__

#include <iostream>
#include <string>
#include <vector>
#include <cstddef>

class AsciiTable {

 private:
    std::istream &instream;
    std::string separator,row;
    std::vector<std::string> field;
    size_t ncol;

    size_t splitRow();
    bool isEol(char);
  
 public:
    AsciiTable(std::istream& in=std::cin, std::string sep=" ") : instream(in),separator(sep),ncol(0) {}

    size_t getNCols() const { return ncol; }
    bool getRow(std::string&);
    std::string getField(size_t);

};

#endif

    
	     
    


		      
