./bootstrap && ./configure CC=gcc CXX=g++ \
--with-sisi-include=$HOME/opt/src/SiSi2.2/sisi/include \
--with-sisi-lib=$HOME/opt/src/SiSi2.2/sisi/lib-gcc \
&& (cd src ; gmake -k clean ) &&  gmake -k -j4 && ./run.sh
