#!/bin/bash 

##################################################################################################
#      Auto.sh  : Script to Manage Entire Development Automation Task's                           #
#                 This script has a couple of Dependencies relied upon some RPC Call's.            #
#                                                                                                 #
#           File : Auto.sh                                                                        #
#       Engineer : rameseka                                                                       #
#          Usage : /nws/rameseka/scripts/Auto.sh <Flags>                                          #
# Supported Flags:  [ techsupport | tail <AG Name>(Optional) | stop | replace | revert | cimc ]   #
#                                                                                                 #
###################################################################################################


ID="$USER"
BUILD_MACHINE_IP=$(hostname -i)
CURRENT_PATH=$(pwd)
CTRL_ARG="$1"
BLITZ6="savbu-blitz6.cisco.com"
UNTAR="tar -xzvf"
CLEAR="clear 2> /dev/null"

KEYGEN="ssh-keygen -R"
Retry_Exhausted=2

function Welcome()
{
    ${CLEAR}
    printf "\n-----------------------------------------------------------------------------------------\n"
    printf "\n\t\t\t\tUCSM Automation Engine V1.0\n"
    printf "\n-----------------------------------------------------------------------------------------\n"
}

function MAN(){
    :
}

function ERROR(){
    #TBD : Print Error Message Based on Error Code  --Code in Progress
    local Ret_Value=$1
    if [ "${Ret_Value}" -eq ${Retry_Exhausted} ]
    then
        printf "\nERROR : Connection Retries to Blitz Exhausted.\n"
        exit 1
    else
        printf "\nSomething went Wrong."
        printf "\nPlease Check your Setup IP/CEC Password & Try Again.\n\n"     #TBD : Give an Retry Option  --DONE
        exit 1
    fi
}

function PROCESSING()
{
     printf "\n\nHang on...Processing....\n" &
}

#TBD : If No Arguments Provided , Drive the script on Intercative Based
if [ -z "$CTRL_ARG" ]
then
    printf "\nInvalid Argument's.\n"
    printf "\nPlease Provide the Proper Argument's.\n\n"
    MAN
    exit 1
else
    Welcome
fi

#TBD : Get the Pass from Either CLI or Env Variable 
if [ -z "${CEC}" ] && [ -z "${UCSIP}" ]
then
    if [[ $CTRL_ARG != "MAN" && $CTRL_ARG != "man" ]] && [[ $CTRL_ARG != "--help" && $CTRL_ARG != "--h" ]] && [[ $CTRL_ARG != "CIMC" && $CTRL_ARG != "cimc" ]] 
    then 
        read -rep $'\n\nPlease Enter the Setup IP : ' IP
        read -serp $'\nPlease Enter the CEC Password : ' PASS
    fi
else
    IP=$UCSIP
    PASS=$CEC
fi

SSH="sshpass -p $PASS ssh -t $ID@$BLITZ6"
SCRIPT="bash /users/rameseka/RPC_Scripts/BM_RPC.sh"

###########################################################################
# Establish a SSH Connection Make an BM RPC Call.                      #
#                                                                         #
# Arguments:                                                              #
#   CTRL_ARG  ,BUILD_MACHINE_IP ,BUILD_MACHINE_PASS , BM_DESTN_PATH, IP   #
#                                                                         #
#Returns:                                                                 #
#       Success / Failure Return Value                                    #
###########################################################################

function SSH_CONNECT()
{
    local Retry=5

    local CTRL_ARG=$1
    local BUID_MACHINE=$2
    local BUID_MACHINE_PASS=$3
    local BM_DESTN_PATH=$4
    local IP=$5

    while [ $Retry -ne 0 ]
    do

        if [[ $CTRL_ARG == "START" || $CTRL_ARG == "start" || $CTRL_ARG == "tail" ]]
        then
            local CLI_AG_CHOICE=$6
            ${SSH} "${SCRIPT}" "${CTRL_ARG}" "${BUID_MACHINE}" "${BUID_MACHINE_PASS}" "${BM_DESTN_PATH}" "${IP}" "${CLI_AG_CHOICE}" 2>/dev/null
        else
            ${SSH} "${SCRIPT}" "${CTRL_ARG}" "${BUID_MACHINE}" "${BUID_MACHINE_PASS}" "${BM_DESTN_PATH}" "${IP}" 2>/dev/null
        fi

            Ret_Value=$?
            if  [ $Ret_Value -eq 0 ]
            then 
                Retry=0
                break

            elif [ $Retry -eq 3 ]
            then
                ${KEYGEN} "${IP}" 2>/dev/null

            elif [ $Retry -eq 1 ]
            then
            return ${Retry_Exhausted}

            elif [ ${Ret_Value} -eq ${Retry_Exhausted} ]  #Why do we need to Loop it again If already Retries Exhaustd in Blitz Call,So Exit
            then
                return ${Retry_Exhausted}
            else  
                printf "\nHost is Busy...Retrying...Build\n"
                ((Retry--))
                sleep 2s
            fi
    done
}

