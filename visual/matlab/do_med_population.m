function do_med_population
%% Evaluate Mediterranean population to compare with Boris Vanniere's
% Global Charcoal database fire activity results

timelim=[-6500, -500];
latlim=[25 50];
lonlim=[-15 40];

% Region definitions
submed=[202,177,196]-1;
mesomed=[228 209 202 215 196 210]-1;
thermomed=[250 262 251 215 327 302 314 303 293 304 277 342]-1;
eastmed=[235 252 253 255 242 271 357]-1;



clp_nc_variable('var','region','reg',submed,'latlim',latlim,'lonlim',lonlim);


return;
end