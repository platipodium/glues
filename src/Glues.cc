/* GLUES main program; this file is part of
   the Global Land Use and technological Evolution Simulator

   Copyright (C) 2001,2002,2003,2004,2005,2006,2007,2008,2009,2010
                 2011,2012
   Carsten Lemmen <carsten.lemmen@hzg.de>, Kai Wirtz <kai.wirtz@hzg.de>

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
   @author Kai Wirtz <kai.wirtz@hzg.de>
   @date   2012-05-16
   @file   Glues.cc
   @brief  Main driver for GLUES simulations
*/

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include "Symbols.h"
#include "GlobalClimate.h"
#include "Messages.h"
#include "Globals.h"
#include "callSiSi.hh"
#include "IO.h"
#include "Input.h"
#include "Data.h"
#include "GNetcdf.h"
#include <vector>
#include <iostream>
#include <fstream>
#include <string>

#ifdef HAVE_MPI_H
#include "mpi.h"
#endif

#ifdef HAVE_NETCDF_H
#include "netcdfcpp.h"
#endif

unsigned int numberOfRegions=0;

/* Prototypes */

class Exchange;
double pseudo_simulation();
double simulation();
long unsigned int calc_deviation(unsigned long int);
extern double spread_all(double t);
void dump_events();
std::string ncfilename;
bool is_restart=false;

