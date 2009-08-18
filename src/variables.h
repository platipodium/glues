/* GLUES variable externals declaration; this file is part of
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
   @author Kai W Wirtz <kai.wirtz@gkss.de
   @date   29.11.2007
   @file variables.h
   @brief Declaration of external variables
*/
#ifndef glues_variables_h
#define glues_variables_h

#ifdef HAVE_CONFIG_H
  #include <config.h>
#endif
  
#include "datastructures/String.hh"
/* Declaration of pointer to variation parameters: */
  extern double *VAR_VAL[199];
  extern char VAR_NAMES[199][22];
  extern int num_variat_parser;

/* Declaration of parameters and variables of simulation: */
  extern double Time;
  extern double TimeStart;
  extern double TimeEnd;
  extern double TimeStep;
  extern double OutputStep;
  extern long RandomInit;
  extern long LocalSpread;
  extern long RemoteSpread;
  extern double CultIndex;
  extern double Space2Time;
  extern long MaxCivNum;
  extern long DataActive;
  extern double* err_data_weights;
  extern unsigned int LengthOferr_data_weights;
  extern long RunVarInd;
  extern long VarActive;
  extern long NumDice;
  extern long MonteCarlo;
  extern long VarOutputStep;
  extern String varresfile;
  extern double storetim;
  extern double RelChange;
  extern long NumMethod;
  extern double InitTechnology;
  extern double InitNdomast;
  extern double InitQfarm;
  extern double InitDensity;
  extern double InitGerms;
  extern double deltan;
  extern double deltaq;
  extern double deltar;
  extern double regenerate;
  extern double spreadm;
  extern double ndommaxvar;
  extern double gammad;
  extern double gammam;
  extern double NPPCROP;
  extern double deltat;
  extern double spreadv;
  extern double overexp;
  extern double kappa;
  extern double gdd_opt;
  extern double omega;
  extern double gammab;
  extern double ndommaxmean;
  extern double* ndommaxcont;
  extern unsigned int LengthOfndommaxcont;
  extern double LiterateTechnology;
  extern double KnowledgeLoss;
  extern double** data_agri_start_old;
  extern unsigned int RowsOfdata_agri_start_old;
  extern unsigned int ColumnsOfdata_agri_start_old;
  extern String*      HeadOfdata_agri_start_old;
  extern double** data_agri_start;
  extern unsigned int RowsOfdata_agri_start;
  extern unsigned int ColumnsOfdata_agri_start;
  extern String*      HeadOfdata_agri_start;
  extern double flucampl;
  extern double flucperiod;
  extern long CoastRegNo;
  extern String datapath;
  extern String regiondata;
  extern String mappingdata;
  extern String resultfilename;
  extern String watchstring;
  extern String spreadfile;
  extern long* ins;
  extern unsigned int LengthOfins;
  extern String climatefile;
  extern long* ClimUpdateTimes;
  extern unsigned int LengthOfClimUpdateTimes;
  extern String eventfile;
  extern String SiteRegfile;
  extern long SaharaDesert;
  extern long LGMHoloTrans;
  extern double* IceExtent;
  extern unsigned int LengthOfIceExtent;
  extern double* IceRed;
  extern unsigned int LengthOfIceRed;

#endif

