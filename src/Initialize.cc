/* GLUES initialization; this file is part of
   the Global Land Use and technological Evolution Simulator
   
   Copyright (C) 2001,2002,2003,2004,2005,2006,2007,2008,2009
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
   @date   2008-01-07
   @file Initialization.cc
   @brief Initialize all data
*/

#include "callSiSi.hh"
#include "Globals.h"
#include "GlobalClimate.h"        
#include "Messages.h"
#include <vector>

extern unsigned int read_region_eventradius(const std::string&,int**);

double LeftFromSep (String );
double RightFromSep (String );
int    generate_varlist();
unsigned long l0,l1=2147483648u;
double cnd[12];
string store_names[N_OUTVARS],variat_names[N_VARIAT];
std::ofstream ofs;

/*------------------------------------------------------------------*/
/*    Add climate event according to proxy data for each region     */
/*------------------------------------------------------------------*/
int set_events()
{
    signed int loop=1,num_ev,num_prox,i,j,pe,iall=0,jj,n,pj,EventSeriesLen;
    double evfreq_avg,evfreq_avg_all=0;
	//double omt;
	double TotDist,HalfDist=100.,SimInit=12,RecWeight[22];
    double mintime,wsum,sermax,sermin,*EventSeries,*EventWeight ;
    
/*----------------------------------------------------------------------*/
/*   allocate memory for region specific Index and event-Time arrays    */
/*----------------------------------------------------------------------*/
    EventRegTime= (double *)(malloc(numberOfRegions*MaxEvent*sizeof(double)));
    EventRegInd = (int *)(malloc(numberOfRegions*sizeof(int)));
    EventRegNum = (int *)(malloc(numberOfRegions*sizeof(int)));
    EventSeries = (double *)(malloc(MaxEvent*MaxProxyReg*sizeof(double)));
    EventWeight = (double *)(malloc(MaxEvent*MaxProxyReg*sizeof(double)));
    
    /** Test correctness of EventInReg file */
    if (1) {
	ofs.open("test_EventInReg.dat",ios::out);
	for (i=0; i<numberOfRegions; i++) {
	    for (j=0; j<MaxProxyReg-1; j++) 
		ofs << RegSiteInd[j][i] << " " ;
	    ofs << RegSiteInd[j][i] << endl; 
	}
    }
    
    
/** loop over regions to integrate all event series  
    notice the loop switch (default set to 1)
*/
    for (i=0;  loop &&  i<numberOfRegions; i++) 
    {
	if(RegSiteInd[0][i]<0) {
	    EventRegInd[i]=0,EventRegNum[i]=-1;
	    continue; // prefer continue to avoid deep else structure
	}
           
	/*--------------------------------------------------------*/
	/*   loop over all indexed time series for each region    */
	/*--------------------------------------------------------*/
	for (j=0,num_ev=num_prox=0,TotDist=evfreq_avg=sermax=sermin=0; j<MaxProxyReg; j++)  
	{
	    n=RegSiteInd[j][i];
	    if (n<0) break; 
	    if (n==0) {
		cerr << "ERROR. Proxy index [" << i << "][" << j 
		     << "] cannot be zero." << endl;
		return 0;
	    }

	    /* count events for each regional series */
	    for (pe=0; *(EventTime+pe+(n-1)*MaxEvent)>0 && pe<MaxEvent;pe++);  
		
	    if (pe<=0) 
	    {
		cerr << "ERROR. Number of events is zero. Check events file (" 
		     << n << "/" << i << "/" << j <<  ")" << endl;
		return 0;
	    }
		    
	    num_ev+=pe;
	    num_prox++;
	    /*-------------------------------------------------------------------*/
	    /*   calculate distance dependend weight factor for found records    */
	    /*-------------------------------------------------------------------*/
	    RecWeight[j]=HalfDist/(HalfDist+RegSiteRad[j][i]);
	    TotDist+=RecWeight[j] ;
	    
	    evfreq_avg+=pe/(EventSerMax[n-1]-EventSerMin[n-1])*RecWeight[j];
	    sermax+=EventSerMax[n-1]*RecWeight[j];
	    sermin+=EventSerMin[n-1]*RecWeight[j];
	   
	    if (0) {
		cout << i << "/" << j << ": " << pe << " " << n << " " << RecWeight[j] << " " 
		     << num_ev << " " << num_prox << " " 
		     << EventSerMax[n-1] << "-" << EventSerMin[n-1] 
		     << " " << evfreq_avg << endl; 
	    }
	    
	    if (0 && (i==0 ||i==211 || i==271 || i== 156))
	    { 
		cerr <<n<<" :\t";
		for(pe =0; *(EventTime+pe+(n-1)*MaxEvent)>0 && pe<MaxEvent;pe++)
		    cerr << *(EventTime+pe+(n-1)*MaxEvent)<<"\t";
		cerr << endl<<RecWeight[j]<<"\t"<<EventSerMin[n-1]<<endl;  
	    }
	    
	}
	/*-------------------------------------------------------------------*/
	/*   normalize distance dependend weight factor for found records    */
	/*-------------------------------------------------------------------*/
	for (j=0; j<MaxProxyReg; j++) if ( RegSiteInd[j][i]>0 ) RecWeight[j]/=TotDist;
	evfreq_avg/= TotDist;   
	sermax /= TotDist;   
	sermin /= TotDist;   
	evfreq_avg_all+=evfreq_avg; iall++;
	
	//cout <<"TotDist="<<TotDist<<"\t"<<RecWeight[0]<<":"<<RegSiteRad[0][i]<<"\t"<<sermax<< endl;    
 
//  if (0 && (i==0 || i==211 || i==271 || i== 156))
	//cout <<i<<" prox=" <<num_prox<<" tevents="<<num_ev <<"\tevents="<<evfreq_avg*(sermax-sermin)<<endl;
    
	/*----------------------------------------------------------------------------*/
	/*      initialize newly synthesized event series with first proxy record     */
	/*----------------------------------------------------------------------------*/
	for (n = RegSiteInd[0][i],j=0;*(EventTime+j+(n-1)*MaxEvent)>0 && j<MaxEvent;j++ )
	{
	    *(EventSeries+j)=*(EventTime+j+(n-1)*MaxEvent);
	    EventWeight[j]=RecWeight[0];
	}
     
	EventSeriesLen=j; 
	
	if(num_prox>1)
	{
	    // temporal order of all events 
	    for (j=1; j<MaxProxyReg; j++)
		if((n = RegSiteInd[j][i]) >=0)      
		    for(pe=0; *(EventTime+pe+(n-1)*MaxEvent)>0 && pe<MaxEvent;pe++)
		    {
			for(jj =0; *(EventTime+pe+(n-1)*MaxEvent)> *(EventSeries+jj)&&jj<EventSeriesLen;jj++);
			EventSeriesLen++;
			if(jj<EventSeriesLen-1)
			{
			    for(pj =EventSeriesLen; pj>jj; pj--)
			    {
				*(EventSeries+pj)=*(EventSeries+pj-1);
				EventWeight[pj]=EventWeight[pj-1];
			    }
			    *(EventSeries+jj)=*(EventTime+pe+(n-1)*MaxEvent);
			    EventWeight[jj]=RecWeight[j];
			}
			else
			    *(EventSeries+EventSeriesLen-1)=*(EventTime+pe+(n-1)*MaxEvent),
				EventWeight[EventSeriesLen-1]=RecWeight[j];
			
		    }
	    
/*	   cout << endl<< endl; 
	   for (j=0;j< EventSeriesLen;j++ ) cout << *(EventSeries+j)<<"\t";
	   cout << endl; 
	   for (j=0;j< EventSeriesLen;j++ ) cout << EventWeight[j]<<"\t";
	   cout << endl<< endl; 	       */  
	    /*---------------------------------------------------*/
	    /*       merge two close events 1.5*flucperiod       */
   /*---------------------------------------------------*/ 
	    for(pe=0;pe<2;pe++)   
		for (j=0,mintime=SimInit;j< EventSeriesLen-1;j++ )
		    if(*(EventSeries+j+1)-*(EventSeries+j)<1.5*flucperiod*1E-3) 
		    {
			jj=j;   
//            cout <<jj<<" merge "<< *(EventSeries+j+1)<<":"<<*(EventSeries+j)<< "\t"<<EventSeriesLen<< endl; 
			
			// new event time in the weighted mean
			*(EventSeries+jj)=(*(EventSeries+jj+1)*EventWeight[jj+1]+*(EventSeries+jj)*EventWeight[jj]);
			// update weighting coefficient	
			wsum =  (EventWeight[jj+1]+EventWeight[jj]);   
			EventWeight[jj]=(EventWeight[jj+1]*EventWeight[jj+1]+EventWeight[jj]*EventWeight[jj]);
			
			*(EventSeries+jj)/= wsum;
			EventWeight[jj]/= wsum;	      
			
	   // shift all higher entries down in order to preserve continous and ranked series
			for(pj =jj+1; pj<EventSeriesLen; pj++) *(EventSeries+pj)=*(EventSeries+pj+1),EventWeight[pj]=EventWeight[pj+1];
			EventSeriesLen--;  	     
		    }
    /*--------------------------------------------------*/
    /*      calculate integral number of events (II)    */
    /*--------------------------------------------------*/
	    pe =floor(evfreq_avg*1.0*(sermax-sermin)); 
	    if (pe < 0 || sermax<0 || sermin<0) 
	    {
		cerr << "ERROR. Number of events must be integral (" 
		     << pe << "/" << evfreq_avg << "/" << sermax << "/" 
		     << sermin << ")" << endl;
		return 0;
	    }     
	    
	    /*-----------------------------------------------------------------*/
	    /*     merge closest events until averaged event freq is reached   */
	    /*-----------------------------------------------------------------*/   
	    while(EventSeriesLen>pe)
// TODO: this is an infiinite loop on grpsrv07 ll 200-216
	    {	
	  
		// find minimal gap between events 
		for (j=0,mintime=SimInit;j< EventSeriesLen-1;j++ )
		    if(*(EventSeries+j+1)-*(EventSeries+j)<mintime) mintime=*(EventSeries+j+1)-*(EventSeries+j),jj=j;   
		
//       cout <<i<<":"<<jj<<":"<< mintime<<"\tLen="<<EventSeriesLen<<"\tpe="<<pe<< endl; 
    
		// new event time in the weighted mean
		*(EventSeries+jj)=(*(EventSeries+jj+1)*EventWeight[jj+1]+*(EventSeries+jj)*EventWeight[jj]);
	      
		// update weighting coefficient	            
		wsum =  (EventWeight[jj+1]+EventWeight[jj]);   
		EventWeight[jj]=(EventWeight[jj+1]*EventWeight[jj+1]+EventWeight[jj]*EventWeight[jj]);
		
		*(EventSeries+jj)/= wsum;
		EventWeight[jj]/= wsum;	      
		
	   // shift all higher entries down in order to preserve continous and ranked series
		for(pj =jj+1; pj<EventSeriesLen; pj++) *(EventSeries+pj)=*(EventSeries+pj+1),EventWeight[pj]=EventWeight[pj+1];
		EventSeriesLen--; 
		
	    }
	} // end num_prxy>1
	else
	    for (j=0,mintime=SimInit;j< EventSeriesLen-1;j++ )
		if(*(EventSeries+j+1)-*(EventSeries+j)<1.5*flucperiod) 
		{
		    jj=j;   
		    //     cout <<jj<<":"<< mintime<< endl<< endl; 
		    *(EventSeries+jj)=0.5*(*(EventSeries+jj+1)+*(EventSeries+jj));
		    for(pj =jj+1; pj<EventSeriesLen; pj++) *(EventSeries+pj)=*(EventSeries+pj+1);
		    EventSeriesLen--;    
		}       
      
   
	if (0 && (i==0 || i==211 || i==271 || i== 156))  
	{ for (j=0;j< EventSeriesLen;j++ ) cout << *(EventSeries+j)<<"\t";
	cout << endl; 
	cout <<i<<":"<< EventSeriesLen << endl<< endl; }    
	
	/*-----------------------------------------------------------------------------*/
	/*   add early Holocene events for shortended proxies and/or high event freq   */
	/*-----------------------------------------------------------------------------*/   
	if( (n=(int)((TimeEnd*1E-3-sermax)*evfreq_avg)) >= 1 && sermax> *(EventSeries+EventSeriesLen-1))
	{
	    for (j=0;j< n;j++,EventSeriesLen++ )
		*(EventSeries+EventSeriesLen)= sermax+(j+0.5)/evfreq_avg;    
	    if (0 && (i==0 || i==211 || i==271 || i== 156))  cout <<"add "<< sermax<<" "<< sermax+(j+0.5)/evfreq_avg<< endl;
	}
	
	/*---------------------------------------------*/
	/*     store final event sequence into array   */
	/*---------------------------------------------*/   
	EventRegInd[i]=0;
	EventRegNum[i]=EventSeriesLen;
	for (j=0;j< EventSeriesLen;j++ )
	    *(EventRegTime+i*MaxEvent+j)= *(EventSeries+EventSeriesLen-1-j)*1E3;
	if(j<MaxEvent) for (;j< MaxEvent;j++ ) *(EventRegTime+i*MaxEvent+j)=-9999;        
     
	/*--------------------------------------------------------------------------------*/
	/*      add late Holocene events for shortended proxies and/or high event freq    */
	/*--------------------------------------------------------------------------------*/   
	if( (n=(int)((sermin)*evfreq_avg)) >= 1 && sermin < *(EventSeries))
	{
	    for (j=0;j< n;j++,EventSeriesLen++, EventRegNum[i]++)
		*(EventRegTime+i*MaxEvent+EventSeriesLen)= (sermin-(j+0.5)/evfreq_avg)*1E3;    
	    if (0 && (i==0 || i==211 || i==271 || i== 156))  cout <<"add "<< sermin<<" "<< sermin-(j+0.5)/evfreq_avg<< endl;
	} 
	
	if (0 && (i==0 || i==211 || i==271 || i== 156))  
	{ 
	    for (j=0;j< EventRegNum[i];j++ ) cout << *(EventRegTime+i*MaxEvent+j)<<"\t";
	    cout << endl; 
	    cout <<i<<" final ev-number="<< EventRegNum[i] << endl<< endl; }          
    }  
    
    return 1;
}