#############################################################################
#      Copy and Replace the  Appropriate Binary File to the specified Setup #
#############################################################################
function COPY()
{
    read -rep $'\n\nPlease Enter the Complte Bin File Path : ' BIN_PATH
    PROCESSING
    SSH_CONNECT "${CTRL_ARG}" "${BUILD_MACHINE_IP}" "${PASS}" "${BIN_PATH}" "${IP}";
    RET_VAL=$?
    if [ $RET_VAL -ne 0 ]
    then 
       ERROR $RET_VAL
    else
        #TBD : Suggest a user on How to Revert the So 
        printf "\nNOTE : \n\tYou can Always Revert back to Backed up So File ,If you find something Fishy in a Setup.\n\n"
    fi
}

#############################################################################
#      Revert the appropriate Binary File to the standard Binary            #
#############################################################################
function REVERT()
{
    PROCESSING
    SSH_CONNECT  "${CTRL_ARG}" "${BUILD_MACHINE_IP}" "${PASS}" "${CURRENT_PATH}" "${IP}"
    RET_VAL=$?
    if [ $RET_VAL -ne 0 ]
    then
       ERROR $RET_VAL
    fi
}

################################################################################################
#    Fetch the Techsupport directly from the setup & Extract to the current working Directory  # 
################################################################################################
function TS()
{
    PROCESSING
    SSH_CONNECT "${CTRL_ARG}" "${BUILD_MACHINE_IP}" "${PASS}" "${CURRENT_PATH}" "${IP}"
    RET_VAL=$?
    if [ $RET_VAL -ne 0 ]
    then
        ERROR $RET_VAL
    else
        printf "\nExtracting the TechSupport.... Please wait...\n"
        TechSupport=$( ls -Art | tail -n 1 )
        /nws/vivavila/ShellScripts/Extracttarfile.sh "${TechSupport}" > /dev/null 2>&1

        #TBD : Print only based on Success Case , Check if Techsupport Argument is passed or Not , 
        printf "\n--> TechSupport Collected and Extracted Successfully\n"
        printf "\n-----------------------------------------------------------------------------------------\n"
    fi
}

########################################################################################
#   START  :  Start Tailing the Live AG Logs on a Setup                                #
#                                                                                      #
#   STATUS  : Fetch the progress of the Current Tailing Logs                           #
#                                                                                      #
#   STOP  : Stop the Tailing the process and Zip it and Bring it  back to the CWD      # 
########################################################################################

function START()
{
    local CLI_AG_CHOICE=$1
    PROCESSING
    SSH_CONNECT "${CTRL_ARG}" "${BUILD_MACHINE_IP}" "${PASS}" "${CURRENT_PATH}" "${IP}" "${CLI_AG_CHOICE}"
    RET_VAL=$?
    if [ $RET_VAL -ne 0 ]
    then
        ERROR $RET_VAL
    fi
}

function STATUS()
{
    PROCESSING
    SSH_CONNECT "${CTRL_ARG}" "${BUILD_MACHINE_IP}" "${PASS}" "${CURRENT_PATH}" "${IP}"
    RET_VAL=$?
    if [ $RET_VAL -ne 0 ]
    then
        ERROR $RET_VAL
    fi
}

function STOP()
{
    PROCESSING
    SSH_CONNECT "${CTRL_ARG}" "${BUILD_MACHINE_IP}" "${PASS}" "${CURRENT_PATH}" "${IP}"
    RET_VAL=$?
    if [ $RET_VAL -ne 0 ]
    then
        ERROR $RET_VAL
    else
        $UNTAR Tailed_Logs.gz >& /dev/null
    fi

}

####################################################
#      Generate the CIMC Challenge String          #
####################################################
function CIMC()
{
    PROCESSING
    C1=$1
    C2=$2
    ID=""
    PASS=''
    if ! sshpass -p "${PASS}" ssh -t "${ID}"@${BLITZ6} "bash /users/rameseka/RPC_Scripts/BM_RPC.sh ${CTRL_ARG} ${C1} ${C2}" 2>/dev/null
    then
        ERROR
    fi
}

function MAN_()
{
    MAN
}

#Main Driver Code

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
                    START "$2"
                    ;;
    "STOP" | "stop" ) 
                    STOP 
                    ;;
    "STATUS" | "status" ) 
                    STATUS 
                    ;;
    "CIMC" | "cimc" ) 
                    CIMC "$2" "$3"
                    ;;
    "MAN" | "man" | "--help" | "-h" ) 
                    MAN           
                    ;;

     *) MAN_   #Remove _ Here paste the original Logic here 
        ;;
esac

#TBD
#Add a Detailed MAN Page , inlcluding passwordless SSH

#Debugging Functionality
# if [ "$LOGS" == "DEBUG" ]
# then
#         set -x
# else
#         set +x
# fi
