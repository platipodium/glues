cl_register_function();


%  1. Create a cluster
%calc_cluster

% 2. convert to regionmap (grid based)
calc_cluster2regionmap;

% 3. Add sea information
calc_seas;

% 4. calculate vector path around regions
calc_regionpath;

% 5. Add border information
calc_regionborders;
