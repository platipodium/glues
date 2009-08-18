function calc_seas

cl_register_function();

load('/h/lemmen/projects/glues/glues/glues/examples/setup/686/mapping_80_685.mat');

[cols rows]=size(regionmap);

% Set water to 999 in regionmap
tmpmap=regionmap.*0-1;
tmpmap(regionindex)=regionnumber;
iwater=find(tmpmap < 0);
nwater=length(iwater);
regionmap(iwater)=-10;

latmap=ones(720,1) * latgrid;
lonmap=longrid' * ones(1,360);
 
imedi=find(lonmap >= -5.3 & lonmap <= 37 ...
        & latmap <= 46.5   & latmap >= 30 ...
        & (latmap <= 40 | lonmap >= 0) ...
        & (latmap <= 41 | lonmap <= 22 & regionmap < 0));
regionmap(imedi)=-200;

iblack=find(latmap >= 41 & latmap <= 48 ...
         & lonmap >= 22 & lonmap <= 45  & regionmap < 0);
regionmap(iblack)=-300;

ired= find(latmap <= 30 & latmap >= 12 ...
         & lonmap >= 32 & lonmap <= 43.5 & regionmap < 0);
regionmap(ired)=-400;

ipersian= find(latmap <= 32 & latmap >= 23 ...
         & lonmap >= 47 & lonmap <= 57 & regionmap < 0);
regionmap(ipersian)=-450;

icaspian= find(latmap <= 50 & latmap >= 35 ...
         & lonmap >= 47 & lonmap <= 54 & regionmap < 0);
regionmap(icaspian)=-350;

ibaltic= find( (latmap <= 56 & latmap >= 53 ...
         & lonmap >= 9 & lonmap <= 32) ...
         | (latmap >= 56 & latmap <= 66 ...
         & lonmap >= 13 & lonmap <= 32 ) & regionmap < 0);
regionmap(ibaltic)=-650;

save('regionmap','lat','lon','latgrid','longrid','regionarray',...
'regionindex','regionlength','regionmap','regionnumber');

return
