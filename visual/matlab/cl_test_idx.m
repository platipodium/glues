function cl_test_idx

cols=720;
rows=360;

disp('regular')
cl_lli2i(1,1)==1 
cl_lli2i(1,2)==2
cl_lli2i(1,cols)==cols

cl_lli2i(rows,1)==(rows-1)*cols+1
cl_lli2i(rows,2)==(rows-1)*cols+2
cl_lli2i(rows,cols)==rows*cols

disp('bounds')
cl_lli2i(0,1) 
cl_lli2i(-1,1) 
cl_lli2i(rows+1,1) 
cl_lli2i(rows+1,1) 




[la,lo]=cl_i2lli(1)
[la,lo]=cl_i2lli(2)
[la,lo]=cl_i2lli(cols)
[la,lo]=cl_i2lli((rows-1)*cols+1)
[la,lo]=cl_i2lli((rows-1)*cols+2)
[la,lo]=cl_i2lli(rows*cols)

end