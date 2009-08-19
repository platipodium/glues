;-----------------------------------------------
; .pro script for IDL to visualize
; global migration rate 
;
; Carsten Lemmen <c.lemmen@fz-juelich.de>
;----------------------------------------------

pro plot_dyn_npp,psflag=psflag

cd,'/home11/icg126/projects/glues/glues/dist/visual'

dir='../../vecode'
files=file_search(dir,'npp*.tab',count=count)

if count le 0 then return

filename=files[0]


plotprepare,plot
plotinit,plot

if keyword_set(psflag) then begin
  plot.landscape=0
  plot.psflag=psflag
  plot.psfile='dyn_npp'
  plot.stamp=1
endif

s=read_data_file(filename)
;s=get_file(filename,/get_columns,type=1)

; find longest data set
;idata=0
;while idata lt ndata-5 do begin
;  print,data[idata],data[idata+5]
;  idata=idata+6+data[idata+5]
;endwhile

plot.title='Data source: ' + filename

lat=90-data[2,*]/2
lon=data[3,*]/2-180

plotmap,plot
plot.new=0

plot.psym=plot.symbols.point
plotxy_2d,plot,x=lon,y=lat,z=data[5,*]

plot.psym=0
plot.color=0

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
