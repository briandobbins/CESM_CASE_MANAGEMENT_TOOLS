#!/bin/bash

curl -o main_install.sh https://raw.githubusercontent.com/briandobbins/CESM_CASE_MANAGEMENT_TOOLS/openmpi/aws/main_install.sh
sh main_install.sh > /tmp/main_install.log


# Also add the compilers to the /etc/profile.d/oneapi.sh
echo 'source /opt/intel/oneapi/setvars.sh > /dev/null' > /etc/profile.d/oneapi.sh

# Get CESM2.1.4-rc.10
cd /opt/ncar
git clone -b aws_openmpi_batch https://github.com/briandobbins/CESM cesm
cd cesm
svn --username=guestuser --password=friendly list https://svn-ccsm-models.cgd.ucar.edu << EOF
p
yes
EOF
./manage_externals/checkout_externals


# Change user limits for ec2-user:
cat << EOF >> /etc/security/limits.conf
ec2-user         hard    stack           -1
ec2-user         soft    stack           -1
EOF

# Make the scratch/inputdata directory for ec2-user
mkdir -p /scratch/ec2-user/inputdata
chown -R ec2-user:ec2-user /scratch/ec2-user

# Create the ~/.bashrc for ec2-user:
cat << EOF >> /home/ec2-user/.bashrc
module load libfabric-aws
export OMP_NUM_THREADS=1


export PATH=/opt/ncar/software/bin:\$PATH

alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"
EOF

# Add this to our path:
echo 'export PATH=/opt/ncar/cesm/cime/scripts:${PATH}' > /etc/profile.d/cesm.sh
echo 'export CIME_MACHINE=aws-hpc6a' >> /etc/profile.d/cesm.sh
echo 'export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/opt/ncar/software/lib' >> /etc/profile.d/cesm.sh

