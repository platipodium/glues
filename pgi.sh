./bootstrap && ./configure CC=pgcc CXX=pgCC \
--with-sisi-include=$HOME/opt/src/SiSi2.2/sisi/include \
--with-sisi-lib=$HOME/opt/src/SiSi2.2/sisi/lib-pgi \
&& (cd src ; gmake -k clean ) 
gmake -k -j4 || (cd src gmake -k j4)
 ./run.sh
