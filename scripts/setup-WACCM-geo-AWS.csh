#!/bin/csh -fx
### set env variables

setenv CESM2_TOOLS_ROOT /home/geostrat/CESM_CASE_MANAGEMENT_TOOLS
setenv CESMROOT /opt/ncar/cesm

set COMPSET = BWSSP245cmip6
set SCENARIO = SSP245
set VERSION = TSMLT
set NAMESIM = DELAYED-2045
set ENS = 001
set MACHINE = aws-arise
set RESOLN = f09_g17
set RESUBMIT = 0
set STOP_N=1
set STOP_OPTION=nyears

set smbr =  1
set embr =  1

@ mb = $smbr
@ me = $embr

foreach mbr ( `seq $mb $me` )

if    ($mbr < 10) then
  setenv CASENAME  b.e21.BW.${RESOLN}.${SCENARIO}-${VERSION}-GAUSS-${NAMESIM}.00${mbr}
  setenv REFCASE   b.e21.BWSSP245cmip6.f09_g17.CMIP6-SSP2-4.5-WACCM.00${mbr}
else
  setenv CASENAME  b.e21.BW.${RESOLN}.${SCENARIO}-${VERSION}-GAUSS-${NAMESIM}.0${mbr}
  setenv REFCASE   b.e21.BWSSP245cmip6.f09_g17.CMIP6-SSP2-4.5-WACCM.0${mbr}
endif

setenv CASEROOT  /home/geostrat/cases/$CASENAME
#setenv CASEROOT  /glade/scratch/$USER/$CASENAME
setenv REFDATE  2045-01-01
#setenv REFROOT  /scratch/geostrat/archive/$REFCASE/rest/${REFDATE}-00000/
setenv REFROOT /scratch/geostrat/archive/restarts/${REFDATE}-00000  
setenv STARTDATE  $REFDATE
set RUNDIR = /scratch/$USER/$CASENAME/run/

$CESMROOT/cime/scripts/create_newcase --compset ${COMPSET} --res f09_g17 --case ${CASEROOT}

  cd $CASEROOT

  ./xmlchange NTASKS_CPL=576
  ./xmlchange NTASKS_ATM=576
  ./xmlchange NTASKS_LND=576
  ./xmlchange NTASKS_ICE=576
  ./xmlchange ROOTPE_ICE=0
  ./xmlchange NTASKS_OCN=576
  ./xmlchange ROOTPE_OCN=0
  ./xmlchange NTASKS_ROF=576
  ./xmlchange NTASKS_GLC=576
  ./xmlchange NTASKS_WAV=36
  ./xmlchange ROOTPE_WAV=0
  ./xmlchange NTASKS_ESP=1
  ./xmlchange NTHRDS=1

  ./xmlchange RUN_REFCASE=$REFCASE
  ./xmlchange RUN_REFDATE=$REFDATE
  ./xmlchange RUN_STARTDATE=$STARTDATE
  ./xmlchange GET_REFCASE=FALSE

  cp $CESM2_TOOLS_ROOT/SourceMods/src.cam/* $CASEROOT/SourceMods/src.cam/
  cp $CESM2_TOOLS_ROOT/user_nl_files/geo/user_nl_* $CASEROOT/

  mv  env_batch.xml tmp.batch
  cat tmp.batch | sed 's/-N {{ job_id }}/-N TSMLT.{{ job_id }}/' > env_batch.xml
  ./case.setup

  ./xmlchange STOP_N=$STOP_N
  ./xmlchange STOP_OPTION=$STOP_OPTION
  ./xmlchange RESUBMIT=$RESUBMIT

  ./xmlchange PIO_TYPENAME=netcdf



echo " Copy Restarts -------------"
if (! -d $RUNDIR) then
        echo 'mkdir ' $RUNDIR
        mkdir -p $RUNDIR
endif

   cp    ${REFROOT}/rpointer* $RUNDIR/
   ln -s ${REFROOT}/b.e21*    $RUNDIR/

echo " End restarts copy -----------"

   ./case.setup --reset; ./case.setup
   #./case.setup --reset; ./case.setup; ./case.build >& bld.`date +%m%d-%H%M`


# Create the postprocessing stuff:
   create_postprocess --caseroot=${PWD}

# Get the controller stuff:
   git clone https://github.com/briandobbins/feedback_suite.git controller # Update with Dan's new stuff


end  # member loop

exit

