#!/bin/bash

CASENAME=
CASE_ROOT=/home/geostrat/cases/${CASENAME}
ARCHIVE_ROOT=/scratch/geostrat/archive/${CASENAME}
TARGET_BUCKET=s3://cesm-arise-aws
CPL_BUCKET=s3://cesm-arise-aws-cplhist

# Change to archive directory
cd ${ARCHIVE_ROOT}

# Do the timeseries sync
echo "-- TS Sync Start : $(date) --"
for dir in $(find * -name proc); do
  TARGET_DIR=${TARGET_BUCKET}/${CASENAME}/${dir}
  echo "COMMAND: aws s3 cp ${dir}/ ${TARGET_DIR} --recursive --quiet "
  aws s3 cp ${dir}/ ${TARGET_DIR} --recursive --quiet &
done
wait
echo "-- TS Sync Finish : $(date) --"

# Do the yearly restarts:
echo "-- Restart Sync Start : $(date) --"
for dir in $(find rest -name \*-01-01-00000 -type d); do
  TARGET_DIR=${TARGET_BUCKET}/${CASENAME}/${dir}
  echo "COMMAND: aws s3 cp ${dir}/ ${TARGET_DIR} --recursive --quiet "
  aws s3 cp ${dir}/ ${TARGET_DIR} --recursive --quiet 
done
echo "-- Restart Sync Finish : $(date) --"

# Do the latest controller log:
echo "-- Controller Sync Start : $(date) --"
TARGET_DIR=${TARGET_BUCKET}/${CASENAME}
echo "COMMAND: aws s3 cp ${CASE_ROOT}/controller/ControlLog_${CASENAME}.txt  ${TARGET_DIR}/ --quiet "
aws s3 cp ${CASE_ROOT}/controller/ControlLog_${CASENAME}.txt  ${TARGET_DIR}/ --quiet
echo "-- Controller Sync Finish : $(date) --"


# Copy the coupler files to the other bucket:
echo "-- CPL Sync Start : $(date) --"
TARGET_DIR=${CPL_BUCKET}/$(basename $ARCHIVE_ROOT)/cpl/hist
echo "COMMAND: aws s3 cp cpl ${TARGET_DIR} --recursive --quiet"
aws s3 cp cpl ${TARGET_DIR} --recursive --quiet
echo "-- CPL Sync Finish : $(date) --"

# Remove the archive directory
echo "COMMAND: rm -rf ${ARCHIVE_ROOT}"
# rm -rf ${ARCHIVE_ROOT}
