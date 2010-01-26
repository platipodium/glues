function [kclass]=cl_koeppen(lat,temp,prec,lsm)
% Calculates the Koeppen classification based on temperature and
% precipitation fields
%
% parameter latitude, temperature, precipitation and land-sea mask


% Original fortran code by E. Kirk, M. Sujatta and N. Sander (ZMAW Hamburg)
% Adopted for Matlab by C. Lemmen (GKSS)

% 11 climate classes


% temp: montly average temperature, dimension is nmonth x nlon x nlat
% lat dimension is nlat

nmon=12.0;

t=temp;                 % monthly mean 2m temperature deg C
p=prec;                 % monthly mean precipitation mm

tn = min(t,1);          % Annual min temperature 
tx = max(t,1);          % Annual max temperature
tm = sum(t,1)./nmon;    % Annual mean temperature

pn = min(p,1);          % Annual min precip
%px = max(p,1);          % Annual max precip (not used)
%pm = sum(p,1)./nmon;    % Annual mean precip (not used)

isouth=find(lat<0);


%% Calculate sesonal mean, max, sum of precipitation

wrn = min([p(12,:,:),p(1,:,:),p(2,:,:)],1); % Winter rain min
srn = min(p(6:8,:,:),1);                    % Summer rain min
srn(isouth,:) = wrn(isouth,:);              % swap for SH
wrn(isouth,:) = min(p(6:8,isouth,:),1);          

wrx = max([p(12,:,:),p(1,:,:),p(2,:,:)],1); % Winter rain max
srx = max(p(6:8,:,:),1);                    % Winter rain min
srx(isouth,:) = wrx(isouth,:);              % swap for SH
wrx(isouth,:) = max(p(6:8,isouth,:),1);

rr = sum(p,1);          % Annual precipitation
% Check unit for rr (mm or cm)

wr = sum([p(12,:,:),p(1,:,:),p(2,:,:)],1);  % Winter rain
sr = sum(p(6:8,:,:),1);                     % Summer rain
sr(isouth,:) = wrn(isouth,:);
wr(isouth,:) = sum(p(6:8,isouth,:),1); 

pr = sum(p(3:5,:,:),1);                     % Spring rain
fr = sum(p(9:11,:,:),1);                    % Fall rain
pr(isouth,:)=fr(isouth,:);
fr(isouth,:) = sum(p(3:5,isouth,:),1);

wrr = sum([p(10:12,:,:),p(1,:,:),p(3,:,:)],1);  % Winter half-year rain
srr = sum(p(4:9,:,:),1);                        % Summer half-year rain
srr(isouth,:)=wrr(isouth,:);
wrr(isouth,:)=sum(p(4:9,isouth,:),1);

%% Calculate drought threshold

% Default based on mean temperature
dt = 2.0*(tm + 7.0);                            % Drought threshold
%dt(:) = 2.0 * (tm(:) + 14.0)   ! Nicole

% find high winter precip
iwinter = wrr > 0.7*(wr+pr+sr+fr);
dt(iwinter)=2*tm;

% find high summer precip
isummer = srr > 0.7*(wr+pr+sr+fr);
dt(isummer) = 2.0 * (tm(:) + 14.0);


%% Convert to climate zones
c=tn*0.0;