/*----------------------------------------------------*/
/*   read data files and 
     initialize global simulation variables        */
/*----------------------------------------------------*/
vector<PopulatedRegion>::size_type  RegionProperties(vector<PopulatedRegion>);

int read_data() {

  init_names();         // prepares file name strings

  vector<PopulatedRegion> region;
  vector<PopulatedRegion>::size_type nregion;

  nregion=RegionProperties(region);

  cout << "Read " << nregion << " regions" << endl;
  // if nregions=0 return 1;

  if (!read_neighbours()) return 0;  // calculate neighbour regions 
 
  // Mapping data ist not needed, but optional (not used yet, i.e.
  // for remapping of regions
  // if (!read_mapping()) return 0;

  if (GlobalClimate::InitRead(climatestring) < 1) return 0;
  
  if (!read_proxyevents()) return 0;  //  

  //cout << "No proxy events. TODO: Initialize.cc ll297 " << endl;
  if (!read_SiteRegfile()) return 0;  //  

  char fname[199], *radn;

  strcpy(fname,datapath);
  strcat(fname,SiteRegfile);

  radn=strstr(fname,"Reg");
  if (radn != NULL) {
    strcpy(radn,"Rad.dat");
  }
  else {
    // temporary fix for new name of file
    radn=strstr(fname,"events.tsv");
    strcpy(radn,"eventradius.tsv");
  }

  //if (!read_SiteRadfile()) return 0;  //  
  for (unsigned int j=0; j<(unsigned int)MaxProxyReg; j++) RegSiteRad[j]=(int *)(malloc(numberOfRegions*sizeof(int)));

  if (read_region_eventradius(std::string(fname),RegSiteRad)==0) return 0;
  
  /* --------------------------------------------------------------- */
  /* if environmental conditions change, update region information
     and population maximal traits: currently only at t=0 !!        */
  /* --------------------------------------------------------------- */
  // if (t == timepoints[climatedatacounter]/TimeStep)
//  cout << "Climate data update at " << regenerate << " years\n";
  if(regenerate<0.1/TimeStep) RegOn=1;
  else  RegOn=0;

 // out_vegetation();
 // out_boxes();
  //cout << "No proxy events. TODO: Initialize.cc ll.312 " << endl;
  if (!set_events()) return 0;
  
  return 1;
}

