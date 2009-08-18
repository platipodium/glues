#include "../CulturePopulation.h"
#include "../CultureRegion.h"

#include <string>
#include <iostream>
#include <iomanip>
#include <vector>
#include <fstream>

using std::cout;
using std::endl;

using namespace glues;

double glues::CulturePopulation::DeathFunction() {
    return  exp(-(technology/literatetechnology));
}

double glues::CulturePopulation::SubsistenceIntensity() {
    return (1-qfarming)*sqrt(technology) + qfarming*technology*fdomesticated;
}

double glues::CulturePopulation::LabourAvailability() {
    return 1-artisancoefficient*technology;
}

double glues::CulturePopulation::ResourceAvailability() {
    //return fep-Exploitation();
    return 1;
}

double glues::CulturePopulation::Exploitation() {
    return exploitationcoefficient*sqrt(technology)*density;
}

double glues::CulturePopulation::BirthFunction() {
    return ResourceAvailability()*LabourAvailability()*SubsistenceIntensity();
}

double glues::CulturePopulation::TechnologyGradient() {
    return birthcoefficient*(
	((1-qfarming)*(0.5/sqrt(technology)) 
	 + qfarming*fdomesticated)*ResourceAvailability()*LabourAvailability()
	+SubsistenceIntensity()*0*LabourAvailability()
	+SubsistenceIntensity()*ResourceAvailability()*(-artisancoefficient)
	)
	-deathcoefficient*density*(-exp(-technology/literatetechnology)/literatetechnology);
}

double glues::CulturePopulation::FarmingQuotaGradient() {
    return birthcoefficient*(
	-sqrt(technology)+technology*fdomesticated)*LabourAvailability()*ResourceAvailability();
}

double glues::CulturePopulation::DomesticationFractionGradient() {
    return birthcoefficient*technology*qfarming*LabourAvailability()*ResourceAvailability();
}

int main() {

    unsigned long int i,n=10000000;
 
    // cout << "Running test suite for class CultureRegion .." << endl;
    
    DomesticationFractionTrait::InitialValue(0.25);
    DomesticationFractionTrait::Flexibility(1.0);
    FarmingQuotaTrait::InitialValue(0.04);
    TechnologyTrait::InitialValue(1.0);
    TechnologyTrait::Flexibility(0.15);
    CulturePopulation::LiterateTechnology(12);
    CulturePopulation::InitialValue(0.03);
    CulturePopulation::DeathCoefficient(0.0025);
    CulturePopulation::BirthCoefficient(0.025);
    CulturePopulation::Timestep(0.007);
   
    std::vector<CulturePopulation> p;
    std::vector<CulturePopulation>::iterator ip;
    std::vector<CultureRegion> r;
    std::vector<CultureRegion>::iterator ir;

    std::ifstream ifs;
    std::string line;
    ifs.open("georegions.tsv",std::ios::in);
    while(!std::getline(ifs, line).eof()) {
	r.push_back(CultureRegion(line));
    }
    ifs.close();
    
//    cout << "Read " << r.size() << " regions" << endl;
//    for (ir=r.begin(); ir<r.end(); ir++) cout << *ir << endl;
    
    CulturePopulation p1(&r[0],1.0);
    CulturePopulation p2(&r[1],0.01);
    
    p.push_back(p1);
    p.push_back(p2);


/*    cout << i << " " << p[0].Density() << " " 
	 << p[0].Technology() << " " 
	 << p[0].FarmingQuota() << " " 
	 << endl;*/
    for (i=0; i<n; i++) {
	for (ip=p.begin(); ip<p.end(); ip++) {
	    TechnologyTrait& t = ip->Technology();
	    FarmingQuotaTrait& q = ip->FarmingQuota();
	    DomesticationFractionTrait& f = ip->DomesticationFraction();

	    t.Gradient(ip->TechnologyGradient());
	    q.Gradient(ip->FarmingQuotaGradient());
	    f.Gradient(ip->DomesticationFractionGradient());
	    ip->Grow();
/*	    cout << qg << " = " << ip->FarmingQuota().Gradient(ip->FarmingQuotaGradient()) << " " 
		 << q.Gradient() << " " 
		 << " " << q.Change() << endl; */

	    q+=q.Change()*ip->Timestep();
	    t+=t.Change()*ip->Timestep();
	    f+=f.Change()*ip->Timestep();
	}
	if (i%500==0) cout << i << " " << p[0].Density() << " " 
			   << p[0].Technology() << " " 
			   << p[0].FarmingQuota() << " " 
			   << p[0].Capacity() << " "
			   << p[0].DomesticationFraction() << " " 
			   << endl;
    }
    
    

    return 0;
}
