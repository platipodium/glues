;-----------------------------------------------
; .pro script for IDL to visualize
; global migration rate 
;
; Carsten Lemmen <c.lemmen@fz-juelich.de>
;----------------------------------------------

pro plot_dyn_mapping,psflag=psflag

cd,'/home11/icg126/projects/glues/glues/dist/visual'

dir='../../region'
files=file_search(dir,'mapping_04_000.dat',count=count)

if count le 0 then return

filename=files[0]


plotprepare,plot

if keyword_set(psflag) then begin
  plot.landscape=1
  plot.psflag=psflag
  plot.psfile='dyn_regions'
  plot.stamp=2
endif
plotinit,plot

file_as_string=get_file(filename)
ndata=n_elements(file_as_string)
;ndata=20
data=make_array(ndata,value=0)
for idata=1L,ndata-1 do begin
  line=file_as_string(idata)
  splitline=strsplit(line,' ',/extract)
  data[idata-1]=long(splitline[0])
  if idata eq 1 then index=long(splitline[1:*]) $
	else index=[index,long(splitline[1:*])]
endfor


; find longest data set
;idata=0
;while idata lt ndata-5 do begin
;  print,data[idata],data[idata+5]
;  idata=idata+6+data[idata+5]
;endwhile

plot.title='Data source: ' + filename

dx=index/720
dy=index mod 720

lon=reform(dy/2.-180.)
lat=reform(90.-dx/2.)

plotmap,plot
plot.new=0


plot.psym=plot.symbols.square_f
plot.symsize=0.1
plot.color=0

z=reform(data)
color=(z+10*(z mod 10)) mod 30

plotxy_2d,plot,x=lon,y=lat,z=lon*0


plotend,plot
end
