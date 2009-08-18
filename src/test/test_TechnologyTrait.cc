#include "../TechnologyTrait.h"
#include <string>
#include <iostream>

using std::cout;
using std::endl;

using namespace glues;

int main() {

    cout << "Running test suite for class TechnologyTrait .." << endl;
    
    TechnologyTrait::InitialValue(1.6);
    
    TechnologyTrait t;
    double tvalue=t.Value();
    cout << t << " " << tvalue << " " << t.Change() << " " << t.Gradient() << endl;
    
    t.Gradient(0.3);    
    cout << t << " " << tvalue << " " << t.Change() << " " << t.Gradient() << endl;

    t.Value(1.0);
    cout << t << " " << tvalue << " " << t.Change() << " " << t.Gradient() << endl;
   
    t.Value(tvalue+t.Value());

    cout << t << " " << tvalue << " " << t.Change() << " " << t.Gradient() << endl;
    
    t+=t.Change();

    cout << t << " " << tvalue << " " << t.Change() << " " << t.Gradient() << endl;
   
    return 0;
}