/*--------------------------------------------*/
/*  Initialize handles and
    global control variables         */
/*--------------------------------------------*/
int initialize() {
  unsigned int MaxNew=(unsigned int)(0.5*numberOfRegions+1);
  /* ----------------------------------------------- */
  /*      Initialize  global/simulation values       */
  /* ----------------------------------------------- */
  sprd = new double[N_POPVARS*numberOfRegions];
  sprdm = new double[numberOfRegions+2];
  NewCivInd = new int[MaxNew];
  OldCivHit= new int[RowsOfdata_agri_start];
  NewCivDev= new double[MaxNew];
  NewCivTime= new double[MaxNew];
  NewCivDist=1.5E3;
  NewCivMaxNum=(int)(0.5*(MaxCivNum-RowsOfdata_agri_start));
  
  // cropfertility = NPPCROP/(NPPCROP+kappa);
  cropfertility = 1;
  
  //cout <<"\nTmax_step="<<tmax<<"\tOutStep="<<OutStep<<endl;
  if(RowsOfdata_agri_start>0)
    s_error=12E3/RowsOfdata_agri_start*
      (data_agri_start[0][0]-
       data_agri_start[RowsOfdata_agri_start-1][0])
      +NewCivDist*Space2Time;
  else
    s_error=0;
  
  //cout<<s_error<<" "<<NewCivMaxNum<<" "<<MaxNew<<endl;
  num_stores=num_variat=0;

  /*--------------------------------------------*/
  /*   save C++ list "OutputVariables"          */
  /*--------------------------------------------*/
  TwoWayList* el = NULL;
  //  TwoWayListElement* ele = NULL;
  el = SiSi::OutputVariables;
  ResultParameter* el2 = (ResultParameter*) el->resetIterator();
  while( el2 ) {
    if(el2->isActive()) {
        store_names[num_stores++]=el2->getName(); 
        //strcpy(store_names[num_stores++],el2->getName());
    }
    el2 = (ResultParameter*) el->nextElement();
  }
  
  /*--------------------------------------------*/
  /*   save C++ list "VariationVariables"       */
  /*--------------------------------------------*/
  num_total_variat=1;
  el = SiSi::VariationVariables;
  el2 = (ResultParameter*) el->resetIterator();
  unsigned int d;
  
  while( el2 ) {
    if(el2->isActive() ) {
      //   MessageHandler::information(el2->getName());
      //strcpy(variat_names[num_variat],el2->getName());
      variat_names[num_variat]=el2->getName();
      /*------------------------------------------------*/
      /*      Identification according name string      */
      /*------------------------------------------------*/
      for(d=0;d<(unsigned int)num_variat_parser;d++)
	if(strcmp(VAR_NAMES[d],variat_names[num_variat].c_str())==0) {
	  par_val[num_variat]=VAR_VAL[d];
	  //  cout << num_variat<<" -> "<<d<<"\n";
	  d=(unsigned int)num_variat_parser+3;
	}
      if(d<(unsigned int)num_variat_parser+2)
	cout << variat_names[num_variat]<<" not found in callSiSi.cc !!\n";
      
      /*------------------------------------------------*/
      /*     Setting min, max & step of variation       */
      /*------------------------------------------------*/
      variat_min[num_variat]=LeftFromSep(el2->getRange());
      double max = RightFromSep(el2->getRange());
      variat_steps[num_variat] = (int) el2->getPrecision();
      
      //   cout << variat_names[num_variat] << " :" << variat_steps[num_variat];
      //   cout << " max=" << max << " min=" <<  variat_min[num_variat];
      //   cout << " addr_1=" << VAR_VAL[num_variat];
      //   cout<<END_OF_LINE;
      
      if(max >variat_min[num_variat] && variat_steps[num_variat] > 1) {
	  variat_delt[num_variat]=(max-variat_min[num_variat])/(variat_steps[num_variat]-1);
	  num_total_variat*=variat_steps[num_variat++];
	}
      else
	{
	  //     variat_min[num_variat]=*VAR_VAL[num_variat];
	  variat_delt[num_variat++]=0;
	}
    }
    el2 = (ResultParameter*) el->nextElement();
  }
  
  if(num_variat!=(unsigned long)num_variat_parser) {
    cout << num_variat << " ACTIVE variation_pars found, ";
    cout << num_variat_parser;
    cout << " at maximum expected from parsing files...\n";
  }

  /*---------------------------------------------*/
  /*    writes all float parameters in
	file with list VariationVariables        */
  /*---------------------------------------------*/
  //    generate_varlist();
  for (int i=0; i<numberOfRegions; i++) sprdm[i]=0;

  return 1;
}

