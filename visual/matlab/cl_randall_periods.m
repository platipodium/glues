function randall=cl_randall_rperiods

%% Load site data

data=load('../../data/randall_ivc_data');

rperiod=data.period';

% First find all archaological artifacts (not stones)
iarchaeology=[
  strmatch('Accharwala',rperiod);  % Harappan (2600 - 1900 BCE). Latitude: 28.84. Longtitude: 71.41.
%  strmatch('Agate-Carnelian',rperiod); % Stones
  strmatch('Ahar-Banas',rperiod); %The Ahar culture, also known as the Banas culture is a Chalcolithic archaeological culture of southeastern Rajasthan state in India,[1] lasting from c. 3000 to 1500 BCE
  strmatch('Amri',rperiod); %  Pre-Harappa fortified town which flourished from 3600 to 3300 BC.
  strmatch('Anarta',rperiod); % Pre Harappa of Gujarat
  strmatch('Andrhra',rperiod); % 200 BC-AD
  strmatch('Anjira',rperiod); % co-temporal with Amri
  strmatch('BMAC',rperiod); %The Bactria?Margiana Archaeological Complex (or BMAC, also known as the Oxus civilization) is the modern archaeological designation for a Bronze Age culture of Central Asia, dated to ca. 2300?1700 BC, l
  strmatch('Bara',rperiod); %  pre-Harappan
  strmatch('Bhurj',rperiod);
  strmatch('Bihar',rperiod); % Classical India
  %strmatch('Black',rperiod);
  strmatch('Buddhist',rperiod);
  strmatch('Burj',rperiod);
  %strmatch('Burnished',rperiod);
  strmatch('Cem',rperiod);
  strmatch('Chalcolithic',rperiod);
  strmatch('Complex B',rperiod);
  strmatch('Damb Sadaat',rperiod);
  strmatch('Dasht',rperiod);
  strmatch('Early',rperiod);
  strmatch('GAZ',rperiod);
  strmatch('Ganeshwar',rperiod);
  strmatch('Grindingstone',rperiod);
  strmatch('Gujarat',rperiod);
  strmatch('Gupta',rperiod);
  strmatch('Hakra Wares',rperiod);
  strmatch('Harappan',rperiod);
  strmatch('Haryana',rperiod);
  strmatch('Historic',rperiod);
  strmatch('Iron Age',rperiod);
  strmatch('Islamic',rperiod);
  strmatch('Jhangar',rperiod);
  strmatch('Jhukar',rperiod);
  strmatch('Jodhpura',rperiod);
  strmatch('Kaisaria',rperiod);
  strmatch('Kechi',rperiod);
  strmatch('Kerman',rperiod);
  strmatch('Kili',rperiod);
  strmatch('Kingrali',rperiod);
  strmatch('Kirana',rperiod);
  strmatch('Kot Diji',rperiod);
  strmatch('Kulli',rperiod);
  strmatch('Kushan',rperiod);
  strmatch('Late',rperiod);
  strmatch('Londo',rperiod);
  strmatch('Lustrous Red Ware',rperiod);
  strmatch('Madhya Preadesh',rperiod);
  strmatch('Maharashtra',rperiod);
  strmatch('Malwa',rperiod);
  strmatch('Mature and Late Harappan',rperiod);
  strmatch('Medieval',rperiod);
  strmatch('Mehrgarh',rperiod);
  strmatch('Microliths',rperiod);
  strmatch('NBP',rperiod);
  strmatch('Nal',rperiod);
  strmatch('Northern Neolithic',rperiod);
  strmatch('OCP',rperiod);
  strmatch('Orissa',rperiod);
  strmatch('PGW',rperiod);
  strmatch('Palaeo / Mesolithic',rperiod);
  strmatch('Partho',rperiod);
  strmatch('Pirak',rperiod);
  strmatch('Post',rperiod);
  strmatch('Prabhas',rperiod);
  strmatch('Pre-',rperiod);
  strmatch('Quetta',rperiod);
  strmatch('Rajasthan',rperiod);
  strmatch('Rang Mahal',rperiod);
  strmatch('Rangpur',rperiod);
  strmatch('Ravi',rperiod);
  strmatch('Red Polished Ware',rperiod);
  strmatch('SKT',rperiod); % Sheri Khan Tarakai--
  strmatch('Shahi Tump',rperiod);
  strmatch('Shinkai',rperiod);
  strmatch('Sistan',rperiod);
  strmatch('Sorath',rperiod);
  strmatch('Sothi-Siswal',rperiod);
  strmatch('Sulaiman',rperiod);
  strmatch('Sunga-Kushan',rperiod);
  strmatch('Swat',rperiod);
  strmatch('TERIA',rperiod);
  strmatch('Thari',rperiod);
  strmatch('Togau',rperiod);
  strmatch('Uttarpradesh',rperiod);
  strmatch('Waziri',rperiod);
  strmatch('Zangian',rperiod);
];

