#!/usr/bin/env bash

wget https://github.com/cea-hpc/modules/releases/download/v5.0.1/modules-5.0.1.tar.bz2

tar xf modules-5.0.1.tar.bz2

cd modules-5.0.1

./configure --prefix=/share/utils/modules/5.0.1 --enable-ml --enable-color --with-tcl=/share/utils/tcltk/8.6.12/lib --with-tclinclude=/share/utils/tcltk/8.6.12/include --with-initconf-in=etcdir --with-tclsh=/share/utils/tcltk/8.6.12/bin/tclsh8.6 --with-editor=vi

sudo make install

ln -s /share/utils/modules/5.0.1/init/profile.sh /etc/profile.d/modules.sh

### Configuration:

# echo -e "
# module use --append {/share/apps/modules/Compilers}
# module use --append {/share/apps/modules/Libraries}
# module use --append {/share/apps/modules/Utilities}
# module use --append {/share/apps/modules/Applications}" | \
# sudo tee -a /share/utils/modules/5.0.1/etc/initrc
