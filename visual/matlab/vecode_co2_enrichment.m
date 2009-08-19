function npp=vecode_co2_enrichment(npp,co2)
  % CO2 enrichment factor 

cl_register_function();

  if ~exist('co2','var') co2=280; end;
  
  npp=npp*(1+0.25*(log(co2/280.)/log(2.0)));

return
end
