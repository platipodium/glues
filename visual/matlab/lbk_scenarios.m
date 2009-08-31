function lbk_scenarios

scenarios={
'base',
'events',
'nospread',
'spreadm000',
'spreadm005',
'spreadm010',
'spreadm066',
'spreadm133',
'spreadv000',
'spreadv007',
'spreadv030',
'spreadv200m0035',
'spreadv700',
'spreadv700m001',
'spreadvInfmZero'
}

n=length(scenarios)

for i=1:n
    
    read_result(['results_' scenarios{i} '.out']);
    cl_plot_marble_variable('sce',scenarios{i},'time',[3000,2980],'fig',i);
end