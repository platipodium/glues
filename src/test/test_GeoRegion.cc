#include "../GeoRegion.h"
#include "../GeoNeighbour.h"
#include <string>
#include <iostream>

using std::cout;
using std::endl;

int main() {

  std::string str="0 0 0 0 0 0";
  std::stringstream sstr;

  cout << "Running test suite for class GeoRegion.." << endl;

  glues::GeoRegion gr1;

  //sstr << gr1 ;
  //cout << sstr << endl;

  str="4 33333 22000 -10.5 20";

  glues::GeoRegion gr2(2,20000.,18.,-10.5);
  glues::GeoRegion gr3(gr2);
  glues::GeoRegion gr4(str);
  glues::GeoRegion gr5(5,10000.,18,-80.5);

  gr2.Neighbour(&gr1,11111,23);
  gr2.Neighbour(&gr2,2222,46);
  gr2.Neighbour(&gr3,2222,46);
  gr2.Neighbour(&gr3,2222,46);
  gr2.Neighbour(&gr4,2222,46);
  gr4.Neighbour(&gr2,2222,46);

  cout << gr1 << endl << gr2 << endl << gr3 << endl << gr4 << endl << gr5 << endl;
  cout << "Distance identical regions " << gr3-gr2 << endl;
  cout << "Other distance  " << gr5-gr2 << endl;
  cout << "Borders " << gr2.Length() << " = " << gr1.Length() << " + " << gr4.Length() << endl;
  
  cout << "Region 1 neighbours " << gr1.NumNeighbours() << " = 1?" << endl;
  cout << "Region 2 neighbours " << gr2.NumNeighbours() << " = 2?" << endl;
  cout << "Region 3 neighbours " << gr3.NumNeighbours() << " = 2?" << endl;
  cout << "Region 4 neighbours " << gr4.NumNeighbours() << " = 1?" << endl;
  cout << "Region 5 neighbours " << gr5.NumNeighbours() << " = 0?" << endl;

  return 0;
}