/**
  Main program incl. pre- & postprocessing
*/
int main(int argc, char* argv[])
{
  
  /** 1. Check whether valid arguments were passed to the main program.
      Currently, the only valid argument count is 2, with value(1) a
      string denoting the file name of the configuration file. 
      Also check whether the file can be openened */
  if (argc!=2) {
    std::cerr << "Exactly one argument (.nc or .sim file name) required." << std::endl;
    glues::Messages::Error(); 
    return 1;
  }

  std::string configfilename(argv[1]);
  size_t pos=configfilename.rfind('.');
  size_t len=configfilename.length();
  std::string ext=configfilename.substr(pos+1,len-pos-1);

  std::ifstream ifs;
  ifs.open(configfilename.c_str(),ios::in);
  if (ifs.bad()) {
    std::cerr << "The input file " << configfilename << " cannot be read." << std::endl;
    glues::Messages::Error();
    return 1;
  }
  ifs.close();


  /** 2. Define MPI and internationalization packages */
#ifdef HAVE_MPI_H
  MPI::Init(argc,argv);
  int mpi_rank=MPI::COMM_WORLD.Get_Rank();
  int mpi_size=MPI::COMM_WORLD.Get_Size();
#endif

#ifdef HAVE_LIBINTL_H
  /** setup internationalization/localization */
  setlocale (LC_ALL, "");
  //bindtextdomain (PACKAGE, LOCALEDIR);
  textdomain (PACKAGE);
#endif


/** 3. Parse the simulation parameters in the SiSi configuration.
  @todo There should be in the future an alternative configuration which
  does not rely on SiSi.  This could be achieved with a converter from SiSi 
  to Namelist and vice versa, or with a parallel development */
  
  if (!ext.compare("sim")) {
    if (!SiSi::parseSimulation(argc, argv) ) {
      std::cerr << "Could not parse SiSi simulation file " << configfilename << "." << std::endl;
	  glues::Messages::Error();
      SiSi::finalize();
      return 1;
    }   
    else {
      
#ifdef HAVE_NETCDF_H
      ncfilename=configfilename.substr(0,pos).append(".nc");
      NcFile ncout(ncfilename.c_str(),NcFile::Replace);

      std::cout << "Writing results and configuration to new file " << ncfilename << std::endl;

      int status=gnc_write_header(ncout);
      
      ncout.add_att("param_Time",Time);
      ncout.add_att("param_TimeStart",TimeStart);
      ncout.add_att("param_TimeEnd",TimeEnd);
      ncout.add_att("param_TimeStep",TimeStep);      
      ncout.add_att("param_OutputStep",OutputStep);
      ncout.add_att("param_CultIndex",CultIndex);
      ncout.add_att("param_Space2Time",Space2Time);
      ncout.add_att("param_storetime",storetim);
      ncout.add_att("param_RelChange",RelChange);
      ncout.add_att("param_InitTechnology",InitTechnology);
      ncout.add_att("param_InitNdomast",InitNdomast);
      ncout.add_att("param_InitQfarm",InitQfarm);
      ncout.add_att("param_InitDensity",InitDensity);
      ncout.add_att("param_deltan",deltan);
      ncout.add_att("param_deltaq",deltaq);
      ncout.add_att("param_regenerate",regenerate);
      ncout.add_att("param_spreadm",spreadm);
      ncout.add_att("param_ndommaxvar",ndommaxvar);
      ncout.add_att("param_gammad",gammad);
      ncout.add_att("param_gammam",gammam);
      ncout.add_att("param_NPPCROP",NPPCROP);
      ncout.add_att("param_deltat",deltat);
      ncout.add_att("param_spreadv",spreadv);
      ncout.add_att("param_overexp",overexp);
      ncout.add_att("param_kappa",kappa);
      ncout.add_att("param_gdd_opt",gdd_opt);
      ncout.add_att("param_omega",omega);
      ncout.add_att("param_gammab",gammab);
      ncout.add_att("param_ndommaxmean",ndommaxmean);
      ncout.add_att("param_LiterateTechnology",LiterateTechnology);
      ncout.add_att("param_KnowledgeLoss",KnowledgeLoss);
      ncout.add_att("param_flucampl",flucampl);
      ncout.add_att("param_flucperiod",flucperiod);
      ncout.add_att("param_RandomInit",RandomInit);
      ncout.add_att("param_LocalSpread",LocalSpread);
      ncout.add_att("param_RemoteSpread",RemoteSpread);
      ncout.add_att("param_MaxCivNum",MaxCivNum);
      ncout.add_att("param_DataActive",DataActive);
      ncout.add_att("param_RunVarInd",RunVarInd);
      ncout.add_att("param_VarActive",VarActive);
      ncout.add_att("param_NumDice",NumDice);
      ncout.add_att("param_MonteCarlo",MonteCarlo);
      ncout.add_att("param_VarOutputStep",VarOutputStep);
      ncout.add_att("param_NumMethod",NumMethod);
      ncout.add_att("param_CoastRegNo",CoastRegNo);
      ncout.add_att("param_SaharaDesert",SaharaDesert);
      ncout.add_att("param_LGMHoloTrans",LGMHoloTrans);
      //ncout.add_att("param_SimulationName",SimulationName);
      //ncout.add_att("param_ModelName",ModelName);
      //ncout.add_att("param_ModelPath",ModelPath);
      ncout.add_att("param_varresfile",varresfile);
      ncout.add_att("param_datapath",datapath);
      ncout.add_att("param_regiondata",regiondata);
      ncout.add_att("param_mappingdata",mappingdata);
      ncout.add_att("param_resultfilename",resultfilename);
      ncout.add_att("param_watchstring",watchstring);
      ncout.add_att("param_spreadfile",spreadfile);
      ncout.add_att("param_climatefile",climatefile);
      ncout.add_att("param_eventfile",eventfile);
      ncout.add_att("param_SiteRegfile",SiteRegfile);
      
      // Write simulation paramters to netcdf restart file (TODO)
      ncout.close();
#endif
    }
  }
  else if (!ext.compare("nc")) {
/*#ifndef HAVE_NETCDF_H
  	  glues::Messages::Error();
#endif*/
      ncfilename=configfilename;
      configfilename=ncfilename.substr(0,pos).append(".sim");
            
      if (!SiSi::parseSimulation(configfilename.c_str(), argv[0])) {
        std::cerr << "Could not parse SiSi simulation file " << configfilename << "." << std::endl;
	    glues::Messages::Error();
        SiSi::finalize();
        return 1;
      }   
      is_restart=true;
      
  }
  else { 
#ifdef HAVE_MPI_H
    if (mpi_rank==0)
#endif
      std::cerr << "Extensions .sim or .nc required." << std::endl, glues::Messages::Error();
    return 1;
  }

#ifdef HAVE_MPI_H
  if (mpi_rank==0)
#endif
    glues::Messages::Welcome();
  
  if (
#ifdef HAVE_MPI_H
      mpi_rank==0 &&
#endif
  /** Read in the basic geographical region definitions
*/
      read_data() ) {
      glues::Messages::Error();
      SiSi::finalize();
#ifdef HAVE_MPI_H
      MPI::Finalize();
#endif
      return 1;
  }

 /** Correct ins and LengthOfIns for those regions which are not part
  of the simulation */
  long int* newins=new long int[LengthOfins];
  unsigned int newlenins=0;
  for (unsigned int i=0; i<numberOfRegions; i++) {
    unsigned int j=regions[i].Id();
    for (unsigned int ii=0; ii<LengthOfins; ii++) if (j==ins[ii]) newins[newlenins++]=ins[ii]; 
  }
  LengthOfins=newlenins;
  for (unsigned int i=0; i<LengthOfins; i++) ins[i]=newins[i];
  delete [] newins;

/** Initialize the Events and populations */
  if ( initialize() ) {
      glues::Messages::Error();
      SiSi::finalize();
#ifdef HAVE_MPI_H
      MPI::Finalize();
#endif
      return 1;
  }

  /** This is a hack: fill EventRegTime[nreg x MaxEvent] from matlab calculation*/
  if (flucampl>0) read_EventRegTime();


  /**
     opens array of ascii & binary result files
  */
  if ( open_watchfiles() ) {
      glues::Messages::Error();
      SiSi::finalize();
#ifdef HAVE_MPI_H
      MPI::Finalize();
#endif
      return 1;
  }

  outfile=store_prep_open();
  if( outfile==NULL ) {
      glues::Messages::Error();
      SiSi::finalize();
#ifdef HAVE_MPI_H
      MPI::Finalize();
#endif
      return 1;
  }
   
  if(RunVarInd>0) set_parvector(RunVarInd,1);

  if (flucampl>0) dump_events();

  /*std::vector<RegionalPopulation> population;
  std::vector<RegionalPopulation>::iterator p_iter;
  for (i=0; i<numberOfRegions; i++) population.push_back(populations[i]);

  for (i=0; i<population.size(); i++)
      cout << populations[i].Density();


 glues::IO::define_resultfile(std::string("test.nc"),numberOfRegions);
 glues::Data data(numberOfRegions,population); */

    
  /** Run the simulation, return value on error is negative, positive return
      value indicates the goodness of the simulation
      */
  
  double err_i=simulation();
  if (err_i<0) {
      glues::Messages::Error();
      SiSi::finalize();
#ifdef HAVE_MPI_H
      MPI::Finalize();
#endif
      return 1;
  }
  /*
            screen output of global numbers
  */
  printf(_("\tTotal deviation is: %1.3f(%ld)\n"),GlobDev,(unsigned long)err_i);
  printf("\t tot_spr : %1.3f\n",tot_spr/tmax);
  printf("\t tot_pop : %1.3f\n",tot_pop/tmax*1E-6);
  printf("\t diff_dev: %2ld\n",regions[KeyCMexico].CivStart()-GlobCivStart);
  printf("\t tech_final: %1.2f\n",populations[KeyFCrescent].Technology());


  for(unsigned int i=0;i<LengthOfins;i++) if (watchfile[i]) fclose(watchfile[i]);
  fclose(outfile);
  // out_vegetation();

  /*
    Do some cleanup and exit correctly
  */
  // cleanup();

  glues::Messages::Success();
  glues::Messages::Goodbye();
  SiSi::finalize();
#ifdef HAVE_MPI_H
  MPI::Finalize();
#endif

  return 0;
}

