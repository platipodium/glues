# Parameter file written by XSiSi 2.0
comment Switches for spreading
int	LocalSpread 0
	\d 1: Exchange between adjacent regions
int	RemoteSpread	0
	\d 1: Exchange between remote seashore regions (not used in v2!)
comment Controlling comparison with observed history pattern
float	CultIndex	0.5
	\d Critical Q*N for civilization
float	Space2Time	2.0
	\u y/km
	\d Conversion of distance error to time error
int	MaxCivNum	2320
	\d Maximal number of independet civilizations; stop condition for simulation		
int	DataActive	0
	\d 1: Vergleich mit Daten (not used yet)
array	err_data_weights
	typeOfArray	float
	dimension	2
data
	1.0	1.51
end
comment Control parameter of variation  18298  40979
int	RunVarInd	-18718
	\d >=0: Index of ParVector used in Variation
int	VarActive	0
	\d 1: Parameter variation on
int	NumDice	200
	\d Number of Random parameter variations
int	MonteCarlo	0
	\d 1: Random parameter variation
int	VarOutputStep	-2
string	varresfile	"parvar0.res"
comment output kenngroessen
float	storetim	0.0
	\u days
	\d Simzeit ohne Ausgabe ab TimeStart
comment Numerics settings
float	RelChange	0.8
int	NumMethod	0
	\d 0: Euler-Cauchy; 1: Runge-Kutta
