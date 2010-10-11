# Parameter file written by XSiSi 2.0
comment Scenario specific numbers and file names
int	CoastRegNo	0
comment Dateipfad fuer Eingabe
string  datapath        "/home/lemmen/glues/examples/setup/1/"
comment Dateiname fuer Eingabe
string	regiondata	"regions_80_1.dat"
string	mappingdata	"mapping_80_1.dat"
comment Dateinamen fuer Ausgabe
string	resultfilename	"results.out"
string	watchstring	"watch.res"
string	spreadfile	"spread.res"
comment Region numbers to inspect
array	ins
	\d region index to inspect (<N_INSPECT)85
	typeOfArray	int
	dimension 1	
data
	1
end
comment Cimate updates 
string	climatefile	"reg_npp_80_1.dat"
array	ClimUpdateTimes
	\d 1:TimeStep  2:NumberOfUpdates
	typeOfArray	int
	dimension	2
data
	500		23
end
comment file names for event series input (from proxy data)
string	eventfile	"EvSeries.dat"
string	SiteRegfile	"EventInReg.dat"
int	SaharaDesert	1
	\d 1: desertification of Sahara at 5.5 kyr BP (to 12%)
int	LGMHoloTrans	1
	\d 1: transition from LGM in NH
array	IceExtent
	\d 1:rlat0  2:rlat2 3:lat_off 4:lon_off
	typeOfArray	float
	dimension	4
data
	50.0	80.0	80.0	45.0
end
array	IceRed
	\d 1:
	typeOfArray	float
	dimension	3
data
	50.0	75.0	80.0
end