/**
     @brief Simulation main loop
     @return double error measure to historical pattern or error flag
*/
double simulation() {

  int retval;
  int CivNum,tu=0,sync=0;
  long t,t_desert,event_i=0;
  double event_time[12]={10500,8200,7100,5500,3500,2400,600,-999},t_glac_end=8000;
  double c_i,ts,nd,omt,fer,tarea,actualfertility,t_glac;
  double tot_spr_t=0;
  FILE *spr=0,*sprt=0;
  int status;

#ifdef HAVE_NETCDF_H
  unsigned long nc_time_len = 0;
  double* nc_time = NULL;
  if (! is_restart) {
     NcFile ncout(ncfilename.c_str(),NcFile::Write);
     status=gnc_write_definitions(ncout,numberOfRegions,maxneighbours);
     ncout.close();
     if (status) return -1;
  } else {
     NcFile ncout(ncfilename.c_str(),NcFile::ReadOnly);
     NcVar * var = ncout.get_var("time");
     NcDim * dim = ncout.get_dim("time");
     nc_time_len = dim->size();
     nc_time = new double[nc_time_len];
     var->get(nc_time,nc_time_len);
     
     /** @todo: correct to n-1 (currently there are missing values at this position, fix elsewhere) */
     //cerr << " " << nc_time_len << " " <<  nc_time[0] << " " << nc_time[nc_time_len-2] << endl;
     //cerr << " " << TimeStart << " " <<  TimeStep << " " << TimeEnd << endl;
     ncout.close();
     
     // Sanity checks for restart times
     if ((TimeStart > nc_time[nc_time_len-2]) | (TimeEnd < nc_time[0]) | (TimeStart < nc_time[0])) {
       std::cerr << "TimeStart/End information outside of range in netcdf restart file" << std::endl;
       return 1;
     }
  }
#endif

  //  Exchange ex(100);

  // Reverse timing if Time is counted in BC/AD
  if (TimeStart<0) {
      if (flucampl>0) for (unsigned int i=0; i<12; i++) event_time[i]=1950-event_time[i];
      t_glac_end=1950-t_glac_end;
  }

  //  ex = new Exchange(numberOfRegions);

  if (is_restart) 
    std::cout << _("Restarting simulation for ") << numberOfRegions << endl;
  else
    std::cout << _("Starting simulation for ") << numberOfRegions << endl;    
  
  cout << _("Simulation from ") << TimeStart << " to " << TimeEnd << " with step " << TimeStep << endl;
  cout << _("Climate updates every ") << ClimUpdateTimes[0] << " years  ("
       << ClimUpdateTimes[1]  << ")" << endl;

  // If there are multiple climates, increase tu, otherwise keep it zero
  if (ClimUpdateTimes[1]>0) tu=floor(1.0*ClimUpdateTimes[0]);

  GlobalClimate pastclimate(0);
  GlobalClimate futureclimate(tu);

  if (!pastclimate.Update(0)) return -1;
  if (!futureclimate.Update(tu)) return -1;

  if (!initialize_populations(1)) return -1; // initialize populations
  //  nd=1*(ndommaxmean+ndommaxvar+spreadm*spreadv)*ndommaxcont[0]*gammab;
  nd=0.25*fabs(ndommaxmean)*(1+ndommaxvar+spreadm*spreadv)*gammab;


  if(nd*TimeStep>RelChange) {
    ts=RelChange/nd;
    if(ts<EPS) ts =EPS;
    if(!VarActive) cout << _("resetting time step to ") << ts << endl;
  } else ts=TimeStep;
  
  unsigned long restart_index=0;

#ifdef HAVE_NETCDF_H
  double * double_record = new double[numberOfRegions];
  float  *  float_record = new  float[numberOfRegions];
  int    *    int_record = new    int[numberOfRegions];
  
  if (is_restart) {
    double time_diff=1E9;
    for (unsigned int i=0; i<nc_time_len; i++) if (abs(TimeStart - nc_time[i]) < time_diff) {
      time_diff=abs(TimeStart - nc_time[i]);
      restart_index=i;
    }
    std::cout << "Restarting from index " << restart_index << " at t="  << nc_time[restart_index]<< endl;
    NcFile ncout(ncfilename.c_str(),NcFile::ReadOnly);
    gnc_read_record(ncout,"technology",&float_record,restart_index);
    for (unsigned int i=0; i< numberOfRegions; i++) populations[i].Technology(float_record[i]);
    gnc_read_record(ncout,"farming",&float_record,restart_index);
    for (unsigned int i=0; i< numberOfRegions; i++) populations[i].Qfarming(float_record[i]);
    gnc_read_record(ncout,"economies_potential",&float_record,restart_index);
    for (unsigned int i=0; i< numberOfRegions; i++) populations[i].Ndommax(float_record[i]);
    gnc_read_record(ncout,"economies",&float_record,restart_index);
    for (unsigned int i=0; i< numberOfRegions; i++) populations[i].Ndomesticated(float_record[i]);
    gnc_read_record(ncout,"population_density",&float_record,restart_index);
    for (unsigned int i=0; i< numberOfRegions; i++) populations[i].Density(float_record[i]);
    
    // Reset to time start from netCDF file to have consistent time steps, desert and
    // climate updates
    NcAtt* att = ncout.get_att("param_TimeStart");
    TimeStart=att->as_float(0); 
    att = ncout.get_att("param_TimeEnd");
    if (att->as_float(0)!=TimeEnd )
      std::cerr << "Different TimeEnd not implemented yet" << endl; 
    
    ncout.close();
  }  

#endif

  
  tmax=(long)((TimeEnd-TimeStart)/ts);
  OutStep=(int)(OutputStep/ts);


  //t_desert=(long)((SimInit-5500)/ts); Old time definition
  /** Desert occurs at 5500 BP */
  t_desert=(long)((-5500-TimeStart)/ts); // new time
  if (t_desert<0) t_desert=0;


  /**
     Open  files analysis of spread
  */
  if(!VarActive && LocalSpread>0) {
    spr=fopen(spreadstring,"w");
    sprt=fopen("spread_glob.dat","w");
  }

  /** Reset all counters */
  tot_spr=0;
  tot_pop=0;

  /** Calculate total world area */
  tarea=0;
  for (unsigned int i=0; i<numberOfRegions; i++) tarea+=regions[i].Area();

  /** Simulation loop */
  CivNum=0;

  double mean_pastclimate_npp=0, mean_region_npp=0;
  double mean_futureclimate_npp=0, mean_sahara_npp=0;
  
#ifdef HAVE_NETCDF_H  
  NcFile ncout(ncfilename.c_str(),NcFile::Write);

  if (!is_restart) {

    // Write the records for 
    // all non time-dependent variables
    for (unsigned int i=0; i<numberOfRegions; i++) float_record[i]=populations[i].Region()->Longitude();
    gnc_write_record(ncout,"longitude",&float_record);
  	for (unsigned int i=0; i<numberOfRegions; i++) float_record[i]=populations[i].Region()->Latitude();
    gnc_write_record(ncout,"latitude",&float_record);
    for (unsigned int i=0; i<numberOfRegions; i++) float_record[i]=populations[i].Region()->Id();
    gnc_write_record(ncout,"region",&float_record);
    for (unsigned int i=0; i<numberOfRegions; i++) float_record[i]=0;
    gnc_write_record(ncout,"technology_init",&float_record);
    for (unsigned int i=0; i<numberOfRegions; i++) float_record[i]=0;
    gnc_write_record(ncout,"farming_init",&float_record);
    for (unsigned int i=0; i<numberOfRegions; i++) float_record[i]=0;
    gnc_write_record(ncout,"economies_init",&float_record);
    for (unsigned int i=0; i<numberOfRegions; i++) float_record[i]=0;
    gnc_write_record(ncout,"population_density_init",&float_record);
    for (unsigned int i=0; i<numberOfRegions; i++) float_record[i]=populations[i].Region()->Area();
    gnc_write_record(ncout,"area",&float_record);
    for (unsigned int i=0; i<numberOfRegions; i++) int_record[i]=populations[i].Region()->Sahara();
    gnc_write_record(ncout,"region_is_in_sahara",&int_record);
    for (unsigned int i=0; i<numberOfRegions; i++) int_record[i]=populations[i].Region()->ContId();
    gnc_write_record(ncout,"region_continent",&int_record);
 
    int* int_neigh_record=new int[numberOfRegions*maxneighbours];
    for (unsigned int i=0; i<numberOfRegions; i++) {
      GeographicalNeighbour* gn=populations[i].Region()->Neighbour();
	    for (unsigned int j=0; j<maxneighbours; j++) {
	      if (gn) {
	        int_neigh_record[numberOfRegions*j+i]=gn->Region()->Id(); 
  	      gn=gn->Next();
  	    }
	      else int_neigh_record[numberOfRegions*j+i]=-1;
	    }
    }
    NcVar* var=ncout.get_var("region_neighbour");
    var->put(int_neigh_record,maxneighbours,numberOfRegions);
  }
#endif


  for (t=restart_index; t<=tmax; t++) {
  
    // Check whether climate needs to be update and perform necessary updates
	// @todo throw exceptions
	  while (t*ts > tu ) {
	    if (!pastclimate.Update(tu)) return -1;
	    tu=tu+ClimUpdateTimes[0];
	    if (!futureclimate.Update(tu)) return -1;
    }
      

    mean_pastclimate_npp=0; mean_region_npp=0; mean_futureclimate_npp=0;
    mean_sahara_npp=0;

    // Prefill fluctuation vector
    std::vector<double> fluctuation;
    for (unsigned int i=0; i<numberOfRegions; i++) fluctuation.push_back(1.0);


  /** @todo make this reappear based on TimeStart not SimInit, synchronous global fluctuations
    for all regions*/

/*    if(sync) {
      if (SimInit-event_time[event_i]-t*ts<t*ts-SimInit+event_time[event_i+1]) event_i++;
      omt=(SimInit-event_time[event_i]-t*ts)/flucperiod;
      fluctuation.at(i)=1-flucampl*exp(-omt*omt);
      //      fprintf(stdout,"Sync Ev_i=%d Ev_t=%f omt=%f fluc=%f\n",event_i,SimInit-event_time[event_i]-t*ts,omt,fluctuation.at(i));
    }
*/
    /*
         Loop over all regions
    */
    tot_pop_t=actualfertility=0;

    double numberOfSaharanRegions=0;

 
 /** Add a new time record to netdf file */
 #ifdef HAVE_NETCDF_H
	  if (ncout.is_valid()) { 
      NcVar* var=ncout.get_var("time");
      double time[1];
      time[0]=t*ts+TimeStart;
      var->put_rec(time,t);
	  }
#endif

    // Iterate over all regions
    for (unsigned int i=0; i<numberOfRegions; i++) {

	    fluctuation.at(i)=1.0;
	  

      // Update climate information from an interpolation of past and future climates
      regions[i].InterpolateClimate(t*ts,pastclimate.Timestamp(),futureclimate.Timestamp(),
				    pastclimate.Climate(i),futureclimate.Climate(i));
	    mean_region_npp += regions[i].Npp();
	    mean_pastclimate_npp += pastclimate.Climate(i).Npp();
	    mean_futureclimate_npp += futureclimate.Climate(i).Npp();
	    if (regions[i].Sahara()) {
	      mean_sahara_npp += regions[i].Npp();
	      numberOfSaharanRegions ++;
	    }

 
      /**
       Artificial desertification of the Sahare at 5.5 kyr BP
       is controlled by the parameter Sisi::SaharaDesert and works via
       a reduction of FEP with factor 0.9 each year over a period of 100 years
       It has only short-term influence, not important for LBK simulation
    */

      if (SaharaDesert && t>=t_desert && t<=t_desert+20 && regions[i].Sahara()) {
	      double rnpp=regions[i].Npp();
	      regions[i].Npp(rnpp*pow(0.9,t_desert-t+1.0));
      }

     /**
	   Add climate events according to proxy data for each region only if
	   global synchronization is switched off (local parameter sync)
       and fluctuation intensity is greater than zero (SISI parameter flucampl)
     */
      //cout << "No proxy events. TODO: Initialize.cc ll.312 " << endl;
     
 
      if (!sync && flucampl>0) {
     // For old Events implementation (backward)
	   
	      double t_old = 1950-(*(EventRegTime+i*MaxEvent+EventRegInd[i])) * 1;
	      double t_new = 1950-(*(EventRegTime+i*MaxEvent+EventRegInd[i]+1)) * 1;
	   
	   
	   /** 
	     Advance event pointer if next event closer 
	     Then calculate time difference to event (as variable omt) and
	     relax this with exp function and breadth flucperiod 
	   */
	      if (((t_old + t_new) < (TimeStart+t*ts)*2) ) EventRegInd[i]++;
    
	      omt=(1950-(*(EventRegTime+i*MaxEvent+EventRegInd[i]))-(TimeStart+t*ts))/flucperiod;
	      fluctuation.at(i)=1-flucampl*exp(-omt*omt);
	   
	   if (0&i==124)  cout << i << " "<< t*ts << " " << TimeStart+t*ts << " " << EventRegInd[i]
	  		<< " flucampl=" << flucampl << " fluc=" << fluctuation.at(i) << " om=" << omt << " tr=" << t_old << "-" << t_new << std::endl; 
     }
 

      // Check whether glaciated NH needs to be considered, this
	  // is controlled with SISI:LGMHoloTrans parameter and
	  // reduces the climate parameter fluc
	  //
	  // @todo replace by Peltier ICE-5G model
	  if (LGMHoloTrans) {
        double t_glac = (t_glac_end-TimeStart-t*ts)/ (t_glac_end-TimeStart);
        if(t_glac >0) {
	      float icef=IceFac(regions[i].Latitude(),regions[i].Longitude());
	      if (icef<1)
	        //fluc *= icef+(1-icef)*(1-t_glac);
	        fluctuation.at(i) *= icef+(1-icef)*(1-t_glac);
	        //float lat=regions[i].Latitude();
	        //printf("%1.0f reg %d lat=%1.2f\t%1.2f\tif=%1.1f tg=%1.1f\tfac=%1.2f\n",t*ts,i,lat,fluc,icef,t_glac,icef+(1-icef)*(1-t_glac));}
        }
      }

      regions[i].Fluctuation(fluctuation.at(i));

      /**
	  Add local population to world population
      */
      tot_pop_t+=populations[i].Size();


// ******************** End of diagnostics ***********************************
  
      // Calculate prognostic variables only for timesteps > 0
      //if (t>restart_index)	{
        retval=populations[i].Develop(TimeStep);
	      if (retval) printf("pop %d out of range:\tP=%1.1f T=%1.1f ND=%1.1f\nexit ...\n",i,populations[i].Density(),
	      populations[i].Technology(),populations[i].Ndomesticated());
	      //t=tmax;

        // Check whether we reach high development stage
        c_i=populations[i].CultIndex();
        if(c_i>CultIndex && regions[i].CivStart()<1) {
	        CivNum+=regions[i].CivStart((long int)(t*ts));
	        if(CivNum>=MaxCivNum) {
	          t=tmax;
	          if(!VarActive) printf("Maximal number of Civs (%d) reached !\n..exit...\n",CivNum);
	        }
        }
        //    actualfertility+=regions[i].NatFertility(fluc)*regions[i].Area();
        actualfertility+=populations[i].NatFert()*populations[i].Tlim()*regions[i].Area();
      }

    tot_pop+=tot_pop_t;

// ** Spread ********************************************************************
// Diffusion between regions is controlled by parameter
// param::LocalSpread
 
    if (LocalSpread)  {
      tot_spr_t = spread_all(t*ts-TimeStart);
      tot_spr += tot_spr_t;
      if( !exchange() ) t=tmax;
      fer=populations[KeyFCrescent].ActFert();
      fer=actualfertility/tarea;
      if(t%3==0 &0 && !VarActive )
	    fprintf(sprt,"%1.2f %1.2f %1.2f %1.4f\n",TimeStep*t,tot_spr_t,tot_pop_t,fer);
    }
    //      if(fabs(t*TimeStep-9400)<TimeStep)
    //	double tdiff=populations[KeyCMexico].Technology()-populations[KeyFCrescent].Technology();

// ********************** printf diagnostics *****************************************************
    if(t%200==0 &0) for(unsigned int ii=0;ii<4;ii++) {
      unsigned int i=ins[ii];
      printf("%ld %d:\t",t,i);
      printf("afert=%1.2f npp=%1.2f\t",populations[i].ActFert(),regions[i].Npp());//regions[183].NatFertility()
      printf("tech=%1.2f nd=%1.2f\t",populations[i].Technology(),populations[i].Ndomesticated());//regions[183].NatFertility()
      printf("over=%1.2f ",overexp*populations[i].Density()*populations[i].Technology());
      printf("cult=%1.2f\n",populations[i].CultIndex());
    }

// ********************** output ************************************
    if ( !VarActive && !(t%OutStep) )  // && t*TimeStep > 7000
      {
	SiSi::logFile.progress(t,tmax);
	if(LocalSpread>0) {
	  fprintf(spr,"%1.1f\t",TimeStep*t);
	  for(unsigned int i=0;i<LengthOfins;i++)
	    for(unsigned int n=0;n<4;n++)
	      fprintf(spr,"%1.4f\t",sprd[(ins[i])*N_POPVARS+n+(n>2)]*1E3);
	  fprintf(spr,"\n");
	}
	for(unsigned int i=0;i<LengthOfins;i++)
	  populations[ins[i]].Write(watchfile[i],(int)(t*ts));
      }
    if ( !VarActive && !(t%(OutStep)) ) {
      make_store();
      fwrite(&store_vector[0],sizeof(float),num_stores*numberOfRegions,outfile);
    }
    
#ifdef HAVE_NETCDF_H

	if (ncout.is_valid()) { 
	//if (ncout.is_valid() && !(t%OutStep) ) { 
	  for (unsigned int i=0; i< numberOfRegions; i++) float_record[i]=populations[i].Technology();
	  gnc_write_record(ncout,"technology",&float_record,t);
	  for (unsigned int i=0; i< numberOfRegions; i++) float_record[i]=populations[i].Qfarming();
	  gnc_write_record(ncout,"farming",&float_record,t);
	  for (unsigned int i=0; i< numberOfRegions; i++) float_record[i]=populations[i].Size();
	  gnc_write_record(ncout,"population_size",&float_record,t);
	  for (unsigned int i=0; i< numberOfRegions; i++) float_record[i]=populations[i].RelativeGrowthrate();
	  gnc_write_record(ncout,"relative_growth_rate",&float_record,t);
	  for (unsigned int i=0; i< numberOfRegions; i++) float_record[i]=populations[i].Density();
	  gnc_write_record(ncout,"population_density",&float_record,t);
	  for (unsigned int i=0; i< numberOfRegions; i++) float_record[i]=populations[i].Ndomesticated();
	  gnc_write_record(ncout,"economies",&float_record,t);
	  for (unsigned int i=0; i< numberOfRegions; i++) float_record[i]=populations[i].Ndommax();
	  gnc_write_record(ncout,"economies_potential",&float_record,t);
	  for (unsigned int i=0; i< numberOfRegions; i++) float_record[i]=populations[i].Tlim();
	  gnc_write_record(ncout,"temperature_limitation",&float_record,t);
	  for (unsigned int i=0; i< numberOfRegions; i++) float_record[i]=populations[i].ActFert();
	  gnc_write_record(ncout,"actual_fertility",&float_record,t);
	  for (unsigned int i=0; i< numberOfRegions; i++) float_record[i]=populations[i].NatFert();
	  gnc_write_record(ncout,"natural_fertility",&float_record,t);
	  for (unsigned int i=0; i< numberOfRegions; i++) float_record[i]=populations[i].Region()->Npp();
	  gnc_write_record(ncout,"npp",&float_record,t);
	  /*for (unsigned int i=0; i< numberOfRegions; i++) float_record[i]=sprdm[i];
	  gnc_write_record(ncout,"migration_density",&float_record,t);
	  for (unsigned int i=0; i< numberOfRegions; i++) float_record[i]=sprd[i*N_POPVARS+0];
	  gnc_write_record(ncout,"technology_spread",&float_record,t);
	  for (unsigned int i=0; i< numberOfRegions; i++) float_record[i]=sprd_p[i*N_POPVARS+0];
	  gnc_write_record(ncout,"technology_spread_by_people",&float_record,t);
	  for (unsigned int i=0; i< numberOfRegions; i++) float_record[i]=sprd_i[i*N_POPVARS+0];
	  gnc_write_record(ncout,"technology_spread_by_information",&float_record,t);
      for (unsigned int i=0; i< numberOfRegions; i++) float_record[i]=sprd_p[i*N_POPVARS+1];
	  gnc_write_record(ncout,"economies_spread_by_people",&float_record,t);
	  for (unsigned int i=0; i< numberOfRegions; i++) float_record[i]=sprd_i[i*N_POPVARS+1];
	  gnc_write_record(ncout,"economies_spread_by_information",&float_record,t);
	  */for (unsigned int i=0; i< numberOfRegions; i++) float_record[i]=sprd_p[i*N_POPVARS+2];
	  gnc_write_record(ncout,"farming_spread_by_people",&float_record,t);
	  
	  for (unsigned int i=0; i< numberOfRegions; i++) float_record[i]=populations[i].Region()->SuitableTemp();
	  gnc_write_record(ncout,"suitable_temperature",&float_record,t);
	  for (unsigned int i=0; i< numberOfRegions; i++) float_record[i]=populations[i].Region()->SuitableSpecies();
	  gnc_write_record(ncout,"suitable_species",&float_record,t);
	  for (unsigned int i=0; i< numberOfRegions; i++) float_record[i]=populations[i].SubsistenceIntensity();
	  gnc_write_record(ncout,"subsistence_intensity",&float_record,t);

//      for (n=4; n<N_POPVARS-1; n++) printf("%1.3f ",sprd[i*N_POPVARS+n]*1E3);

	}
    
#endif

 /* Clear spread matrix */
   for (unsigned int i=0; i<numberOfRegions; i++) sprdm[i]=0;
 

    //if (t%10==0) fprintf(stdout,"t= %f past= %f cur= %f fut= %f sah= %f\n",t*ts,mean_pastclimate_npp/numberOfRegions,mean_region_npp/numberOfRegions,mean_futureclimate_npp/numberOfRegions,mean_sahara_npp/numberOfSaharanRegions);

    //     cout<<"end time"<<endl;


    // glues::IO::writeNetCDF(ncout,t,populations);

  }
  if(!VarActive & LocalSpread>0) fclose(spr), fclose(sprt);

  return calc_deviation(CivNum);
  
#ifdef HAVE_NETCDF_H  
  ncout.close();
#endif
}
/** END of simulation() */

