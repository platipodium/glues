;-----------------------------------------------
; .pro script for IDL to visualize
; global migration rate 
;
; Carsten Lemmen <c.lemmen@fz-juelich.de>
;----------------------------------------------

pro watch_res,psflag=psflag

cd,'/home11/icg126/projects/glues/glues/glues/visual'

dir='../data/test'
files=file_search(dir,'*watch.res',count=count)

if count le 0 then return

columnames= ['time','tlim','fert','prod','rgrowth','dens','techn','ndom','qfarm','germs','disease']
ndata=n_elements(columnames)

plotprepare,plot
plot.landscape=0

if keyword_set(psflag) then begin
  plot.landscape=0
  plot.psflag=psflag
  plot.psfile='watch_res'
  plot.stamp=1
endif

plotinit,plot
plot.rows=count
plot.legend_position=0
plot.xtitle='Time [yr BP]'
plot.y_interstice=80

plotnew=0
for ifile=0,count-1 do begin

    s=read_data_file(files[ifile])
    plot.title='Data source: ' + files[ifile]
    time=reform(s.data[0,*])*10-9000
    for idata=1,ndata-1 do begin
        value=reform(s.data[idata,*])
	logmax=round(alog10(max(abs(value))))
	plot.yrange=[0,1.8]
        plot.psym=0
        plot.color=idata
        plot.legend_name=string(form='(A8,A,I2)',columnames[idata],' 10E',logmax)
        plotxy,plot,x=time,y=value/(10^logmax)
        plot.new=plotnew
    endfor
;plot.legend_title=''    
    plot.new=1
    plotnew=3

endfor

plotend,plot
end