int generate_varlist() {
  ofstream file;
  FILE  *sp;
  double val;
  cout << _("writing VariationVariables in varlist.ins...\n");
  sp=fopen("varlist.ins","w");
  //  file.open("varlist.ins",ios::out);
  for(unsigned int i=0;i<(unsigned int)num_variat_parser;i++) {
    fprintf(sp,"\tresult\t%s\n",VAR_NAMES[i]);
    fprintf(sp,"\t\ttype \tfloat\n");
    val=*VAR_VAL[i];
    fprintf(sp,"\t\t\\r %2.4f:%2.4f\n",0.5*val,1.5*val);
    fprintf(sp,"\t\tactive\ttrue\n");
    fprintf(sp,"\t\tprecision\t3\n");
  }
  fclose(sp);
  //  file.close();
  return 0;
}

/*-------------------------------------------------*/
/*  2 routines which split a string into 2 halfes  */
/*-------------------------------------------------*/

double RightFromSep (String s) {
  bool sepin = false;
  double val;
  String result = "";
  for( unsigned int i=0; i<(unsigned int)s.length(); i++ ) {
    if(sepin) result += s.charAt(i);
    if( s.charAt(i) ==':') sepin = true;
  }
  val = (double) atof(result);
  return (double) val; 
}

double LeftFromSep (String s) {
  double val;
  String result = "";
  for(unsigned  int i=0; i<(unsigned int)s.length(); i++ )
    if( s.charAt(i) !=':') result += s.charAt(i);
    else break;
  
  val = (double) atof(result);
  return val; 
}

