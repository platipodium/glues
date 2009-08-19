;-----------------------------------------------
; .pro script for IDL to visualize
; global migration rate 
;
; Carsten Lemmen <c.lemmen@fz-juelich.de>
;----------------------------------------------

pro spread_res,psflag=psflag

cd,'/home11/icg126/projects/glues/glues/glues/visual'

dir='../data/test'
files=file_search(dir,'spread*.res',count=count)

if count le 0 then return

plotprepare,plot
plot.landscape=0

if keyword_set(psflag) then begin
  plot.landscape=0
  plot.psflag=psflag
  plot.psfile='spread_res'
  plot.stamp=1
endif

plotinit,plot
plot.rows=2
plot.columns=2
plot.legend_position=0
plot.xtitle='Time [yr BP]'
plot.y_interstice=80

ifile=0

s=read_data_file(files[ifile])
plot.page_title='Data source: ' + files[ifile]

nrows=n_elements(s.data[*,0])
ncols=n_elements(s.data[0,*])

length=5
start=10
time=long(reform(s.data[0,*])*10)

nregions=(nrows-1)/6

for iregion=0,nregions-1 do begin

  for irow=1+iregion*6,(iregion+1)*6 do begin
    thiscase = irow mod 6
    plot.yrange=[-30,50]
    data=reform(s.data[irow,*])
    if max(data) eq min(data) then continue
    plot.color=thiscase
    case thiscase of 
	1: data=5*data
	2: data=1*data
	3: data=10*data
	5: data=10*data
    endcase	
    plot.psym=plot.symbols.point
    plotxy,plot,x=time,y=data
    plot.new=0
  endfor
 plot.new=1
endfor

plotend,plot
end
