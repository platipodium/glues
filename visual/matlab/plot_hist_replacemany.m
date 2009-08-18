function plot_hist_replacemany

cl_register_function();

if ~exist('year','var') year=6000; end
if ~exist('ratio','var') ratio=33; end
if ~exist('fignum','var') fignum=1; end
if ~exist('fmin','var') fmin=200; end
if ~exist('fmax','var') fmax=1800; end

matfile=['replacemany_' num2str(year) '_' num2str(ratio) '.mat'];

matfile='replacemany_5.5_0.5_eleven_33.mat';

if ~exist(matfile,'file') 
    fprintf('Required file %s does not exist.',matfile);
    fprintf('Please copy or recreate with calc_replacemany.m.' );
    return; end;
load(matfile);

r=rmdata;

valid=find( ~isnan(r.lat) & r.Freq>0 ...
    & ~strncmp(cellstr(r.Site),'sunspot_natur_',14) ...
    & ~strncmp(cellstr(r.Site),'Greenland_Be10',14) ...
    & ~strncmp(cellstr(r.Site),'GISP2_intcal98',14) ...
);
nvalid=length(valid);

validsun=find( ~isnan(r.lat) & r.Freq>0 ......
    & ( strncmp(cellstr(r.Site),'sunspot_natur_',14) ...
      | strncmp(cellstr(r.Site),'Greenland_Be10',14) ...
      | strncmp(cellstr(r.Site),'GISP2_intcal98',14)) ...
);
nvalidsun=length(validsun);

site=r.Site(valid);
f=r.Freq(valid);
lat=r.lat(valid);
lon=r.lon(valid);

fprintf('%5d non-solar analysed proxies\n',length(unique(site)));

fprintf('%5d local frequency peaks\n',length(f));
fprintf('%5d local upper frequency peaks\n',sum(r.isupp(valid)));
fprintf('%5d local lower frequency peaks\n',sum(r.islow(valid)));
fprintf('%5d local total frequency peaks\n\n',sum(r.istot(valid)));

isstatic=(r.islow(valid) & r.isupp(valid) & r.istot(valid));
islowtot=(r.islow(valid) & ~r.isupp(valid) & r.istot(valid));
isupptot=(~r.islow(valid) & r.isupp(valid) & r.istot(valid));
islow=(r.islow(valid) & ~r.isupp(valid) & ~r.istot(valid));
isupp=(~r.islow(valid) & r.isupp(valid) & ~r.istot(valid));

fprintf('%5d stable (tot/low/upp) peaks\n',sum(isstatic));
fprintf('%5d disappear (tot/low) peaks\n',sum(islowtot));
fprintf('%5d    appear (tot/upp) peaks\n',sum(isupptot));
fprintf('%5d disappear (low only) peaks\n',sum(islow));
fprintf('%5d    appear (upp only) peaks\n',sum(isupp));

figure(1); clf reset;

[n,x] = hist(1./f);
dx=x(2)-x(1);
bar(x,n,0.9,'k');
xt=round(1./get(gca,'XTick'));
xtl=num2str(xt');
set(gca,'XTickLabel',xtl);
xlabel('Cyclicity (a)');
ylabel('Number of peaks');

hold on;
lw=0.4;

bar(x-0.5*lw*dx,hist(1./f(find(r.isupp(valid))),x),lw,'c');
bar(x+0.5*lw*dx,hist(1./f(find(r.islow(valid))),x),lw,'y');

lw=0.15;
bar(x-2*lw*dx,hist(1./f(islowtot),x),lw,'r');
bar(x-1*lw*dx,hist(1./f(islow),x),lw,'m');
bar(x+0*lw*dx,hist(1./f(isstatic),x),lw,'g');
bar(x+1*lw*dx,hist(1./f(isupptot),x),lw,'b');
bar(x+2*lw*dx,hist(1./f(isupp),x),lw,'c');

legend('All','Upper','Lower','low+tot','low','static','upp+tot','upp','Location','NorthEast');
plot_multi_format(1,'hist_replacemany');

return
end
