#!/bin/bash

#Usage : Cimc.sh C1 C2
C1=$1
C2=$2

ID=""
PASS=''

BLITZ6="savbu-blitz6.cisco.com"
CLEAR="clear 2> /dev/null"
EXIT="exit"

if [ $# -lt 2 ];
then
    printf "\nPlease provide the Proper Challenge String\n\n"
    ${EXIT} 0
fi

ERROR(){
    ${CLEAR}
    printf "\nSomething went Wrong  while connecting to Blitz Server.\n"
    ${EXIT} 1
}

#Driver Code
${CLEAR}
printf "\nHang on...Processing....\n\n" &
if ! sshpass -p "${PASS}" ssh -t ${ID}@"$BLITZ6" "/router/bin/ct_sign_client -C1 ${C1} -C2 ${C2} -cec;" 2> /dev/null;
then
    ERROR
fi
