#include "../Population.h"
#include <string>
#include <iostream>
#include <vector>


using std::cout;
using std::endl;

using namespace glues;

int main() {

    unsigned long int i,n;
    std::vector<Population> p;
    std::vector<Population>::iterator ip;
    
    n=300;
    
    cout << "Running test suite for class Population.." << endl;
    
    // Static initializers
    Population::DeathCoefficient(0.7);
    Population::BirthCoefficient(0.7);
    Population::Timestep(0.07);
    
    Population p1;
    Population p2(0.1);
    
    p.push_back(p1);
    p.push_back(p2);

    for (i=0; i<n; i++) {
	for (ip=p.begin(); ip<p.end(); ip++) ip->Grow();
	if (i%20==0) cout << i << " " << p[0] << " " << p[1] << endl;
    }
    
    return 0;
}
