#include "../LandRegion.h"
#include <string>
#include <iostream>

using std::cout;
using std::endl;

using namespace glues;

int main() {

    double iceextent[]={50,80,80,45};

  cout << "Running test suite for class LandRegion.." << endl;

  glues::LandRegion::NppMaxLae(550.0);
  glues::LandRegion::IceExtent(iceextent);

  std::vector<LandRegion> r;
  std::vector<LandRegion>::iterator ir;
  
  std::ifstream ifs;
  std::string line;
  ifs.open("georegions.tsv",std::ios::in);
  while(!std::getline(ifs, line).eof()) {
      r.push_back(LandRegion(line));
  }
  ifs.close();
  
  r[1].Neighbour(&r[2],11111,23);
  r[1].Neighbour(&r[3],2222,46);
  r[3].Neighbour(&r[1],2222,46);
  r[0].Neighbour(&r[2],2222,46);

  for (ir=r.begin(); ir<r.end(); ir++) {
      cout << (*ir) << endl;
  }

  LandRegion& r1=r[1];

  for (int i=1; i<1600; i++) {
      r1.Climate().Npp(i*1.0);
      cout << r1.Climate().Npp() << " " << r1.FoodExtractionPotential() << " " << r1.LocalSpeciesDiversity() << endl;
  }

  return 0;
}
