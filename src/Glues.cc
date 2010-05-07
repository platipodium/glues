/* GLUES main program; this file is part of
   the Global Land Use and technological Evolution Simulator

   Copyright (C) 2001,2002,2003,2004,2005,2006,2007,2008,2009,2010
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
   @date   2010-02-24
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
#include "Data.h"
#include "GNetcdf.h"
#include <vector>

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
extern double spread_all();
void dump_events();

/**
  Main program incl. pre- & postprocessing
*/
int main(int argc, char* argv[])
{

  
  double err_i;

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

/** Parse the simulation parameters in the SiSi configuration.
  @todo There should be in the future an alternative configuration which
  does not rely on SiSi.  This could be achieved with a converter from SiSi 
  to Namelist and vice versa, or with a parallel development */
  if( !SiSi::parseSimulation(argc, argv) ) {
#ifdef HAVE_MPI_H
      if (mpi_rank==0)
#endif
	  glues::Messages::Error();

      SiSi::finalize();
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

  dump_events();


  /*std::vector<RegionalPopulation> population;
  std::vector<RegionalPopulation>::iterator p_iter;
  for (i=0; i<numberOfRegions; i++) population.push_back(populations[i]);

  for (i=0; i<population.size(); i++)
      cout << populations[i].Density();


 glues::IO::define_resultfile(std::string("test.nc"),numberOfRegions);
 glues::Data data(numberOfRegions,population); */

    
  /** Run the simulation */
  
  err_i=simulation();
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

  int status=0;
  int retval;
  int CivNum,tu=0,i,ii,sync=0;
  long t,t_desert,event_i=0;
  double SimInit=12000,event_time[12]={10500,8200,7100,5500,3500,2400,600,-999},t_glac_end=8000;
  double c_i,ts,nd,omt,fer,tarea,actualfertility,t_old,t_new,t_glac;
  double tot_spr_t=0;
  FILE *spr=0,*sprt=0;

#ifdef HAVE_NETCDF_H
  NcFile ncout("test.nc",NcFile::Replace);
  status=gnc_write_header(ncout,numberOfRegions);
  if (status) return -1;
#endif

  //  Exchange ex(100);

  if (TimeStart<0) {
      SimInit=-10000;
      for (i=0; i<12; i++) event_time[i]=2000-event_time[i];
      t_glac_end=2000-t_glac_end;
  }

  //  ex = new Exchange(numberOfRegions);

  cout << _("Starting simulation for ") << numberOfRegions << endl;
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
  }
  else ts=TimeStep;
  tmax=(long)((TimeEnd-TimeStart)/ts);
  OutStep=(int)(OutputStep/ts);
  t_desert=(long)((SimInit-5500)/ts);

  if (TimeStart < 0) t_desert=(long)((TimeEnd-TimeStart-5500)/ts); // new time

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
  
  
  /** Write the record for all non time-dependent variables */
  float * float_record = new float[numberOfRegions];
  int   *   int_record = new   int[numberOfRegions];
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
  

  for (t=0; t<tmax; t++) {

      mean_pastclimate_npp=0; mean_region_npp=0; mean_futureclimate_npp=0;
      mean_sahara_npp=0;
    /*
      synchronous global fluctuations/unfavorable
      conditions
    */
    //    flucperiod=1500*0.4/(flucampl+0.01);
    /*    omt=cos(t*ts*PI/flucperiod);
	  fluc=1-flucampl*omt*omt*omt*omt;
	  if(fluc<0) fluc=0;
    */
    t_glac = (SimInit-t*ts-t_glac_end)/(SimInit-t_glac_end);

    if (TimeStart < 0 ) t_glac = (t_glac_end-TimeStart-t*ts)/ (t_glac_end-TimeStart);

    if(sync) {
      if(SimInit-event_time[event_i]-t*ts<t*ts-SimInit+event_time[event_i+1]) event_i++;
      omt=(SimInit-event_time[event_i]-t*ts)/flucperiod;
      fluc=1-flucampl*exp(-omt*omt);
      //      fprintf(stdout,"Sync Ev_i=%d Ev_t=%f omt=%f fluc=%f\n",event_i,SimInit-event_time[event_i]-t*ts,omt,fluc);
    }

    /*
      Check whether we need to update climate information, if so
      perform the update
    */
    if (t*ts > tu ) {
	  if (!pastclimate.Update(tu)) return -1;
	  tu=tu+ClimUpdateTimes[0];
	  if (!futureclimate.Update(tu)) return -1;
    }
    ice_fac=1;
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

 
   /**
       Iterate over all regions
    */
    for (i=0; i<numberOfRegions; i++) {


	mean_region_npp += regions[i].Npp();
	mean_pastclimate_npp += pastclimate.Climate(i).Npp();
	mean_futureclimate_npp += futureclimate.Climate(i).Npp();
	if (regions[i].Sahara()) {
	    mean_sahara_npp += regions[i].Npp();
	    numberOfSaharanRegions ++;
	}

      /**
	 Update climate information from an interpolation of past and future climates
      */
      regions[i].InterpolateClimate(t*ts,pastclimate.Timestamp(),futureclimate.Timestamp(),
				    pastclimate.Climate(i),futureclimate.Climate(i));

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
     if(!sync) {
	t_old = SimInit-*(EventRegTime+i*MaxEvent+EventRegInd[i])-t*ts;  // check for updated index to event series
	t_new = t*ts-SimInit+*(EventRegTime+i*MaxEvent+EventRegInd[i]+1);
	if(t_old<t_new) EventRegInd[i]++;

	omt=(SimInit-*(EventRegTime+i*MaxEvent+EventRegInd[i])-t*ts)/flucperiod;
	fluc=1-flucampl*exp(-omt*omt);
	//if(t%10==10 && (i==79||i==82|| i==150) )
	if (fluc < 1 & 0)
	  {
	    cout<<t*ts<<"\t"<<i<<":"<<EventRegInd[i]<<" fluc="<<fluc<<" om="<<omt<<"\t t1=";
	    cout<<*(EventRegTime+i*MaxEvent+EventRegInd[i])<<"\t t2=";
	    cout<<*(EventRegTime+i*MaxEvent+EventRegInd[i]+1)<<endl;
	    }
      }
     //fluc=1.0;


      /**
	 Emulation of climate transition after LGM in Northern Hemisphere controlled with
	 parameter param::LGMHoloTrans
      */
      if(t_glac >0 && LGMHoloTrans ) {
	float lat=regions[i].Latitude();
	float icef=IceFac(regions[i].Latitude(),regions[i].Longitude());
	//if(i%100==-50 & t%10==0)
	//printf("%1.0f reg %d lat=%1.2f\t%1.2f\tif=%1.1f tg=%1.1f\tfac=%1.2f\n",t*ts,i,lat,fluc,icef,t_glac,icef+(1-icef)*(1-t_glac));
	fluc*= icef+(1-icef)*(1-t_glac);
      }

      /**
	  Add local population to world population
      */
      tot_pop_t+=populations[i].Size();

      /**
	 Evolution of functional traits and population growth
      */
      //if (regions[i].Npp()>MIN_NPP) {
	retval=populations[i].Develop(TimeStep);
	if (retval) printf("pop %d out of range:\tP=%1.1f T=%1.1f ND=%1.1f\nexit ...\n",i,populations[i].Density(),
			   populations[i].Technology(),populations[i].Ndomesticated());
	//t=tmax;
	//}

      /**
	 Check whether we reach high development stage
      */
      c_i=populations[i].CultIndex();
      if(c_i>CultIndex && regions[i].CivStart()<1) {
	CivNum+=regions[i].CivStart((long int)(t*ts));
	if(CivNum>=MaxCivNum) {
	  t=tmax;
	  if(!VarActive)
	    printf("Maximal number of Civs (%d) reached !\n..exit...\n",CivNum);
	}
      }
      //    actualfertility+=regions[i].NatFertility(fluc)*regions[i].Area();
      actualfertility+=populations[i].NatFert()*populations[i].Tlim()*regions[i].Area();
    }

    tot_pop+=tot_pop_t;

    /**
       Diffusion between regions is controlled by parameter
       param::LocalSpread
    */
    if (LocalSpread>0)	{
      tot_spr_t = spread_all();
      tot_spr += tot_spr_t;
      if( !exchange() ) t=tmax;
      fer=populations[KeyFCrescent].ActFert();
      fer=actualfertility/tarea;
      if(t%3==0 &0 && !VarActive )
	fprintf(sprt,"%1.2f %1.2f %1.2f %1.4f\n",TimeStep*t,tot_spr_t,tot_pop_t,fer);
      //       fprintf(sprt,"%1.2f %1.2f %1.2f %1.2f\n",TimeStep*t,tot_spr_t,tot_pop_t,actualfertility/tarea);

    }
    //      if(fabs(t*TimeStep-9400)<TimeStep)
    //	double tdiff=populations[KeyCMexico].Technology()-populations[KeyFCrescent].Technology();

    if(t%200==0 &0) for(ii=0;ii<4;ii++) {
      i=ins[ii];
      printf("%ld %d:\t",t,i);
      printf("afert=%1.2f npp=%1.2f\t",populations[i].ActFert(),regions[i].Npp());//regions[183].NatFertility()
      printf("tech=%1.2f nd=%1.2f\t",populations[i].Technology(),populations[i].Ndomesticated());//regions[183].NatFertility()
      printf("over=%1.2f ",overexp*populations[i].Density()*populations[i].Technology());
      printf("cult=%1.2f\n",populations[i].CultIndex());
    }
    /*for (i=0; i<numberOfRegions; i++)
      { printf("%d %d:",t,i);
      for (n=4; n<N_POPVARS-1; n++) printf("%1.3f ",sprd[i*N_POPVARS+n]*1E3);
      cout<<endl;} */
    /*
      output information  for evaluation
    */
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
	  for (unsigned int i=0; i< numberOfRegions; i++) float_record[i]=sprdm[i];
	  gnc_write_record(ncout,"migration_density",&float_record,t);
	}
    
#endif

 /* Clear spread matrix */
   for (int i=0; i<numberOfRegions; i++) sprdm[i]=0;
 

    //if (t%10==0) fprintf(stdout,"t= %f past= %f cur= %f fut= %f sah= %f\n",t*ts,mean_pastclimate_npp/numberOfRegions,mean_region_npp/numberOfRegions,mean_futureclimate_npp/numberOfRegions,mean_sahara_npp/numberOfSaharanRegions);

    //     cout<<"end time"<<endl;


    // glues::IO::writeNetCDF(ncout,t,populations);

  }
  if(!VarActive & LocalSpread>0) fclose(spr), fclose(sprt);

  return calc_deviation(CivNum);
  
  ncout.close();
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
     fsl << "siminit=" << 12000 <<  ';' <<endl;
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
