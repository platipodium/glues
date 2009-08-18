// 
// File:   Tracer.h
// Author: lemmen
//
// Created on September 28, 2007, 2:44 PM
//

#ifndef tracer_h
#define	tracer_h

#include "Symbols.h"
#include <cstdlib>

/** DECLARATION section **/
class Tracer {
  private:
    int length;
    char* spectrum;
  public:
    Tracer(int length);
    ~Tracer();
    int getLength();
    friend std::ostream& operator<<(std::ostream& os, Tracer& tracer);
};

#endif	/* tracer_h */

