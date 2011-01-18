/********************************************************
 * GLUES						*
 * Global Land-Use & technological Evolution Simulator	*
 * Program UnCRiM                                       *
 * Understanding Civilization Rise Model                *
 *						       	*
 * \author  Kai Wirtz <wirtz@icbm.de>                   *
 *     to do: recursive method if change> RelChange !!	*
 *\file  spread.cpp                                     *    
 *\brief Migration Module of UnCRiM			*
 *\date  26.06.2001                                     *
 *******************************************************/
#include "Globals.h"
#include "Symbols.h"
#include "Exchange.h"
#include <assert.h>

class Exchange;

double dpr;
double calc_spread_single(unsigned int,double t=0);
double traitspread(double,double,double);
//double geno_spread(double,double,double);
/* ------------------------------------------------------ */
/*   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
     to do: recursive method if change> RelChange !!      */
/* ------------------------------------------------------ */

/* -------------------------------------------------- */
/*            Mutual spread of properties and
                  individuals between regions         */
/* -------------------------------------------------- */
int exchange(void) {
  double ch;

  for (unsigned int id=0; id<numberOfRegions; id++) {
    populations[id].CreateVector();
    for(unsigned int i=0;i<N_POPVARS;i++) {
      ch=TimeStep*sprd[id*N_POPVARS+i];
      if(fabs(ch/(ev[i]+0.01))>RelChange  && !VarActive) //
		cout<<"HighExch "<<state_names[i]<<" "<<id<<"\t:"<<ev[i]
		<<"+"<<ch<<endl;  // */
      ev[i]+=min(ch,RelChange*ev[i]);
    }

    if(populations[id].Update()) return 1;
  }
  return 1;
}



/* -------------------------------------------------- */
/*   Calculates total population spread   */
/* -------------------------------------------------- */


double spread_all(double t=0) { 

  double tot_spr_t=0;

  /* ---------------------------------------------------------- */
  /*    Clears memory for collecting changes due to spreading   */
  /* ---------------------------------------------------------- */
  for (unsigned int i=0; i<numberOfRegions; i++) {
    for (unsigned int n=0; n<N_POPVARS; n++) {
      sprd[i*N_POPVARS+n]=0;
      sprd_p[i*N_POPVARS+n]=0;
      sprd_i[i*N_POPVARS+n]=0;
    }
  }
  /* ------------------------------------------------------ */
  /*       Calculates exchange rates for all regions        */
  /* ------------------------------------------------------ */
  for (unsigned int i=0; i<numberOfRegions; i++)
    tot_spr_t+=calc_spread_single(i,t);

  //printf("Total spread in this time step: %f\n", tot_spr_t);
  return tot_spr_t;
}