% Zone A Tropical (Af tropical rainforest; Aw tropical savanna
c(tn>=18.0 && pn >=6.0) = 1;    % Af
c(tn>=18.0 && pn < 6.0) = 2;    % Aw

% Zone E Snow (ET tundra; EF permafrost)
c(tx >=0 && tx < 10.0) = 10;    % ET
c(tx < 0) = 11;                 % EF

% Zone C (wet) (Cs warm climate with dry summer; Cw with dry winter; Cf humid temperate climate)
c(tn>-3.0 && tn<18.0 && srx >= 10.0*wrn) = 6;    % Cs
c(tn>-3.0 && tn<18.0 && srx <  10.0*wrn) = 7;    % Cw
c(tn>-3.0 && tn<18.0 && wrx >= 3.0*srn) = 5;    % Cf

% Zone B (dry) (BS steppe; BW desert)
c(rr<=dt && rr >=dt/2.0) = 3;           % BS
c(rr<dt/2.0) = 4;                       % BW

% Zone D Boreal (Dw cold climate with dry winter; DF with moist winter)
c(tn<-3.0 && tx >= 10.0 && srx >= 10.0*wrn) = 8;    % Dw
c(tn<-3.0 && tx >= 10.0 && srx <  10.0*wrn) = 9;    % Df

%% Calculate feeback variables albedo, roughness, vegetation and forest
%% cover

% Define typical albedos for the 11 climate classes and open ocean
% ocean as 12th climate class
albedo_list = [0.12,0.15,0.28,0.28,0.20,0.19,0.16,0.14,0.15,0.17,0.20,0.069];
z0_list = [2.0,0.361,0.005,0.004,0.100,0.055,1.000,0.634,1.00,0.033,0.001,1.5E-5];

% forest cover typical values and vegetation cover;
cf_list = [1.0,0.6,0.0,0.0,0.0,0.0,1.0,0.9,1.0,0.1,0.0,0.0];
cv_list = [0.960,0.6,0.1,0.08,0.29,0.34,0.59,0.68,0.51,0.39,0.0,0.0];

c(lsm<0.5)=0;
ca=c; ca(c<0.5)=12;
alb=albedo_list(ca);
z0=z0_list(ca);
cv=cv_list(ca);
cf=cf_list(ca);

%% Write out the koeppen feedback parameters to kopeen.txt file, to be
%% added to surface.txt file for PlaSim

CODE_ALB = 174; % Background Albedo
CODE_Z0  = 173; % Roughness Length
CODE_CF  = 212; % Forest Cover
CODE_CV  = 199; % Vegetation Cover

if ~exist('data','dir') mkdir(data); end
fid=fopen('data/koppen.txt','w');

fprintf(fid,'\n%d\n',CODE_ALB);
for ilat=1:nlat
  fprintf(fid,'%12.6f',alb(ilat,:));
  fprintf(fid,'\n');
end


fprintf(fid,'\n%d\n',CODE_Z0);
for ilat=1:nlat
  fprintf(fid,'%12.6f',z0(ilat,:));
  fprintf(fid,'\n');
end


fprintf(fid,'\n%d\n',CODE_CF);
for ilat=1:nlat
  fprintf(fid,'%12.6f',cf(ilat,:));
  fprintf(fid,'\n');
end


fprintf(fid,'\n%d\n',CODE_CV);
for ilat=1:nlat
  fprintf(fid,'%12.6f',cv(ilat,:));
  fprintf(fid,'\n');
end

fclose(fid);

if nargout>0
  klass=c;
end

return;


end

%call cc_entry('   ',0.7,1.0,1.0)  ! light blue
%call cc_entry('.  ',0.0,0.0,0.0)  ! black
%call cc_entry('Af  ',0.0,0.5,0.0) ! green
%call cc_entry('Aw  ',0.0,0.3,0.0) ! dark green
%call cc_entry('BS  ',1.0,1.0,0.0) ! yellow
%call cc_entry('BW  ',1.0,0.9,0.2) ! dark yellow
%call cc_entry('Cs  ',1.0,0.5,0.0) ! orange red
%call cc_entry('Cw  ',1.0,0.0,0.0) ! red
%call cc_entry('Cf  ',0.8,0.3,0.3) ! brown red
%call cc_entry('Dw  ',0.6,0.6,0.1) ! light brown
%call cc_entry('Df  ',0.3,0.5,0.1) ! green brown
%call cc_entry('ET  ',0.7,0.6,1.0) ! light violett
%call cc_entry('EF  ',0.4,0.4,1.0) ! blue

