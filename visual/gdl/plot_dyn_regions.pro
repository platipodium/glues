;-----------------------------------------------
; .pro script for IDL to visualize
; global migration rate 
;
; Carsten Lemmen <c.lemmen@fz-juelich.de>
;----------------------------------------------

pro plot_dyn_regions,psflag=psflag

cd,'/home11/icg126/projects/glues/glues/dist/visual'

dir='../../region'
files=file_search(dir,'regions_44_000.dat',count=count)

if count le 0 then return

filename=files[0]


plotprepare,plot
plotinit,plot

if keyword_set(psflag) then begin
  plot.landscape=0
  plot.psflag=psflag
  plot.psfile='dyn_regions'
  plot.stamp=1
endif

file_as_string=get_file(filename)
ndata=n_elements(file_as_string)
;ndata=20
data=make_array(6,ndata,value=0)
for idata=1,ndata-1 do begin
  line=file_as_string(idata)
  splitline=strsplit(line,': '+string(9b),/extract)
  ;print,format='(A,I2,A)',splitline[0]+':',n_elements(splitline),' '+line
  ireg=long(splitline[0])
  data[0:5,ireg]=long(splitline[0:5])
endfor


; find longest data set
;idata=0
;while idata lt ndata-5 do begin
;  print,data[idata],data[idata+5]
;  idata=idata+6+data[idata+5]
;endwhile

plot.title='Data source: ' + filename

lat=reform(90-data[4,*]/2)
lon=reform(data[3,*]/2-180)

plotmap,plot
plot.new=0


plot.psym=plot.symbols.square_f
plot.symsize=0.5
plot.color=0

plotxy,plot,x=lon,y=lat
plot.psym=0

for idata=1,ndata-1 do begin
  line=file_as_string(idata)
  splitline=strsplit(line,': '+string(9b),/extract)
  ;print,format='(A,I2,A)',splitline[0]+':',n_elements(splitline),' '+line
  numneighs=splitline[5]
  ireg=splitline[0]
  for in=0,numneighs-1 do begin
	neigh=splitline[6+2*in]
	plot.new=3
	plotxy,plot,x=[lon[neigh],lon[ireg]],y=[lat[neigh],lat[ireg]]
  endfor
endfor

    for idata=1,-1 do begin
	plot.yrange=[0,1.8]
        plot.psym=0
        plot.color=idata
        plot.legend_name=string(form='(A8,A,I2)',columnames[idata],' 10E',logmax)
        plotxy,plot,x=time,y=value/(10^logmax)
        plot.new=plotnew
    endfor

plotend,plot
end
