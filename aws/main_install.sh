#!/bin/bash



# Install the yum repo for all the oneAPI packages:
cat << EOF > /etc/yum.repos.d/oneAPI.repo
[oneAPI]
name=Intel(R) oneAPI repository
baseurl=https://yum.repos.intel.com/oneapi
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://yum.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
EOF

# Install various tools we need for users (some of these are probably already on here, but I'm aiming for 
# consistency with the container setup, so duplicates will just be skipped)
yum -y upgrade 
yum -y install vim emacs-nox git subversion which sudo csh make m4 cmake wget file byacc curl-devel zlib-devel
yum -y install perl-XML-LibXML gcc-gfortran gcc-c++ dnf-plugins-core python3 perl-core ftp numactl-devel

# Set up the 'python' alias to point to Python3 -- this is going away for newer CESM releases, I think, but may
# be needed for this 2.1.4-rcX version
ln -s /usr/bin/python3 /usr/bin/python

# Install the 'limited' set of Intel tools we need - note that this also downloads
# and installs >25 other packages, but it's still only a 3GB install, vs the 20GB
# you get from the 'intel-hpckit' meta-package.
yum -y install intel-oneapi-compiler-fortran-2022.0.2 intel-oneapi-compiler-dpcpp-cpp-and-cpp-classic-2022.0.2 

# Now add all our libraries, into /opt/ncar/software/lib so they're accessible by compute nodes:
# (Note: This needs to be cleaned up for better updating of versions later!)
# We do this in /opt so that compute nodes don't need to have all this stuff installed, making
# boot time much faster.  The first line adds our location to the standard LD search path.
echo '/opt/ncar/software/lib' > /etc/ld.so.conf.d/ncar.conf

# Also add the compilers to the /etc/profile.d/oneapi.sh
echo 'source /opt/intel/oneapi/setvars.sh > /dev/null' > /etc/profile.d/oneapi.sh


# OK, check if our precompiled stuff is available; if not, we'll build it:

curl ftp://cesm-inputdata-lowres1.cgd.ucar.edu/cesm/low-res/cloud/software/v0.1/aws/x86/intel/openmpi/software.tar.gz --output /tmp/ncar_software.tar.gz
if [ -f /tmp/ncar_software.tar.gz ]; then
  cd /opt/ncar/ && tar zxvf /tmp/ncar_software.tar.gz
  rm -f /tmp/ncar_software.tar.gz
else
  echo "ERROR: Couldn't download CESM software environment.  This is a problem!  Probably because NCAR's FTP servers have blacklisted the IP.. ask Brian for now."
fi



