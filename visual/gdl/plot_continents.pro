pro plot_continents,psflag=psflag



plotprepare,plot

if not keyword_set(psflag) $
  then plot.psflag=0 $
  else plot.psflag=psflag

plotinit,plot

plot.map_set.projection='cylindrical'
plot.map_set.continents=1
plot.map_set.grid=1
plot.map_set.hires=0


plotmap,plot

end
