exts='png';


% FEPRE Neolithic dataset
d=cl_read_fepre;
clp_radiocarbon_sites(d);
cl_print(gcf,'name',d.filename,'ext',exts);

[so,isort]=sort(d.age_uncal_bp);
caly=movavg(d.age_uncal_bp(isort),d.age_cal_bp(isort),1);
calx=unique(d.age_uncal_bp);
ivalid=find(isfinite(caly+calx));
mintime=min(d.age_uncal_bp(ivalid));
maxtime=max(d.age_uncal_bp(ivalid));
calf=interp1(calx(ivalid),caly(ivalid),mintime:maxtime,'linear');

% Vander Linden Mesolithic/Neolithic dataset (uncal)
d=cl_read_Vanderlinden;
clp_radiocarbon_sites(d);
cl_print(gcf,'name',d.filename,'ext',exts);

uage=d.age_uncal_bp;
ivalid=find(uage>=mintime & uage<=maxtime);
d.age_cal_bp=calf(uage(ivalid)-mintime+1);
clp_radiocarbon_sites(d);
cl_print(gcf,'name',[d.filename '_calibrated'],'ext',exts);


d=cl_read_neolithic('Vanderlinden',[-inf inf],[-inf inf],[-inf inf]);
clp_radiocarbon_sites(d);
cl_print(gcf,'name',d.filename,'ext',exts);

uage=d.age_uncal_bp;
ivalid=find(uage>=mintime & uage<=maxtime);
d.age_cal_bp=calf(uage(ivalid)-mintime+1);
clp_radiocarbon_sites(d);
cl_print(gcf,'name',[d.filename '_calibrated'],'ext',exts);


% Pinhasi data set
d=cl_read_Pinhasi;
clp_radiocarbon_sites(d);
cl_print(gcf,'name',d.filename,'ext',exts);

% Turney dataset
d=cl_read_Turney;
clp_radiocarbon_sites(d);
cl_print(gcf,'name',d.filename,'ext',exts);



