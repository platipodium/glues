;-----------------------------------------------
; .pro script for IDL to visualize
; npp - ndom -fert relationship
;
; Carsten Lemmen <c.lemmen@fz-juelich.de>
;----------------------------------------------

pro npp_ndom_fert,psflag=psflag

filename='../npp_ndom_fert.dat'

if file_exist(filename) then s=read_data_file(filename) else s=read_data_file()

npp =reform(s.data[0,*])
ndom=reform(s.data[1,*])
fert=reform(s.data[2,*])

plotprepare,plot
plotinit,plot

if keyword_set(psflag) then begin
  plot.psflag=psflag
  plot.psfile='npp_ndom_fert'
  plot.stamp=1
endif

plot.title='Data source: ' + filename
plot.legend_position=3
plot.psym=-plot.symbols.circle
plot.color=1
plot.xtitle='NPP [g m!e-2!N yr!E-1!N]'
plot.legend_name='Relative number of!Clocal agro-pastoral economies (LAE)'
plotxy,plot,x=npp,y=ndom

plot.new=0
plot.color=2
plot.psym=-plot.symbols.circle_f
plot.legend_name='Food extraction potential (FEP)'
plotxy,plot,x=npp,y=fert

plotend,plot
end
