/* GLUES region mapping specification; this file is part of
   the Global Land Use and technological Evolution Simulator
   
   Copyright (C) 2001,2002,2003,2004,2005,2006,2007,2008
   Carsten Lemmen <carsten.lemmen@gkss.de>, Kai Wirtz <kai.wirtz@gkss.de>

   This program is free software; you can redistribute it and/or modify it
   under the terms of the GNU General Public License as published by the
   Free Software Foundation; either version 2, or (at your option) any later
   version.

   This program is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
   Public License for more details.

   You should have received a copy of the GNU General Public License along
   with this program; if not, write to the Free Software Foundation, Inc.,
   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
*/
/**
   @author Carsten Lemmen <carsten.lemmen@gkss.de>
   @author Kai Wirtz <kai.wirtz@gkss.de>
   @date   2008-01-14
   @file RegionMapping.cc
   @brief Implementation of class RegionMapping
*/

#include "RegionMapping.h"

RegionMapping::RegionMapping(unsigned int num) {
  if ((numcells=num) >0) {
    cout << endl << num << endl;
    cellids=new unsigned int[num];
    for (unsigned int i=0; i<numcells; i++) cellids[i]=0;
  }
  else cellids=0;
}


RegionMapping::RegionMapping(unsigned int num, unsigned int* ids) {
  if ((numcells=num) >0) {
    cellids=new unsigned int[num];
    for (unsigned int i=0; i<numcells; i++) cellids[i]=ids[i];
  }
  else cellids=0;
}

/*RegionMapping::RegionMapping(unsigned int num, double* lats, double* lons) {
  if ((numcells=num)>0) {
    cellids=new unsigned int[num];
    for (unsigned int i=0; i<numcells; i++) cellids[i]=geo2id(lats[i],lons[i]);
  }
  else cellids=0;
}

RegionMapping::RegionMapping(char* filename, unsigned int id) {

  const static int BUFSIZE=10;
  static char  charbuffer[BUFSIZE];

  ifstream file(filename,ios::in);
  char ch;
  unsigned int i=0,index;

  if (file.fail()) {
    cout << "FATAL: Cannot open file " << filename << endl;
    exit(1);
  }

  while ((ch=file.get())) {

    // Test for whitespace as separator
    if (ch!=' ' || ch != 10 || ch!=13 || ch!='\t') {
      charbuffer[i++]=ch;

      if (i>BUFSIZE-1) {
	cout << "FATAL: Buffer too small (BUFSIZE=" << BUFSIZE << endl;
	exit(1);
      }
      continue;
    }
   
    // Whitespace was detected, convert to integer and 
    // clear buffer
    index=atoi(charbuffer);
    for (int j=0;j<BUFSIZE;j++) charbuffer[j]='\0';
    i=0;

    if (index != id) file.ignore(10000,'\n');
    else {;
    //treat line here
    }
    continue;
  }
  
  file.close();
}
*/

unsigned int RegionMapping::geo2id(double lat,double lon) const {
  unsigned int dx,dy;
  dx=(unsigned int)((90.-lat)*2.);
  dy=(unsigned int)((lon+180.)*2.);
  return dx*720+dy;
}

std::ostream& operator<<(std::ostream& os, const RegionMapping& map) {
  return os << "Map[" << map.Number() << "]";
}

int RegionMapping::Assign(unsigned int * ids) {
  for (unsigned int i=0; i<numcells; i++) {
    cellids[i]=ids[i];
  }
  return 1;
}

/** EOF RegionMapping.cc*/
