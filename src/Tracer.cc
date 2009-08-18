// 
// File:   Tracer.cc
// Author: lemmen
//
// Created on September 28, 2007, 2:48 PM
//

#include "Tracer.h"

/** Implementation section **/

Tracer::Tracer(int size)
{
    length=size;
    spectrum=(char*)malloc(size*sizeof(char));
}
    
Tracer::~Tracer()
{
    if (spectrum != NULL) free(spectrum);
    length=0;
}

int 
Tracer::getLength()
{
    return length;
}
    
std::ostream& operator<<(std::ostream& os, Tracer& tracer)
{
    cout << tracer.getLength() << _(" tracers active") ;
    return os;
}