/*----------------------------------------------------*/
/*     Translates name string to index number         */
/*----------------------------------------------------*/
int get_popvar_ind(std::string & search) {
  int ok=-1;
  for (int i=0;strstr(state_names[i].c_str(),"END")==NULL && (ok<0);i++)
    if ( strstr(search.c_str(),state_names[i].c_str())  !=NULL) ok=i;
  return ok;
}

/*----------------------------------------------------*/
/*     Stores all output variable into vector         */
/*----------------------------------------------------*/
int make_store() {
  unsigned int i,j,ind;
  //float sum,f,suml;
  for (i=0; i<(unsigned int)num_stores; i++)
    for (j=0, ind=store_ind[i]; j<numberOfRegions; j++) {
      store_vector[i*numberOfRegions+j]=populations[j].IndexedValue(ind);
      //     if(i==7 && j==184)
      //       printf("%d res:%d ind:%d\t %1.3f\n",j,i,ind,populations[j].return_indvalue(ind));
    }
  return 0;
}

/*---------------------------------------------*/
/*   prepares and opens binary result output   */
/*---------------------------------------------*/
FILE* store_prep_open() {
  char ind,trans;
  FILE* outfile=fopen(resultstring,"wb");
  store_vector = new float[num_stores*numberOfRegions];
  
  /*---------------------------------------------*/
  /*     writes header to binary result file     */
  /*---------------------------------------------*/
  trans=num_stores;
  fwrite(&trans,sizeof(unsigned char),1,outfile);
  //  fprintf(outfile,"\% %d ",num_stores);

  cout<<"storing:";
  for(unsigned int d=0;d<(unsigned int)num_stores;d++) {
    if( (ind = get_popvar_ind(store_names[d]) ) < 0 ) {
      cout << store_names[d] << _("not in varlist! (using ind 0)") << endl;
      store_ind[d]=0;
    }
    else store_ind[d]=ind;
    fprintf(outfile,"%s\n",store_names[d].c_str());
    printf("\t%s(%d)",store_names[d].c_str(),ind); 
  }
  printf("\n"); 
  trans=num_stores;
/** Old implementation, problems with different sizes of
    ulong on 32 and 64 bit systems, thus changed to float 
    which is always 32 bit on all systems tested

    fwrite(&numberOfRegions,sizeof(unsigned long),1,outfile);
    float ftrans[3]={TimeStart,TimeEnd,OutputStep*2};  
    fwrite(&ftrans,3*sizeof(float),1,outfile);
*/
  float ftrans[4]={numberOfRegions*1.0,TimeStart,TimeEnd,OutputStep*2};
  fwrite(&ftrans,4*sizeof(float),1,outfile);

  return outfile;
}
   

