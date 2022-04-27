#!/bin/bash

groupadd cesm -g 1000
# add the 'geostrat' user (later, this functionality will be handled by the API)
# We'll check if the /home/geostrat directory exists and call with -M if it does:
if [ -d /home/geostrat ]; then
  adduser -c "NCAR GeoStrat" -d /home/geostrat -u 1000 -g cesm -M -s /bin/bash geostrat
fi

ln -s /usr/bin/python3 /usr/bin/python

# Set up our search path
echo '/opt/ncar/software/lib' > /etc/ld.so.conf.d/ncar.conf

# Also add the compilers to the /etc/profile.d/oneapi.sh
echo 'source /opt/intel/oneapi/setvars.sh > /dev/null' > /etc/profile.d/oneapi.sh

echo 'export LD_LIBRARY_PATH=\${LD_LIBRARY_PATH}:/opt/ncar/software/lib' >> /etc/profile.d/cesm.sh

