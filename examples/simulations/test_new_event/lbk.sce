# Parameter file written by XSiSi 2.0
comment Scenario specific numbers and file names
int	CoastRegNo	0
comment Dateipfad fuer Eingabe
string	datapath	"/h/lemmen/projects/glues/glues/glues-1.1.2/examples/setup/686/"
comment Dateiname fuer Eingabe
string	regiondata	"regionstat_686.tsv"
string	mappingdata	"regionmap_686.dat"
comment Dateinamen fuer Ausgabe
string	resultfilename	"results.out"
string	watchstring	"watch.res"
string	spreadfile	"spread.res"
comment Region numbers to inspect
comment 164 243 171 123
array	ins
	\d region index to inspect (<N_INSPECT)85
	typeOfArray	int
	dimension 9	
data
	122 146 170 215 216 271 410 411 418
end
comment 	122	146	170	215	216	223	224	225	227	234	249	269	270	271	359	379	383	410	411	418	461
comment Cimate updates 
string	climatefile	"reg_npp_80_686.tsv"
array	ClimUpdateTimes
	\d 1:TimeStep  2:NumberOfUpdates
	typeOfArray	int
	dimension	2
data
	500	23	
end
comment file names for event series input (from proxy data)
string	eventfile	"event_series.tsv"
string	SiteRegfile	"region_events.tsv"
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
