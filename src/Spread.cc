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
double calc_spread_single(unsigned int);
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


double spread_all() { 

  double tot_spr_t=0;

  /* ---------------------------------------------------------- */
  /*    Clears memory for collecting changes due to spreading   */
  /* ---------------------------------------------------------- */
  for (unsigned int i=0; i<numberOfRegions; i++)
    for (unsigned int n=0; n<N_POPVARS; n++)
    sprd[i*N_POPVARS+n]=0;
  /* ------------------------------------------------------ */
  /*       Calculates exchange rates for all regions        */
  /* ------------------------------------------------------ */
  for (unsigned int i=0; i<numberOfRegions; i++)
    tot_spr_t+=calc_spread_single(i);

  //printf("Total spread in this time step: %f\n", tot_spr_t);
  return tot_spr_t;
}

/* ----------------------------------------------------------- */
/*   Calculates exchange of a single region with neighbours    */
/* ----------------------------------------------------------- */
double calc_spread_single(unsigned int iid) {

  unsigned int jid, i1;
  double length,exch,ptech,jrgr,force;
  double jpop,ipop,ijpop,iarea,jarea,irgr,idommax;
	//double maxforce;
  double jtech,itech,dp0,dp1,indom,ndx,iqfarm,igerm,iresist;
  double iinfl,jinfl;
  GeographicalNeighbour* neigh;
  
  /* ------------------------------------------------- */
  /*    Gets all population & region properties ...    */
  /* ------------------------------------------------- */
  iarea  = populations[iid].Region()->Area();
  ipop   = populations[iid].Density();
  itech  = populations[iid].Technology();
  indom  = populations[iid].Ndomesticated();
  iqfarm = populations[iid].Qfarming();
  igerm  = populations[iid].Germs();
  iresist= populations[iid].Resist();
  idommax= populations[iid].Ndommax();
  
  irgr = populations[iid].Growthrate();
  
  iinfl=itech*ipop;  
  
  /* -------------------------------------------- */
  /*     Gets all region neighbours ...           */
  /* -------------------------------------------- */
  neigh= populations[iid].Region()->Neighbour();
  while (neigh) {
    if( (jid   = neigh->Region()->Id()) < iid) {
      
      /* -------------------------------------------- */
      /*     Gets neighbours' characteristics  ...    */
      /* -------------------------------------------- */
      jpop  = populations[jid].Density();
      jarea = populations[jid].Region()->Area();
      jtech = populations[jid].Technology();
      jrgr  = populations[jid].Growthrate();
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

      /** Alternative formulation * /
      
      if ( (iid==270) && (irgr<0) && (irgr<jrgr) ) {
	fprintf(stdout,"%3d: %4.0f %4.0f %3.0f | %3d: %4.0f %4.0f %3.0f | I=%3.0f J=%3.0f IJ=%3.0f F=%8.2f\n",iid,ipop*1000.0,iarea/1000.0,itech*100.0,jid,jpop*1000.0,jarea/1000.0,jtech*100.0,iinfl*100.0,jinfl*100.0,ijpop*100.0,force*1000.0);
      */
	
      /** Calculated maximum relative change in both
	  target and source regions
	  introduced 2008-01-22 cl */

      /*maxforce=RelChange/TimeStep
      *min(1.0/populations[iid].Region()->Numneighbours(),
	   1.0/populations[jid].Region()->Numneighbours()
	   *jpop*jarea/ipop/iarea);
      
	   dp0=min(force,maxforce/iarea);*/ 
      dp0=force;
      dp1=-iarea*dp0/jarea;
      
    sprd[iid*N_POPVARS+4]+=dp0*ipop;
    sprd[jid*N_POPVARS+4]+=dp1*jpop;

     /**
	 For unidirectional transport of traits and traits in people,
	 identify source and target. Change occurs in
	 importing region only with traits of exporter 
	       */
	       

    int import_id=0,export_id=0;
    double import_change=0;
    
    if(force<0) {  // outward pressure
//	  dpr=dp1;  // area-scaled percentage of change
      export_id=iid;
      import_id=jid;
      import_change=dp1;
    }
    else { // inward pressure
//	  dpr=-dp0;
      export_id=jid;
      import_id=iid;
      import_change=dp0;
    }
    
    double export_tech  =populations[export_id].Technology();
    double export_qfarm =populations[export_id].Qfarming();
    double export_ndom  =populations[export_id].Ndomesticated();
    double export_germ  =populations[export_id].Germs();
    double export_resist=populations[export_id].Resist();
    double export_pop   =populations[export_id].Density();;

    double import_pop   =populations[import_id].Density();
    double import_tech  =populations[import_id].Technology();
    
    /** 
      Spread of traits with people
    */
    assert(import_change>=0);
    
    /** TODO pop can be negative */
    assert(import_pop>0);
    if (import_change>0) {
      //sprd[import_id*N_POPVARS+0] += (export_tech*export_pop/import_pop)*import_change;
      //sprd[import_id*N_POPVARS+1] += (export_ndom*export_pop/import_pop)*import_change;
      sprd[import_id*N_POPVARS+2] += (export_qfarm*export_pop/import_pop)*import_change;
      //sprd[import_id*N_POPVARS+3] += (export_resist*export_pop/import_pop)*import_change;
      //sprd[import_id*N_POPVARS+5] += (export_germ*export_pop/import_pop)*import_change;
    }
    else cerr << populations[import_id] << " rgr= " << populations[import_id].RelativeGrowthrate() 
    	<< "/ import_change = " << import_change << endl
    	<< force << " / " << dp0 << " / " << dp1  << endl
    	<< ijpop << " / " << iinfl << " / " << jinfl << " / " << exch << endl
    	<< populations[export_id] << endl;

      /*-------------------------------------------------------*/
      /*   Spread of traits with trade (see parameter spreadm)   */
      /*-------------------------------------------------------*/
      //    printf("\t do spread\t%d\t%ld\n",iid,sprd);

     sprd[import_id*N_POPVARS+0]+=traitspread(export_tech,import_tech,import_change);
     //sprd[import_id*N_POPVARS+1]+=traitspread(indom,populations[jid].Ndomesticated(),import_change);
     sprd[import_id*N_POPVARS+1]+=traitspread(export_ndom,populations[import_id].Ndomesticated(),import_change);
       
      // TODO 
      /** Qfarming should not spread, should it? 
          Changed by cl 2009-09-06 */
      //sprd[i1*N_POPVARS+2]+=traitspread(iqfarm,populations[jid].Qfarming());

// TODO germs and resist
      //sprd[import_id*N_POPVARS+5]+=traitspread(igerm,populations[jid].Germs(),import_change);
      //sprd[import_id*N_POPVARS+3]+=genospread(iresist,populations[jid].Resist(),export_tech);

      double ch;
      ch=TimeStep*sprd[iid*N_POPVARS+4];
      if(fabs(ch/(ipop+0.01))>RelChange)
	cout<<"HighDeni "<< state_names[4] <<" "<<iid<<"\t: "<< ipop
	<<"+"<<ch<<endl;
      ch=TimeStep*sprd[jid*N_POPVARS+4];
      if(fabs(ch/(jpop+0.01))>RelChange)
	cout<<"HighDenj "<< state_names[4] <<" "<<jid<<"\t: "<< jpop
	<<"+"<<ch<<endl;
      
  if (0& (iid==211 || iid==271 || iid== 235))
     printf("%d %d\t%1.1f %1.1f\t%1.1f \n",iid,jid,dp0*1E3,dp1*1E3,ndx*1E3);

    /** For diagnostic output calculate total migration activity */
  sprdm[iid]+=fabs(dp0*ipop);
  sprdm[jid]+=fabs(dp1*jpop);

    }
    neigh = neigh->Next();
  }
  return fabs(sprd[iid*N_POPVARS+4])*iarea;
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
  return spreadm*(export_trait-import_trait)*import_change;
}

/*---------------------------------------------------*/
/*  calc exchange rate for genotype characteristics  */
/*---------------------------------------------------*/
inline double genospread(double it,double jt,double ptech) {
  return (it-jt)*dpr/ptech;
}

/** EOF Spread.cc */
