function holodata=get_holodata(datafile)

cl_register_function();

if ~exist('holodata') 
    holodata = read_textcsv(datafile, ';','"'); 
    save('holodata.mat','holodata');
else load 'holodata.mat'; 
end;

return;
