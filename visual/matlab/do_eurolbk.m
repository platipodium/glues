% Run script for eurolbk paper about spread and migration in Europe

reg='emea';

r=clp_nc_variable('var','region','showvalue',1,'reg',reg);

ti=clp_nc_trajectory('var','technology_spread_by_information','reg',reg);
tp=clp_nc_trajectory('var','technology_spread_by_people','reg',reg);
ei=clp_nc_trajectory('var','economies_spread_by_information','reg',reg);
ep=clp_nc_trajectory('var','economies_spread_by_people','reg',reg);
qi=clp_nc_trajectory('var','farming_spread_by_people','reg',reg);
pp=clp_nc_trajectory('var','migration_density','reg',reg);
t=clp_nc_trajectory('var','technology','reg',reg);
f=clp_nc_trajectory('var','farming','reg',reg);
e=clp_nc_trajectory('var','economies','reg',reg);
p=clp_nc_trajectory('var','population_density','reg',reg);

reg=[271 278 255 242 253 211 216 235 252 183 184 210 198 178 170 147 146 142 177 156 123 122];

for i=1:length(reg)
  j=find(r.value==reg(i));
  figure(reg(i)); 
  clf reset; 
  plot(ti(j,:),'r-'); 
  hold on; 
  plot(tp(j,:),'b-'); 
  plot(t(j,:)/1000,'g--'); 
  plot(q(j,:)/100,'m--'); 
  plot(qp(j,:),'m-');  
end