/*---------------------------------------------------*/
/*  initialize population and some global variables  */
/*---------------------------------------------------*/
int initialize_populations(double var) {
  int ind; 
  double biond,nf,tl,nd;
  GlobalClimate startclimate(0);
  //  if (!startclimate.Read(climatestring,0,(VegetatedRegion**)&regions)) return 0;
  if (!startclimate.Update(0)) return 0;

  /*--------------------------------------------*/
  /*    identify minimal with initial values    */
  /*--------------------------------------------*/
  minval[1]=0*InitNdomast;
  minval[2]=InitQfarm;
  /* ------------------------------------------- */
  /*      global=worldwide control variables     */
  /* ------------------------------------------- */
  GlobCivStart=-1;
  GlobDev=NewCivDev[0]=0;
  GlobDevNum=NewCivNum=0;
  for (unsigned int i=0; i<(unsigned int)RowsOfdata_agri_start; i++)
    OldCivHit[i]=1;
  
  /* --------------------------------------------------- */
  /*   sets continental number of domesticable species   */
  /* --------------------------------------------------- */
  CalcContNdommax();
  

/*  vector<RegionalPopulation> population;
    vector<RegionalPopulation>::size_type npopulation; */

  if (!populations)
    if ( (populations = new RegionalPopulation[numberOfRegions]) ==NULL)   {
      cout << "\nERROR\tCannot allocate memory for global"  
           << " variable populations (initialize_populations)\n" << endl;
      exit(0);
    }
  
  for (unsigned int i=0;i<numberOfRegions; i++) {
    /* ------------------------------------------- */
    /*     initialisation of population traits     */
    /* ------------------------------------------- */
    regions[i].Climate(startclimate.Climate(i));
    ice_fac = IceFac(regions[i].Latitude(),regions[i].Longitude());

    tl	= regions[i].SuitableTemp();
   
    ind=regions[i].ContId();
    regions[i].ContNdommax(cnd[ind]);
    regions[i].Exploit(overexp*InitDensity);

    biond=cnd[ind]*regions[i].SuitableSpecies()*tl;
    if(i==300 || i==6) {
    cout<<i<<":" ; 
    cout <<ice_fac<<" Lat:"<<cnd[ind]<<" biond:"<<biond<<" tl:"<<regions[i].Tlim()<<" stl:"<<tl<<endl;
    regions[i].Write(stdout,regions[i].Id());
    }
    //   biond=regions[i].ContNdommax()*regions[i].SuitableSpecies();
    if(biond<EPS) biond=EPS;  
    nf = regions[i].NatFertility(1.0);
    nd= InitNdomast;
    if(nd>biond) nd=biond;
    //   cout<<i<<":"<<biond<<"("<<regions[i].SuitableSpecies()<<") ";
    populations[i]=RegionalPopulation(InitDensity,
				      InitQfarm,InitTechnology,nd,
				      InitGerms,InitGerms*0.5,biond,nf,tl,&(regions[i]));
    // do the reverse population to region link
    regions[i].Population(&(populations[i]));
    regions[i].ResetCivStart();
  }
  if(!VarActive) out_statreg();
  return 1;
}