randall.period{1}='Archaeological artifacts';
randall.index{1}=iarchaeology;

% Find all Mesolithic sites

imesolithic=[
  strmatch('Palaeo / Mesolithic',rperiod);
];
randall.period{2}='Mesolithic';
randall.index{2}=imesolithic;

ineolithic=[
  strmatch('Kili',rperiod);
  strmatch('Burj',rperiod);
  strmatch('Bhurj',rperiod);
  strmatch('Togau',rperiod);
  strmatch('Kechi',rperiod);
  strmatch('Anarta',rperiod);
  strmatch('Hakra',rperiod);
];
randall.period{3}='Neolithic';
randall.index{3}=ineolithic;

ibronze=[
  strmatch('Amri',rperiod);
  strmatch('Kot Dij',rperiod);
  strmatch('Sothi',rperiod);
  strmatch('Damb',rperiod);
  strmatch('Kechi',rperiod);
  strmatch('Early Harappan',rperiod);
  strmatch('Kulli',rperiod);
  strmatch('Sorath',rperiod);
  strmatch('Harappan',rperiod);
  strmatch('Post-urban',rperiod);
  strmatch('Jhukar',rperiod);
  strmatch('Pirak',rperiod);
  strmatch('Late Sorath',rperiod);
  strmatch('Lustrous',rperiod);
  strmatch('Cem',rperiod);
  strmatch('Late Harapp',rperiod);
  strmatch('Swat',rperiod);
];
randall.period{4}='Bronze Age';
randall.index{4}=ibronze;
  

ipreharappan=[
  strmatch('Kili',rperiod);
  strmatch('Burj',rperiod);
  strmatch('Bhurj',rperiod);
  strmatch('Togau',rperiod);
  strmatch('Kechi',rperiod);
  strmatch('Bara',rperiod);
  strmatch('Hakra',rperiod);
  strmatch('Anarta',rperiod);
];

% Is this Chalcolithic cultures 4300-3200 BC?

randall.period{5}='Pre-Harappan';
randall.index{5}=ipreharappan;

iearlyharappan=[
  strmatch('Amri',rperiod);
  strmatch('Ravi',rperiod);
  strmatch('Kot Dij',rperiod);
  strmatch('Sothi',rperiod);
  strmatch('Damb',rperiod);
  strmatch('Zhob',rperiod);
  strmatch('Early Harappan',rperiod);
  strmatch('Anjira',rperiod);
];
randall.period{6}='Early Harappan';
randall.index{6}=iearlyharappan;


imatureharappan=[
  strmatch('Kulli',rperiod);
  strmatch('Sorath',rperiod);
  strmatch('Harappan (Mature)',rperiod);
  strmatch('Accharwala',rperiod);
];
randall.period{7}='Mature Harappan';
randall.index{7}=imatureharappan;

ilateharappan=[
  strmatch('Post-urban',rperiod);
  strmatch('Jhukar',rperiod);
  strmatch('Pirak',rperiod);
  strmatch('Late Sorath',rperiod);
  strmatch('Lustrous',rperiod);
  strmatch('Cem',rperiod);
  strmatch('Late Harappan',rperiod);
  strmatch('Swat',rperiod);
];
randall.period{8}='Late Harappan';
randall.index{8}=ilateharappan;



return;
end

