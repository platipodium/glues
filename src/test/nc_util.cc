/* GLUES nc_util.cc this file is part of
   the Global Land Use and technological Evolution Simulator
   
   Copyright (C) 2010
   Carsten Lemmen <carsten.lemmen@hzg.de>

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
   @author Carsten Lemmen <carsten.lemmen@hzg.de>
   @date   2010-03-06
   @file nc_util.cc
   @brief Utility functions for netCDF file handling
*/

#include "nc_util.h"

/** Copy a global attribute */
int copy_att(NcFile* file, const NcAtt* att) { 

  long attlen=att->num_vals();
  NcType atttype=att->type();
  NcValues* values=att->values();
  
  switch (atttype) {
	  case ncChar: 	file->add_att(att->name(),(char*)values->base()); break;
	  case ncByte: file->add_att(att->name(),attlen,(short*)values->base()); break;
	  case ncShort: file->add_att(att->name(),attlen,(short*)values->base()); break;
	  case ncInt: file->add_att(att->name(),attlen,(long*)values->base()); break;
	  case ncFloat: file->add_att(att->name(),attlen,(float*)values->base()); break;
	  case ncDouble: file->add_att(att->name(),attlen,(double*)values->base()); break;
  }
  return 0;
}

int copy_att(NcVar* var, const NcAtt* att) { 
  // Copy a global attribute
  long attlen=att->num_vals();
  NcType atttype=att->type();
  NcValues* values=att->values();
  
  switch (atttype) {
	  case ncChar: 	var->add_att(att->name(),(char*)values->base()); break;
	  case ncByte: var->add_att(att->name(),attlen,(short*)values->base()); break;
	  case ncShort: var->add_att(att->name(),attlen,(short*)values->base()); break;
	  case ncInt: var->add_att(att->name(),attlen,(long*)values->base()); break;
	  case ncFloat: var->add_att(att->name(),attlen,(float*)values->base()); break;
	  case ncDouble: var->add_att(att->name(),attlen,(double*)values->base()); break;
  }
  return 0;
}

int append_att(NcAtt* att, const char* ch) { 
  // Copy a global attribute
  long attlen=att->num_vals();
  NcType atttype=att->type();
  NcValues* values=att->values();
  string s1((char*)values->base());
  string s2 = s2.append(", " + string(ch));
  
  return 0;
}



