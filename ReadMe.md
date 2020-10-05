# Global Land Use and technological Evolution Simulator (GLUES)

## Installation

Glues is set up for building on many platforms.  To facilitate cross-platform compatibility, the
GNU autotools are used.

### Quick install

From the `.tgz` distribution archive, run the file `./configure`, then make
    
    ./configure && make

You should (but you can) not install GLUES in your system, rather use the provided example scripts `run*.sh` do execute glues.

### More detailed installation

1. If you downloaded the developer's version via mercurial CVS, you don't have a `./configure` script.  You can
    create this with the `./bootstrap` shell script. 

       ./bootstrap
       libtoolize

2. Run `./configure`, you can find generic help on configure options in the file `INSTALL`.

        ./configure

3. If there are WARNING messages at the end of `./configure`, please see below, otherwise, continue to building

4. Run `make` (preferably gnu make) to build the glues system,  you should end up with an executable glues in 
    the directory src.

### Warnings and errors during installation

1. WARNING: no configuration information is in `src/sisi`  
    There is no `./configure` in the subdirectory sisi; this is only needed if you don't have the sisi library
    installed elsewhere on your system, i.e., if you need a new build of sisi

    Go to `src/sisi` and issue `./bootstrap`, if you get errors, run `autoreconf -fvi`, then `./bootstrap` again

        (cd src/sisi; ./bootstrap || autoreconf -fvi && ./boostrap)
   
    Run `./configure` and `make`, and put the libraries into the lib directory

      (cd src/sisi; ./configure && gmake )
      (cp src/sisi/lib/.libs/libSiSi* src/sisi/lib/) 

2. Doxygen not found but required to build documentation
    There is no doxygen on this system, and the documentation will not be build.  This doesn't prevent you from
    running GLUES.  If you need the API documentation, install doxygen, and run configure again.

3. Cannot find -lSiSi
    You might have to copy the `libSiSi.* `files to `src/sisi/li` (see above 1.)


4. `Makefile.i` not created: please upgrade your version of libtool

### What do do if you don't get sisi to build or run

1. Download the sisi package from the sourceforge site
    `https://sourceforge.net/projects/glues/files/sisi/SiSi2.2.tgz/download`

2. Unpack the .tgz file and change to sisi directory

3. run `gmake lib` to make the sisi library

4. copy `lib/libsisi.*` to your systems library directory, ranlib libsisi.* and make an alias of this library
    under the name libSiSi.* and under the name libSiSi2.0.*

5. copy include to your systems include directory
 
6. Go back to your glues distribution

7. Create an empty Makefile in src/sisi

        echo 'all:' > src/sisi/Makefile

8.  

       ./configure --with-sisi=<directory where you copied sisi lib and include> in glues directory
 
