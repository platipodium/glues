function clp_deforestation

cl_register_function;


climatefile='hyde_glues_cropfraction.mat';

load(climatefile);

nc=naturalcarbon;
rc=remainingcarbon;

rct=mean(remainingcarbon);
dct=mean(naturalcarbon-remainingcarbon);

plot(rct,'r');
hold on;
plot(dct*10,'b');

pcolor(naturalcarbon-remainingcarbon);
shading interp

return
end
