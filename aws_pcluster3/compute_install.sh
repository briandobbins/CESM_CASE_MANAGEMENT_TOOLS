#!/bin/bash

ln -s /usr/bin/python3 /usr/bin/python

# Set up our search path
echo '/opt/ncar/software/lib' > /etc/ld.so.conf.d/ncar.conf

# Also add the compilers to the /etc/profile.d/oneapi.sh
#echo 'source /opt/intel/oneapi/setvars.sh > /dev/null' > /etc/profile.d/oneapi.sh

echo 'export LD_LIBRARY_PATH=\${LD_LIBRARY_PATH}:/opt/ncar/software/lib' >> /etc/profile.d/cesm.sh

