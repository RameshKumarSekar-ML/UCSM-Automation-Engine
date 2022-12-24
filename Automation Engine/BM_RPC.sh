#!/bin/bash

##################################################################################################
#      BM_RPC.sh  : Dependency Script that will Remotely Invoke Instruction's                     #
#                   This script couldn't be Executed Autonomously.                                #
#                                                                                                 #
#           File : BM_RPC.sh                                                                      #
#       Engineer : rameseka                                                                       #
#                                                                                                 #
###################################################################################################

ID="$USER"
CTRL_ARG=$1
BUID_MACHINE=$2
BUID_MACHINE_PASS=$3
BM_DESTN_PATH=$4
IP=$5
# IP="${@: -1}"
CLI_AG_CHOICE=$6

C1="$2"
C2="$3"

ADMINBACKUP="adminbackup"
ADMINBACKUP_PASSWD="nbv12345"
Retry_Exhausted=2
KEYGEN="ssh-keygen -R"
CLEAR="clear 2> /dev/null"

SSH="sshpass -p $ADMINBACKUP_PASSWD ssh -t $ADMINBACKUP@$IP"
SCRIPT="/users/rameseka/RPC_Scripts/BLITZ_RPC.sh"

function ERROR(){
    ${CLEAR}
    local Ret_Value=$1

    if [ "${Ret_Value}" -eq ${Retry_Exhausted} ]
    then
        printf "\nERROR :Connection Retries to %s Exhausted\n" "$IP"
        printf "\n *Please check if either %s is Valid IP \n *Check If %s Adminbackup Shell is Accessible\n *Check If Setup is Up & Running \n\n" "$IP" "$IP"
        exit $Retry_Exhausted
    else
        printf "\nSomething went Wrong  while connecting to %s \n" "$IP"
        printf "\n *Please check if either %s is Valid IP \n *Check If %s Adminbackup Shell is Accessible\n *Check If Setup is Up & Running \n\n" "$IP" "$IP"
        exit 0
    fi
}

###########################################################################
# Establish a SSH Connection Make an BLITZ RPC Call.                      #
#                                                                         #
# Arguments:                                                              #
#   CTRL_ARG  ,BUILD_MACHINE_IP ,BUILD_MACHINE_PASS , BM_DESTN_PATH, IP   #
#                                                                         #
#Returns:                                                                 #
#       Success / Failure Return Value                                    #
###########################################################################

function SSH_CONNECT()
{
    #TBD : Make all the Variable Local to this Scope 
    local BASH="bash -s"
    local CTRL_ARG=$1
    local ID=$2
    local BUID_MACHINE=$3
    local BUID_MACHINE_PASS=$4

    if [ "${CTRL_ARG}" != "START" ]  && [ "${CTRL_ARG}" != "start" ]
    then
        local BM_DESTN_PATH=$5
    else
        local IP=$5
    fi
     
    local Retry=5
    while [ $Retry -ne 0 ]
    do
        if  ${SSH} "${BASH}" < "${SCRIPT}" "${CTRL_ARG}" "${ID}" "${BUID_MACHINE}" "${BUID_MACHINE_PASS}" "${BM_DESTN_PATH}" 2>/dev/null
        then 
            #TBD : What if Retries Has been Exhausted [Important]  --Code Done
            Retry=0
            break

        elif [ $Retry -eq 3 ]
        then
             ${KEYGEN} "${IP}" 2>/dev/null

        elif [ $Retry -eq 1 ]
        then
            return ${Retry_Exhausted}

        else  
            printf "\nHost is Busy...Retrying...Blitz\n"
            ((Retry--))
            sleep 2s
        fi
    done
   
} 

function COPY()
{
    SSH_CONNECT "${CTRL_ARG}" "${ID}" "${BUID_MACHINE}" "${BUID_MACHINE_PASS}" "${BM_DESTN_PATH}" 2>/dev/null
    RET_VAL=$?
    if [ $RET_VAL -ne 0 ]  
    then
        ERROR $RET_VAL
    fi
}

function REVERT()
{
    SSH_CONNECT "$CTRL_ARG"  2>/dev/null
    RET_VAL=$?
    if [ $RET_VAL -ne 0 ]  
    then 
        ERROR $RET_VAL
    fi
}

function TS()
{
    SSH_CONNECT  "$CTRL_ARG" "$ID" "$BUID_MACHINE" "$BUID_MACHINE_PASS" "$BM_DESTN_PATH" 2>/dev/null
    RET_VAL=$?
    if [ $RET_VAL -ne 0 ]  
    then
        ERROR $RET_VAL
    else
        ${CLEAR}
        printf "\n-----------------------------------------------------------------------------------------\n"
        printf "\n--> Successfully generated the TechSupport Bundle to Build Machine Path [ %s ] . \n" "$BM_DESTN_PATH"
    fi
}

function START()
{
    SSH_CONNECT "$CTRL_ARG" "$ID" "$BUID_MACHINE" "$BUID_MACHINE_PASS" "$IP"  2>/dev/null
    RET_VAL=$?
    if [ $RET_VAL -ne 0 ]  
    then
        ERROR $RET_VAL
    else
        #Note : If Logs.sh is already present , then directly go ahead the do the RPC Call
        sshpass -p $ADMINBACKUP_PASSWD ssh -t "$ADMINBACKUP"@"$IP" "cd /var/sysmgr/sam_logs; sudo /sbin/ip netns exec management bash /var/sysmgr/sam_logs/Logs.sh START $IP $CLI_AG_CHOICE" 2>/dev/null
    fi
}

function STOP()
{
    SSH_CONNECT "$CTRL_ARG"  "$ID" "$BUID_MACHINE"  "$BUID_MACHINE_PASS" "$BM_DESTN_PATH"  2>/dev/null
    RET_VAL=$?
    if [ $RET_VAL -ne 0 ] 
    then
        ERROR $RET_VAL
    fi
}

function STATUS()
{
    SSH_CONNECT "$CTRL_ARG" 2>/dev/null
    RET_VAL=$?
    if [ $RET_VAL -ne 0 ] 
    then 
        ERROR $RET_VAL
    fi
}

function CIMC()
{
    #Handle Challenge String Missing Case 
    C1=$1
    C2=$2
    /router/bin/ct_sign_client -C1 "${C1}" -C2 "${C2}" -cec;
}

case $CTRL_ARG in

    "COPY" | "copy" | "replace" | "REPLACE" )  
                    COPY 
                    ;;
    "REVERT" | "revert" | "rollback" | "ROLLBACK" ) 
                    REVERT 
                    ;;
    "TS" | "ts" | "techsupport" )  
                    TS 
                    ;;
   "START" | "start" | "tail" ) 
                    START 
                    ;;
    "STOP" | "stop" ) 
                    STOP 
                    ;;
    "STATUS" | "status" ) 
                    STATUS 
                    ;;
    "CIMC" | "cimc" ) 
                    CIMC "$C1" "$C2"
                    ;;
    "MAN" | "man" | "--help" | "-h" ) 
                    MAN 
                    ;;

     *) MAN 
        ;;
esac

#TBD
#What is There are Multiple So File's at at Time  --JUNKED
#What happens when you want to Roll back the New Binary --DONE
#Check all Process is Running Properly  --DONE