/* ------------------------------------------- */
/*     calculate continental number of
       domesticable species    */
/* ------------------------------------------- */
int CalcContNdommax() {
  unsigned int i,ind;
  double area,MaxContAr,tl;
  /* ------------------------------------------- */
  /*    variant B: continental integration of
	area weighted suitability    */
  /* ------------------------------------------- */

  for (i=0;i<=LengthOfndommaxcont;i++) cnd[i]=0;
  for (i=0,MaxContAr=0; i<numberOfRegions; i++) {
    ind=regions[i].ContId();
    area=regions[i].Area();
    ice_fac = IceFac(regions[i].Latitude(),regions[i].Longitude());
    
    tl= regions[i].SuitableTemp();

    if(ind==1) MaxContAr+=area*regions[i].SuitableSpecies()*tl;
    cnd[ind]+=area*regions[i].SuitableSpecies()*tl;
  }
  MaxContAr*=ndommaxcont[0];
  if (!VarActive ) printf("cont:ndomax\t");
  for (unsigned int i=1;i<=LengthOfndommaxcont;i++) {
    /*------------------------------------------------------------*/
    /*   correct manually the continental index to inlude more
         "favorate/infavorate" vegetation during glacial times    */
    /*  will be omitted if maps for 18, 11 and 8 kyr BP are compiled */
    /*------------------------------------------------------------*/

    cnd[i]*=1.0*ndommaxcont[i-1]/MaxContAr;
    cnd[i]=ndommaxmean*pow(cnd[i],1+ndommaxvar);
    if (!VarActive ) printf("%d:%1.2f ",i,cnd[i]);
  }
  if (!VarActive) cout<<endl;
  

  /* ------------------------------------------- */
  /*    variant C: adjustment of preset vector   */
  /* ------------------------------------------- */
  /*
    for (i=0,ndommean=0;i<LengthOfndommaxcont;i++)
    ndommean+=ndommaxcont[i];
    if(LengthOfndommaxcont>0) ndommean/=LengthOfndommaxcont;
    for (i=1;i<=LengthOfndommaxcont;i++)
    cnd[ind]=ndommaxmean*ndommean+ndommaxvar*(ndommaxcont[i-1]-ndommean);
  */

  return 0;
}

