% clear all; close all;
cl_register_function();

slash='/';
prepare_var;
var1=1;
 routine_switch=[3 2 2 0 0 1 1+var1]; % vi(3)+2*vi(4)   

% dx= 0.02+0.02*bitand(var1,8)/8;
% dx = 0.05; 	% time-step for interpolation
dx = 0.025*2; 

critlev = 0;	% critical significance level below 0.95
		% critlev = 5: SIgLev>0.9 is accounted
		
if(routine_switch(1)<2 & routine_switch(4)>1 &routine_switch(4)<3)
    disp('\n Spectral analysis requires interpolation!!!\n');
    exit;
end; 
%  create switch labelfor output files 
lri = 'RFIBS'; 	% label for raw & LPF and interpolated
ltr = '0LM';   	% label for no, linear trend removal or moving average
lsp = 'LPFW';   % label for spectral method (LS, periodogram(welch), fourier, wavelet
lr  = 'AS';     % label for red noise (all datapoints, in segments)
if(routine_switch(1)>=2)
   il=[lri(routine_switch(1)+1) num2str(dx*1000)];
else
   il=[lri(routine_switch(1)+1) '00'];
end;
% switchlabel = [il ltr(routine_switch(2)+1) lsp(routine_switch(4)) lr(routine_switch(6)) '_'];
if routine_switch(4)==0, lsps='K-0';
else  lsps=[lsp(routine_switch(4)) '-0']; end;
switchlabel = [il ltr(routine_switch(2)+1) lsps lr(routine_switch(6)) '_'];
  minmaxper0 = [0 6.5; 5.5 12];% Border dates for time windows

% select sites to show;
sites2analyze = [1:139]; % 2 19 22 23 24
% sites2analyze = [1 3 24 66 88]; % 24 50
% sites2analyze = [3 23 45 66]; % 24 50
shownum = [35 36 41 49 92:99];
%    fp = [0.8 1.5; 0.25 0.4]; 	% frequency windows of interest 
fp = [0.8 1.8;0.46 0.64; 0.29 0.38]; 	% frequency windows of interest 

maxplot = 4+8; %12;		% max number of plots per page
% prepare_figures;
NumPeriod = size(minmaxper0,1); 	% Number of (overlapping) Holocene periods to analyze
numsites = length(sites2analyze);
%%%%%%%%% read list of sites including file_names
datafile = 'proxysites.csv';  % no absolute filename !!
if ~exist('holodata') holodata = read_textcsv(datafile, ';','"'); end;
   ms=150;  % max(sites2analyze)
evspan=zeros(ms,2);
evseries=zeros(ms,20)-1;
  
 dti=zeros(NumPeriod,numsites)+99; % array of mean data time interval 

%%%%%%%%%% loop over all proxy-sites (for loading and prefilter)
si = 1;  % running index 1,2,3,...
for i = sites2analyze
    
    % cutoff frequency (may be site specific...) 
    cutoff = holodata.CutoffFreq(i); 
    if cutoff < 0, cutoff = 12; end  % cutoff = 11;
    
    % load data and check/repair irregularities
    load_prep_data;    
    
    % run +/-50-yr low pass filter (tw) 
    if(routine_switch(1)==1 | routine_switch(1)==3)
        tw=0.05; movavg;    
        ts_data_t= mavg(:,1); ts_data_v= mavg(:,2);    
    end;
       
    % run  interpolation to equally spaced dates 
    if  routine_switch(1)>=2
%      fprintf('interpolate time interval %1.3f->%1.3f\n',sum(ts_data_t(2:end)-ts_data_t(1:end-1))/nlen,dx);
%      fprintf('%1.3f ... %1.3f\n',0.02*round(50*ts_data_t(1))+dx,ts_data_t(end));
       xinterp = (0.02*round(50*ts_data_t(1))+dx):dx:ts_data_t(end); % interpolationsstellen
       yinterp = interp1(ts_data_t,ts_data_v,xinterp); % lineare interpolation
        ts_data_v = yinterp; ts_data_t = xinterp;
    end;
  
    % transpose row to column vector      
    if size(ts_data_v,2) ==1
        ts_data_v=ts_data_v'; ts_data_t=ts_data_t';     
    end

    % remove trend
    switch routine_switch(2)
    case 1
        ts_data_v = remlintrend(ts_data_t,ts_data_v); % linear
    case 2
        tw=1.; movavg;		% high pass filter 
    end;
    
    % always normalize whole time-series !!!!
    ts_data_v = (ts_data_v - mean(ts_data_v))./std(ts_data_v);
         
    % parameters for spectral method (some will not be used, depending on method)
    iwin = 1; 		% type of window 0:rectangular  1:welch
    n50  = 2;		% number of segments with 50% overlap
    nar1 = 150;		% number of ar1-processes
    ofac = 4;       % oversampling factor (ls)
    hifac = 1;      % hifac - highest frequency to calculate in multiples of nyquist freq. (ofac = 2: 2*fnyquist) (ls)
         
     ts_data_v2=ts_data_v;

    % plot time-series 
    event_freq_1
 % plot_ts;
     
% transform spectral density above red noise spectrum to significance intensity
%    if(routine_switch(5)) spec2gray; end;
    si = si +1;
end
save /home/wirtz/glues/region/EvSeries evseries
fid=fopen('/home/wirtz/glues/region/EvSeries.dat','w');
fprintf(fid,'%1.2f %1.2f %1.2f %1.2f %1.2f %1.2f %1.2f %1.2f %1.2f %1.2f %1.2f %1.2f %1.2f %1.2f %1.2f %1.2f   %1.2f %1.2f\n',evseries(:,1:16)',min(ts_data_t),max(ts_data_t) );
fclose(fid);
