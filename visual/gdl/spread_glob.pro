;-----------------------------------------------
; .pro script for IDL to visualize
; global migration rate 
;
; Carsten Lemmen <c.lemmen@fz-juelich.de>
;----------------------------------------------

pro spread_glob,psflag=psflag

cd,'/home11/icg126/projects/glues/glues/glues/visual'

dir='../data/test'
files=file_search(dir,'spread*.res',count=count)

if count le 0 then return

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

ifile=0

s=read_data_file(files[ifile])
plot.title='Data source: ' + files[ifile]

nrows=n_elements(s.data[*,0])
ncols=n_elements(s.data[0,*])


length=5
start=10


for irow=start,min([start+length,nrows]) do begin
  plot.ytype=0
  plot.yrange=[-10,40]
  plot.color=irow-1
  plot.psym=0
  plotxy,plot,x=reform(s.data[0,*]),y=reform(s.data[irow,*]);
  plot.new=0
endfor

plotend,plot
end