/* --------------------------------------------------- */
/*     transfers index to a parameter vector	       */
/* --------------------------------------------------- */
int set_parvector(unsigned long dv, int out) {
  int vi;
  unsigned long dvl=1,d;
  if(out) printf("%ld: ",dv);
  for(d=0;d<num_variat;d++)
    {
      vi=dv%(variat_steps[d]*dvl);
      vi=(int)(vi*1.0/dvl);
      dv-=vi*dvl;
      dvl*=variat_steps[d];
      *par_val[d]=variat_min[d]+vi*variat_delt[d];
      if(out)
	printf("%s:%1.4f\t",variat_names[d].c_str(),*par_val[d]);
    }
  if(out)  printf("\n");
  return 0;
}

/* --------------------------------------------------- */
/*    truncating last variations in case of parallel
                     computation of massive variation   */
/* --------------------------------------------------- */ 
int fix_lastparvar(unsigned long dv,unsigned int off) {
  unsigned int d,dvl,vi;
  for(d=num_variat-off,dvl=1;d<(unsigned int)num_variat;d++) {
    vi=dv%(variat_steps[d]*dvl);
    vi=(unsigned int)(vi*1.0/dvl);
    dv-=vi*dvl;
    dvl*=variat_steps[d];
    *par_val[d]=variat_min[d]+vi*variat_delt[d];
    printf("%ld| fixing %s at %1.3f\n",RandomInit,
	   variat_names[d].c_str(),*par_val[d]);
  }
  num_total_variat/=(int)dvl;
  num_variat-=(int)off;
  if(num_variat<=0) {
    cout<<"Error: Number of Variations falls below one!!"<<endl;
    exit(0);
  } 
  VarOutputStep = ( num_variat>3 ? 3:1);
  return 0;
}

/* ----------------------------------------------------------- */
/*  transfers random number to parameter vector
     including a logarithmic distributionfor large intervals   */
/* ----------------------------------------------------------- */
int set_logparvector(unsigned long dv, FILE *sp) {
  double f,ff,fm,fac,fr;
  
  for(unsigned long d=0;d<num_variat;d++) {
    f=variat_delt[d]*(variat_steps[d]-1);
    if(f>EPS)
      /* ---------------------------------------------- */
      /*	     Logarithmic distribution             */
      /* ---------------------------------------------- */
      if((fm=variat_min[d])/f<0.2 && variat_steps[d]==2 ) {
	ff=log10((f+fm)/(fm+1E-6));
	fr=random2();
	fac=pow(10,fr*ff);       
	*par_val[d]=fm*fac;
      }     
      else {
	fr=random2();
	fprintf(sp,"%1.3f ",fr);
	*par_val[d]=variat_min[d]+fr*f;
	//        printf("(%1.3f) ",*par_val[d]);
      }
    
    else *par_val[d]=variat_min[d];
  }
  return 0;
}

/*---------------------------------------------------------*/
/*      Random number generator for Monte Carlo runs       */
/*---------------------------------------------------------*/
double random2()
{

	// The comparison below is pointless, since l0 is unsigned
	// is this correct behaviour?
if((l0=l0*65539)<0)
	l0+=l1;
return (double)(l0)*(double)2.3283064369E-10;
}

int init_random(unsigned long dv)
{
l0=dv;
 return 0;
}