/* ----------------------------------------------------------- */
/*   Calculates exchange of a single region with neighbours    */
/* ----------------------------------------------------------- */
double calc_spread_single(unsigned int i, double t) {

  unsigned int j, i1;
  unsigned int jid, iid;
  double length,exch,ptech,jrgr,force;
  double jpop,ipop,ijpop,iarea,jarea,irgr,idommax;
	//double maxforce;
  double jtech,itech,dp0,dp1,indom,ndx,iqfarm,igerm,iresist;
  double iinfl,jinfl;
  unsigned int import_id, export_id;
  GeographicalNeighbour* neigh;
  
  /* ------------------------------------------------- */
  /*    Gets all population & region properties ...    */
  /* ------------------------------------------------- */
  iarea  = populations[i].Region()->Area();
  ipop   = populations[i].Density();
  itech  = populations[i].Technology();
  indom  = populations[i].Ndomesticated();
  iqfarm = populations[i].Qfarming();
  igerm  = populations[i].Germs();
  iresist= populations[i].Resist();
  idommax= populations[i].Ndommax();
  iid    = populations[i].Region()->Id();
  
  irgr = populations[i].Growthrate();
  iinfl=itech*ipop;  
  
  /* -------------------------------------------- */
  /*     Gets all region neighbours ...           */
  /* -------------------------------------------- */
  neigh= populations[i].Region()->Neighbour();
  while (neigh) {
    j   = neigh->Region()->Index();
    jid = neigh->Region()->Id();
    
    //cerr << i << "/" <<  iid << " " << j << "/" << jid << endl; 
    /** Only perform an update if j>i to avoid
    double exchange in one time step */	
    if (j > i) {
      
      /* -------------------------------------------- */
      /*     Gets neighbours' characteristics  ...    */
      /* -------------------------------------------- */
      jpop  = populations[j].Density();
      jarea = populations[j].Region()->Area();
      jtech = populations[j].Technology();
      jrgr  = populations[j].Growthrate();
      length= neigh->Length();
      jinfl = jtech*jpop;
      /*-------------------------------------------------*/
      /*      calc specific exchange rate               */
      /*-------------------------------------------------*/
      exch=spreadv*length/sqrt(iarea*jarea);
      
      /** Crisis: I am dying but my neighbour is doing better
	  than I am.  I emigrate.

	  This leads to instabilities earlier than without
	  this mechanism, but no easy solution here */
      
      /** Removed from simulation for lbk */
      //if ( (irgr<0) && (irgr<jrgr) )jinfl=0; //.9*jinfl;
      //else if (  (jrgr<0 && jrgr<irgr) ) iinfl=0; //.9*iinfl;

      ijpop=(iinfl*iarea+jinfl*jarea)/(iarea+jarea);
      force=exch*(ijpop-iinfl);

      /** Alternative formulation 
       Calculated maximum relative change in both
	  target and source regions
	  introduced 2008-01-22 cl */

      /*maxforce=RelChange/TimeStep
      *min(1.0/populations[i].Region()->Numneighbours(),
	   1.0/populations[j].Region()->Numneighbours()
	   *jpop*jarea/ipop/iarea);
      
	   dp0=min(force,maxforce/iarea);*/ 
    dp0=force;
    dp1=-iarea*dp0/jarea;
      
    sprd_p[i*N_POPVARS+4]+=dp0*ipop;
    sprd_p[j*N_POPVARS+4]+=dp1*jpop;
    sprd[i*N_POPVARS+4]+=dp0*ipop;
    sprd[j*N_POPVARS+4]+=dp1*jpop;
    
    /**
    For unidirectional transport of traits and traits in people,
    identify source and target. Change occurs in
    importing region only with traits of exporter 
	*/     
    double import_change;
    double export_change;
    
    if(force<0) {  // outward pressure
      export_id=i;
      import_id=j;
      import_change=dp1;
      export_change=dp0;
    }
    else { // inward pressure
      export_id=j;
      import_id=i;
      import_change=dp0;
      export_change=dp1;
    }
    
    double export_tech  =populations[export_id].Technology();
    double export_qfarm =populations[export_id].Qfarming();
    double export_ndom  =populations[export_id].Ndomesticated();
    double export_germ  =populations[export_id].Germs();
    double export_resist=populations[export_id].Resist();
    double export_pop   =populations[export_id].Density();;

    double import_pop   =populations[import_id].Density();
    double import_tech  =populations[import_id].Technology();   
    
    assert(import_change>=0);
    assert(export_change<=0);
    assert(import_pop>0);
    assert(export_pop>0);
    
    double import_tech_p=import_change>0?(export_tech*export_pop/import_pop)*import_change:0;
    double import_ndom_p=import_change>0?(export_ndom*export_pop/import_pop)*import_change:0;
    double import_qfarm_p=import_change>0?(export_qfarm*export_pop/import_pop)*import_change:0;
    double import_tech_i=import_change>0?traitspread(export_tech,import_tech,import_change):0;
    double import_ndom_i=import_change>0?traitspread(export_ndom,populations[import_id].Ndomesticated(),import_change):0;
    double import_pop_p=import_change*import_pop;
    double export_pop_p=export_change*export_pop;
    
    if (import_change>0) {
   
      /** 
      Spread of traits with people 
      This has not been documented in WL03
      In sprd_p, all exchanges with all neighbours are summed up.
      @todo do the same for germs/resist variables (index 5,6)
      */
      sprd_p[import_id*N_POPVARS+0] += import_tech_p;
      sprd_p[import_id*N_POPVARS+1] += import_ndom_p;
      sprd_p[import_id*N_POPVARS+2] += import_qfarm_p;
      sprd[import_id*N_POPVARS+0] += import_tech_p;
      sprd[import_id*N_POPVARS+1] += import_ndom_p;
      sprd[import_id*N_POPVARS+2] += import_qfarm_p;

	  /**
	  Spread of traits by information/trade
	  This is documented in WL03
	  In sprd_i, all exchanges with all neighbours are summed up.
	  @param controlled by parameter spreadm (in function traitspread)
	  @todo This exchange may apply (or not) to qfarm and germs
	  @todo This exchange may apply (or not) to resist with function genospread
      */
      sprd_i[import_id*N_POPVARS+0]+=import_tech_i;
      sprd_i[import_id*N_POPVARS+1]+=import_ndom_i;
      sprd[import_id*N_POPVARS+0]+=import_tech_i;
      sprd[import_id*N_POPVARS+1]+=import_ndom_i;
      //sprd_i[import_id*N_POPVARS+5]+=traitspread(igerm,populations[j].Germs(),import_change);
      //sprd_i[import_id*N_POPVARS+3]+=genospread(iresist,populations[j].Resist(),export_tech);
           
      //spreadmatrix[numberOfRegions*(import_id*N_POPVARS+2)*j] = (export_qfarm*export_pop/import_pop)*import_change;
      
    
      /* cerr << import_id << " " populations[import_id] << " rgr= " << populations[import_id].RelativeGrowthrate() 
    	<< "/ import_change = " << import_change << endl
    	<< force << " / " << dp0 << " / " << dp1  << endl
    	<< ijpop << " / " << iinfl << " / " << jinfl << " / " << exch << endl 
    	<< export_id // populations[export_id] 
    	<< endl;*/

  
      double ch;
      ch=TimeStep*sprd_p[i*N_POPVARS+4];
      if(fabs(ch/(ipop+0.01))>RelChange)
	    cout<<"HighDeni "<< state_names[4] <<" "<<iid<<"\t: "<< ipop
	      <<"+"<<ch<<endl;
      ch=TimeStep*sprd_p[j*N_POPVARS+4];
      if(fabs(ch/(jpop+0.01))>RelChange)
	    cout<<"HighDenj "<< state_names[4] <<" "<<jid<<"\t: "<< jpop
	 <<"+"<<ch<<endl;
      
      /** For diagnostic output calculate total migration activity */
      sprdm[i]+=fabs(dp0*ipop);
      sprdm[j]+=fabs(dp1*jpop);
    }

   //hreg=[271 255  211 183 178 170 146 142 123 122];
    /*if (import_id==271 || import_id==255 || import_id==211  || import_id==183 || import_id==178 
     || import_id==170 || import_id==146 || import_id==142  || import_id==123 || import_id==122
     || export_id==271 || export_id==255 || export_id==211  || export_id==183 || export_id==178
     || export_id==170 || export_id==146 || export_id==142  || export_id==123 || export_id==122
    ) {
    std::cerr << t << " " << import_id << " " << export_id 
    	<< " " << import_tech_i << " " <<  import_tech_p
    	<< " " << import_ndom_i << " " <<  import_ndom_p
    	<< " " << import_qfarm_p 
    	<< " " << import_pop_p << " " << export_pop_p  	
    	<< std::endl;
    	}
    //*/	
   /*std::cerr << t << " " << import_id << " " << export_id 
    	<< " " << sprd_p[import_id*N_POPVARS+0] << " " <<  sprd_i[import_id*N_POPVARS+0] //<< " " <<  sprd[import_id*N_POPVARS+0]
    	<< " " << sprd_p[import_id*N_POPVARS+1] << " " <<  sprd_i[import_id*N_POPVARS+1] //<< " " <<  sprd[import_id*N_POPVARS+1]
    	<< " " << sprd_p[import_id*N_POPVARS+2] //<< " " <<  sprd_i[import_id*N_POPVARS+2] //<< " " <<  sprd[import_id*N_POPVARS+2]
    	<< " " << sprd_p[import_id*N_POPVARS+4] //<< " " <<  sprd_i[import_id*N_POPVARS+4] //<< " " <<  sprd[import_id*N_POPVARS+4]	
    	<< std::endl;
    //*/	
    }
    neigh = neigh->Next();
  }
  
  /** Collect all information in matrix sprd 
    @todo: commented since results do not agree with calculation of sprd above 
  */
  for (unsigned int ivar=0; ivar<5; ivar++) {
    //sprd[import_id*N_POPVARS+ivar] = sprd_p[import_id*N_POPVARS+ivar] + sprd_i[import_id*N_POPVARS+ivar]; 
  }
  
  return fabs(sprd[i*N_POPVARS+4])*iarea;
}

/*-----------------------------------------------*/
/*   calc exchange rate for adoptable  traits    */
/*-----------------------------------------------*/
/*inline double traitspread(double it,double jt) {
  return spreadm*(it-jt)*dpr;
}*/

/** @brief calculates exchange rate for adoptable traits
    @param export_trait trait of exporting region
    @param import_trait trait in importing region
    @param import_change relative change calculated from influence difference
    This routine used the SiSi variabl spreadm, which gives the relative
    strenght of trait spread by trade versus population spread */

inline double traitspread(double export_trait,double import_trait,double import_change) {
  /** @todo this should not return negative values, should it? This happens when
     the influence of the exporter with lower tech is higher (due to P,A), interesting, but real?*/
  return spreadm*(export_trait-import_trait)*import_change;
}

/*---------------------------------------------------*/
/*  calc exchange rate for genotype characteristics  */
/*---------------------------------------------------*/
inline double genospread(double it,double jt,double ptech) {
  return (it-jt)*dpr/ptech;
}

/** EOF Spread.cc */
