#!/bin/bash

groupadd ctsm -g 1001
# add the 'geostrat' user (later, this functionality will be handled by the API)
# We'll check if the /home/geostrat directory exists and call with -M if it does:
adduser -c "Danica L" -d /home/danical -u 1101 -g ctsm -M -s /bin/bash danical
adduser -c "Will W" -d /home/willw -u 1102 -g ctsm -M -s /bin/bash willw
adduser -c "Negin S" -d /home/negins -u 1103 -g ctsm -M -s /bin/bash negins
adduser -c "Adrianna F" -d /home/adriannaf -u 1104 -g ctsm -M -s /bin/bash adriannaf
adduser -c "Brian D" -d /home/briand -u 1105 -g ctsm -M -s /bin/bash briand

ln -s /usr/bin/python3 /usr/bin/python

# Set up our search path
echo '/opt/ncar/software/lib' > /etc/ld.so.conf.d/ncar.conf

# Also add the compilers to the /etc/profile.d/oneapi.sh
echo 'source /opt/intel/oneapi/setvars.sh > /dev/null' > /etc/profile.d/oneapi.sh

echo 'export LD_LIBRARY_PATH=\${LD_LIBRARY_PATH}:/opt/ncar/software/lib' >> /etc/profile.d/cesm.sh

