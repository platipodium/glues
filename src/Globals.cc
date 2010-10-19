/* GLUES  globally available declaration and definitions. 
   This file is part of
   the Global Land Use and technological Evolution Simulator
   
   Copyright (C) 2001,2002,2003,2004,2005,2006,2007,2008,2009,2010
   Carsten Lemmen <carsten.lemmen@hzg.de>
   Kai W. Wirtz <kai.wirtz@hzg.de>

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
   @author Kai W. Wirtz <kai.wirtz@hzg.de>
   @date 2010-10-13
   @file Globals.cc
   @brief Global declaration and definitions 
   @todo recursive method if change>RelChange
*/

#include "Symbols.h"
#include "RegionalPopulation.h"
#include "PopulatedRegion.h"
#include "Constants.h"

//namespace glues {

RegionalPopulation *populations;
PopulatedRegion      *regions;

/* Minimal/Initial values TECHN, NDOM ,   QF  ,   RESIS,DENS,GERM      */ 
double minval[N_POPVARS]={0, EPS,EPS,EPS  ,EPS*4 ,0.02};
// double maxval[N_POPVARS]={MAXV,0.05,0.05,EPS  ,EPS ,0.02};
// 1	Eurasia
// 2	America-South
// 3	America-North
// 4 	Africa
// 5	Australia
// 6	Greenland
// 7 	Malaysia
// 8	New Guinea
// 9	Smaller islands 
double cropfertility,s_error,GlobDev,fluc=1.0,*EventTime,*EventRegTime;
char resultstring[156]="";
char climatestring[156]="",varrespath[156]="",spreadstring[156]="";
int  inspectid=0,GlobDevNum,MaxEvent,MaxProxyReg,numberOfSites;
char** climatedata;
int* timepoints,civind,vstep,RegOn;
unsigned long num_total_variat;
long GlobCivStart,tmax,OutStep;
FILE  *outfile,*watchfile[N_INSPECT]; //array of watch streams

/* ------------------------------------------ */
/*      Variation & result list variables     */
/* ------------------------------------------ */
float *store_vector;
unsigned int num_stores, num_others;
unsigned long num_variat;
string state_names[N_OUTVARS+1]=
   {"Technology","Agricultures","Farming",
    "Resistance","Density","Migration","Climate",
    "CivStart","NetDisease","Birthrate","END"};
float variat_min[N_VARIAT],variat_delt[N_VARIAT];
int variat_steps[N_VARIAT],store_ind[N_OUTVARS],*EventRegInd,*EventRegNum;
int *NewCivInd,*OldCivHit,NewCivMaxNum,NewCivNum,*RegSiteInd[MAXPROXY],
	*RegSiteRad[MAXPROXY]; 
double NewCivDist,*NewCivDev,*NewCivTime,ice_fac,*EventSerMax,*EventSerMin;
double var_out[2][N_OUTVARS],var_out0[2][N_OUTVARS];
double *par_val[N_VARIAT],*RegPerf;
double tot_spr_t,tot_pop_t,tot_spr,tot_pop;

/* ---------------------------------------------------------- */
/*   Creates memory for collecting changes due to spreading   */
/* ---------------------------------------------------------- */
double *sprd,*sprdm,ev[N_POPVARS];
double *sprd_p,*sprd_i;
double *spreadmatrix;
int maxneighbours;

/** GLOBALS section*/
int *DISTANCEMATRIX ;

/** @deprecated, obsoleted in later versions by LandRegion::IceFraction() */

double IceFac(double lat,double lon)
{
    //double lat0=50,lat2=75;
    double fac2 = hypot(IceExtent[2]-lat,IceExtent[3]+lon)/IceExtent[1];
    double fac = (90-lat)/IceExtent[0];
    if(fac2<fac) fac=fac2;
if(fac>1)  {fac = (90+lat)/IceExtent[0]; if(fac>1)fac=1;}
 return fac;
}


//}
