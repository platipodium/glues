% test_all_scripts 

% These don't work yet
%add_info_to_proxydescription
%calc_cluster2regionmap
%calc_event_integral



calc_event_series

meanval=calc_geo_mean([30,60],[0,10]);
[latgrid,longrid]=calc_geogrid(3,4);
area=calc_gridcell_area(30,0.5,0.5,1);
%[g,glo,gla]=calc_map_mesh(lon,lat,val,radius,resolution,lonlims,latlims)


calc_regionborders
calc_regioncoasts
calc_regioncolors
calc_regionmap_borders
calc_regionmap_coasts
calc_regionmap_outline
calc_regionpath
calc_replacemany
calc_seas
calc_site_summary
cl_calc_cluster
cl_calc_deforestation
cl_calc_regionpath
cl_calc_seas
cl_calpal
cl_create_regions
cl_def_clustervalue
cl_dump_landcells
cl_dump_regionpath
cl_dump_result
cl_get_hyde
cl_get_ice
cl_get_iiasa
cl_init
cl_load
cl_mmax
cl_npp_lieth
cl_plot_distance_timing
cl_plot_marble
cl_plot_marble_timing_tb
cl_plot_marble_variable
cl_read_iiasa
cl_register_function
cl_vecode
cl_yellow
clm_polygon
clm_vector
clp_cluster
clp_deforestation
clp_iiasa
clp_iiasa_vecode
clp_regionpath_numbers
clp_var_deforestation
cprism
create_regions
db
dislocate_slightly
distribute_around
disturb_chronologies
disturb_chronology
do_cluster_regionmap_regionpath
do_first_visualisation
do_plot_timeseries
do_prepare_timeseries
fep
find_proxy
find_region_numbers
geoidx2geoneighbour
georeference
get_files
get_holodata
get_jetnew
get_map_coords
get_regionvector
get_version
getchi2
getdof
getz
grep
hotcold
lae
lbk_scenarios
minls
movavg
name_regionnumber
offMapMarkerClick
onMapMarkerClick
parse_expression
plot_climber
plot_farming_sites
plot_gdd_npp
plot_globe_topography
plot_hist_replacemany
plot_hyper
plot_iiasa_npp_gdd
plot_leavemanyout
plot_map_anomalies
plot_map_band_cluster
plot_map_band_events
plot_map_band_significance
plot_map_events
plot_map_freqchange
plot_map_markers
plot_map_projections
plot_map_proxysites
plot_map_replacemany
plot_map_replacemany_presence
plot_map_solar_marker
plot_migration_sum
plot_multi_format
plot_multi_variable
plot_npp_lieth
plot_origin_regions
plot_plasim_example
plot_powerspectrum
plot_proxy_overview
plot_redfit
plot_redfit_condensed
plot_region_continents
plot_region_numbers
plot_region_trajectories
plot_regionfluctuation
plot_regionnumber_trajectories
plot_regionpath_id
plot_regionpath_numbers
plot_replacemany
plot_replacemany_sensitivity_tcrit
plot_seas
plot_settlements
plot_single_redfit
plot_single_replacemany
plot_single_timeseries
plot_single_timeseries_anomaly
plot_threshold
plot_timeseries_anomaly
plot_timeseries_anomaly_publication
plot_timeseries_anomaly_redfit_publication
plot_timeseries_publication
plot_variable
plot_variable_deforestation
plot_variable_methane_emission
plot_watch_trajectories
plot_zeder_centers
plotm_region_numbers
print_timeseries_data
qhull_spheric
rainbow
read_cru
read_gluesclimate
read_hyde
read_hyde_asc
read_mapping
read_plasim_example
read_result
read_result_kai
read_textcsv
read_txt_comment
regidx2geoidx
regions_event
remove_singularevents
remove_trend
rhoest
save_coastline
scale_precision
set_paper
showvar
sind
split_france_england_685
struct2stringlines
test_all_scripts
vecode
vecode_co2_enrichment
write_mapping
write_region_climber
write_region_hyde
write_region_iiasa
write_region_iiasaclimber
write_region_iiasaclimber_kai
write_region_lpj
write_region_nppgdd
write_region_plasim
write_region_properties
xget_map_coordinates
