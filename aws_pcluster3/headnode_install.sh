#!/bin/bash

curl -o master_install.sh https://raw.githubusercontent.com/briandobbins/CESM_CASE_MANAGEMENT_TOOLS/aws-arise/aws/master_install.sh
sh master_install.sh > /tmp/master_install.log

# add the 'geostrat' user (later, this functionality will be handled by the API)
# We'll check if the /home/geostrat directory exists and call with -M if it does:
groupadd cesm
if [ -d /home/geostrat ]; then
  adduser -c "NCAR GeoStrat" -d /home/geostrat -u 1000 -g cesm -M -s /bin/bash geostrat
else
  adduser -c "NCAR GeoStrat" -d /home/geostrat -u 1000 -g cesm -s /bin/bash geostrat
fi


ln -s /usr/bin/python3 /usr/bin/python

# Set up our search path
#echo '/opt/ncar/software/lib' > /etc/ld.so.conf.d/ncar.conf

# Also add the compilers to the /etc/profile.d/oneapi.sh
echo 'source /opt/intel/oneapi/setvars.sh > /dev/null' > /etc/profile.d/oneapi.sh

# Get CESM2.1.4-rc.10
cd /opt/ncar
git clone -b cesm2.1.4-rc.10 https://github.com/ESCOMP/CESM.git cesm
cd cesm
svn --username=guestuser --password=friendly list https://svn-ccsm-models.cgd.ucar.edu << EOF
p
yes
EOF
#./manage_externals/checkout_externals

# Give sudo access to geostrat:
cat << EOF >> /etc/sudoers.d/91-geostrat
# User rules for ec2-user
geostrat ALL=(ALL) NOPASSWD:ALL
EOF


# Change user limits for ec2-user:
cat << EOF >> /etc/security/limits.conf
ec2-user         hard    stack           -1
ec2-user         soft    stack           -1
geostrat         hard    stack           -1
geostrat         soft    stack           -1
EOF

# Make the scratch/inputdata directory for ec2-user
mkdir -p /scratch/geostrat/inputdata
chown -R geostrat:cesm /scratch/geostrat

# Create the ~/.bashrc for geostrat:
cat << EOF >> /home/geostrat/.bashrc
module load libfabric-aws
export OMP_NUM_THREADS=1

export I_MPI_OFI_LIBRARY_INTERNAL=0
source /opt/intel/oneapi/setvars.sh --force > /dev/null
export I_MPI_FABRICS=ofi
export I_MPI_OFI_PROVIDER=efa

export PATH=\${PATH}:/opt/ncar/software/bin
#export I_MPI_PMI_LIBRARY=/opt/slurm/lib/libpmi.so
EOF

# Add this to our path:
echo 'export PATH=/opt/ncar/cesm/cime/scripts:${PATH}' > /etc/profile.d/cesm.sh
echo 'export CIME_MACHINE=aws-hpc6a' >> /etc/profile.d/cesm.sh
echo 'export LD_LIBRARY_PATH=\${LD_LIBRARY_PATH}:/opt/ncar/software/lib' >> /etc/profile.d/cesm.sh

