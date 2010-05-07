/* GLUES  parameter declaration this file is part of
   the Global Land Use and technological Evolution Simulator
   
   Copyright (C) 2010
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
   @author Kai W Wirtz <kai.wirtz@gkss.de
   @date 2010-05-07
   @file Parameter.h
   @brief Global parameter class
*/

/** PREPROCESSOR section **/
#ifndef glues_parameter_h
#define glues_parameter_h

#include "Symbols.h"

#include <string>
#include "variables.h"
#include "RegionalPopulation.h"
#include "PopulatedRegion.h"
#include "Constants.h"

/****************************************************
 *  Prototypes and global variables 	            *
 ****************************************************/
namespace glues {

static class Parameter {
  
edit
extern RegionalPopulation *populations;
extern PopulatedRegion     *regions;
extern double cropfertility,s_error,GlobDev,fluc,ice_fac;
extern double minval[N_POPVARS],*EventTime,*EventRegTime,*EventSerMax,*EventSerMin;
extern char resultstring[156];
extern char climatestring[156],varrespath[156],spreadstring[156];
extern int  inspectid,GlobDevNum,RegOn,MaxEvent,MaxProxyReg,numberOfSites;
extern int vstep,*RegSiteInd[MAXPROXY],*RegSiteRad[MAXPROXY];
extern unsigned long num_total_variat,num_variat;
extern char** climatedata;
extern int* timepoints,civind;
extern int* DISTANCEMATRIX;
extern long GlobCivStart,tmax,OutStep;
extern FILE  *outfile,*watchfile[N_INSPECT]; //array of watch streams
extern double* sprd,*sprdm,ev[N_POPVARS];
extern unsigned int num_stores,num_states,num_others;
extern float *store_vector;
extern int *EventRegInd,*EventRegNum;
extern string state_names[N_OUTVARS+1];
extern float variat_min[N_VARIAT],variat_delt[N_VARIAT];
extern int variat_steps[N_VARIAT],store_ind[N_OUTVARS]; 
extern int *NewCivInd,*OldCivHit,NewCivMaxNum,NewCivNum;
extern double NewCivDist,*NewCivDev,*NewCivTime;
extern double var_out[2][N_OUTVARS],var_out0[2][N_OUTVARS];
extern double *par_val[N_VARIAT],*RegPerf;
extern double tot_pop_t,tot_spr,tot_pop;
};
}

#endif
