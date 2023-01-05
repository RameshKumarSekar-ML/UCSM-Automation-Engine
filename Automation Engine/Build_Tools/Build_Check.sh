#!/bin/bash
NOHUP_MAKE_SAM="nohup make sam"
${NOHUP_MAKE_SAM} >& logfile &
while [ ${BUILD_RET_CODE} -ne 0 ]
do
    BUILD_STATUS=$!
    wait ${BUILD_STATUS}
    BUILD_RET_CODE=$?
done
