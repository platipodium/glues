function lbk_scenarios


scenarios={
't28',
't37',
't46',
't55',
't64',
't73',
't82',
't91',
's0',
's1',
's2',
's3',
's4',
's5',
's6',
's7',
%}
%
%other ={
'v0m0',
'v1m0',
'v2m0',
'v3m0',
'v4m0',
'v5m0',
'v6m0',
'v7m0',
'v8m0',
'v9m0',
'v1m1',
'v1m2',
'v1m3',
'v1m4',
'v1m5',
'v1m6',
'v3m0',
'v3m1',
'v3m2',
'v3m3',
'v3m4',
'v3m5',
'v3m6',
'v3m7',
'v3m8',
'v3m9',
'base',
'nospread',
'events',
}

n=length(scenarios)

for i=1:n
    
    read_result(['results_' scenarios{i} '.out']);
    cl_plot_marble_timing('sce',scenarios{i});
end