double pseudo_simulation() {
  int i,n,CivNum,CivNumA;
  double ts;

  if (!initialize_populations(1)) return -1; // initialize populations
  /*
       Loop over all regions
  */
  CivNumA=(int)(pow(10,random2()-1)*MaxCivNum);

  for (n=CivNum=0; n<CivNumA; n++) {
    /*
      simulates random start at random region
    */
    i=(int)(random2()*numberOfRegions);
    ts=random2()*TimeEnd;
    printf("start %d at %1.2f\n",i,ts);

    if(regions[i].CivStart()<1)
      CivNum+=regions[i].CivStart((long int)(random2()*TimeEnd));
  }
  return calc_deviation(CivNum);
}

/**
   Normalizing deviation from global history pattern
*/
unsigned long int calc_deviation(unsigned long int CivNum)
{
  unsigned long int i=0;
  unsigned long int n=RowsOfdata_agri_start;
  unsigned long int dev;
  unsigned long int ne=0;

  /**
     Attribute error for lacking civilizations
  */
  for(i=ne=0;i<n;i++) {
    GlobDev+=s_error*OldCivHit[i];
    ne+=OldCivHit[i];
  }

  if(!VarActive) cout << ne << _(" civs missed (") << s_error
		      << _(")\t") << NewCivNum
		      << _(" new civs found") << endl;

  /**
     Tolerating few new "hidden" civilizations
  */
  if(!VarActive &0)
    for(i=0;i<NewCivNum &&i<NewCivMaxNum ;i++) {
      cout<<"Tolerate Civ "<<NewCivInd[i]<<" at ";
      cout<<NewCivTime[i]<<"\tw err "<<NewCivDev[i]<<endl;
    }

  /**
     Adding remaining civilizations to total error
  */
  if(NewCivNum>NewCivMaxNum)
    for(i=NewCivMaxNum;i<NewCivNum;i++) {
      GlobDev+=NewCivDev[i];
      if(!VarActive) {
	cout<<"Ind. CivStart "<<NewCivInd[i]<<" at ";
	cout<<NewCivTime[i]<<"\tw err "<<NewCivDev[i]<<endl;
      }
    }

  dev=(unsigned long int)(65536*GlobDev/(n*s_error));
  //return ( dev>65535 ? 65535  : dev );
  return dev;
}


 void dump_events() {

     std::fstream fse("eventregtime.tsv",std::ios::out);
     std::fstream fsl("eventmodel.m",std::ios::out);

     fsl << "timestep=" << TimeStep << ';' << endl;
     fsl << "timestep=" << TimeStep << ';' << endl;
     fsl << "timeend=" << TimeEnd <<  ';' <<endl;
     fsl << "siminit=" << TimeStart <<  ';' <<endl;
     fsl << "maxevent=" << MaxEvent <<  ';' <<endl;
     fsl << "flucampl=" << flucampl << ';' << endl;
     fsl << "flucperiod=" << flucperiod << ';' << endl;

     fsl.close();

     for (unsigned int i=0; i< numberOfRegions; i++) {
	 for (unsigned int j=0; j<MaxEvent; j++) {
	     fse << EventRegTime[i*MaxEvent+j] << " ";
	 }
	 fse << endl;
     }
     fse.close();

     return;
 }
 

 
 
/** EOF Glues.cc */
