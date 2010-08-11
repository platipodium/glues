function [retdata,basename]=clp_cru_bycountry(varargin)


arguments = {...
  {'timelim',[1901,2000]},...
  {'lim',[-inf,inf]},...
  {'variable','pre'},...
  {'country','pakistan'},...
  {'scale','absolute'},...
  {'figoffset',0},...
  {'nosum',0},...
  {'nocolor',0},...
  {'retdata',NaN},...
  {'nearest',0}
};

cl_register_function;

[a,rargs]=clp_arguments(varargin,arguments);
for i=1:a.length eval([a.name{i} '=' clp_valuestring(a.value{i}) ';']); end


filename=fullfile('data',['tyn_cru2.0_bycountry_' country '.txt']);
if ~exist(filename,'file') error('File does not exist'); end

d=load(filename,'-ascii');
d(d<0)=NaN;
year=d(:,1);
mprec=d(:,2:13); % monthly prec
sprec=d(:,14:17); % seasonal prec
aprec=d(:,18); % annual prec

figure(1);
clf reset;
hold on

bar(1929,120,2,'y','EdgeColor','none');
nyear=length(year);
mtime=year(1)-11/24.:1/12.:year(nyear)+11./24.;
plot(mtime,reshape(mprec',nyear*12,1),'k-');
%plot(year,sprec(:,1)/4.0,'m-','LineWidth',3);
plot(year,sprec(:,2)/4.0,'m-','LineWidth',2);
%plot(year,sprec(:,3)/4.0,'m-','LineWidth',3);
%plot(year,sprec(:,4)/4.0,'g--','LineWidth',3);
plot(year,aprec/12.,'r-','LineWidth',4);

legend('1929','Monthly','Wet season','Annual');
ylabel('Precipitation (mm/month)');
xlabel('Year');

title(['Monthly rainfall CRU TS 2.0 by country ' country]);

set(gca,'XLim',[year(1)-1,year(end)+1],'Ylim',[0 120]);

print('-dpng',['cru_rain_' country]);

%% Plot frequency distribution
figure(2);
clf reset;

nfft=2.^nextpow2(nyear);
yfft=fft(aprec,nfft)/nyear;
freq=1/2.0*linspace(0,1,nfft/2+1);

% Plot single-sided amplitude spectrum.
plot(freq,2*abs(yfft(1:nfft/2+1))) 
title('Single-Sided Amplitude Spectrum of annual precipitation')
xlabel('Frequency (1/a)')
ylabel('|P(freq)|');






end















