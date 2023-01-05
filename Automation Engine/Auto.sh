#!/bin/bash 

#########################################################################################################
#      Auto.sh  : Script to Manage Entire Development Automation Task's                                  #
#                 This script has a couple of Dependencies relied upon some RPC Call's.                  #
#                                                                                                        #
#           File : Auto.sh                                                                               #
#       Engineer : rameseka                                                                              #
#          Usage : /nws/rameseka/scripts/Auto.sh <Flags>                                                 #
# Supported Flags:  [ techsupport | sign | tail <AG Name>(Optional) | stop | replace | revert | cimc ]   #
#                                                                                                        #
##########################################################################################################


ID="$USER"
BUILD_MACHINE_IP=$(hostname -i)
CURRENT_PATH=$(pwd)
CTRL_ARG="$1"
BLITZ6="savbu-blitz6.cisco.com"
UNTAR="tar -xzvf"
CLEAR="clear 2> /dev/null"

KEYGEN="ssh-keygen -R"
Retry_Exhausted=2
EXIT_FAIL="exit 1"

function Welcome()
{
    ${CLEAR}
    printf "\n---------------------------------------------------------------------------------------------------------------------------------------------\n"
    printf "\n\t\t\t\tUCSM Automation Engine V1.0\n"
    printf "\n---------------------------------------------------------------------------------------------------------------------------------------------\n"
}

function MAN(){
    ${CLEAR}
    printf  "\n************************************* USAGE ***************************************************************\n"
    printf  "\nDownload & Extract a TechSupport ---- [ techsupport | TS | ts ]"
    printf  "\n\nSigning the Image -- [ sign | SIGN ] [ UCSM Image Name ] [ Description about Image ](Optional)"
    printf  "\n\nReplace the Library So File -- [ replace | COPY | copy ]"
    printf  "\n\nReverting the Library So File -- [ revert | REVERT  ]"
    printf  "\n\nTail the AG Logs -- [ tail | START | start ] [ AG Specific Name | all ] (Optional)"
    printf  "\n\nStatus of the Tailing Logs -- [ status | STATUS ]"
    printf  "\n\nStop Tailing the Log -- [ stop | STOP ]"
    printf  "\n\nGenerate challenge String -- [ CIMC | cimc ] [C1 String] [ C2 String ]"
    printf  "\n\n*********************************** USAGE *****************************************************************\n"
}

function ERROR(){
    #TBD : Print Error Message Based on Error Code  --Code in Progress
    local Ret_Value=$1
    if [ "${Ret_Value}" -eq ${Retry_Exhausted} ]
    then
        printf "\nERROR : Connection Retries to Blitz Exhausted.\n"
        ${EXIT_FAIL}
    else
        printf "\nSomething went Wrong."
        printf "\nPlease Check your Setup IP/CEC Password & Try Again.\n\n"     #TBD : Give an Retry Option  --DONE
        ${EXIT_FAIL}
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
    ${EXIT_FAIL}
else
    Welcome
fi

#TBD : Get the Pass from Either CLI or Env Variable 
if [ -z "${CEC}" ] && [ -z "${UCSIP}" ]
then
    if [[ $CTRL_ARG != "MAN" && $CTRL_ARG != "man" ]] && [[ $CTRL_ARG != "--help" && $CTRL_ARG != "--h" ]] && [[ $CTRL_ARG != "SIGN" && $CTRL_ARG != "sign" ]]
    then 
        if [[ $CTRL_ARG != "CIMC" && $CTRL_ARG != "cimc" ]] 
        then
            read -rep $'\n\nPlease Enter the Setup IP : ' IP
        fi
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

###############################################################################################
#                                                                                             #
# Created by : rameseka , khallike                                                            #
#                                                                                             #
# Descr : Wrapper Script for Signing the Private Image                                        #
#                                                                                             #
# Arguments:                                                                                  #
#   CTRL_ARG  ,PI Name ,PI Description(Optional)                                              #
#                                                                                             #
###############################################################################################

function SIGN()
{
    function SIGN_MAN()
    {
        printf "\n\t -------------------------------------------------------------------------\n"
        printf "[ Instruction's] : \n\n\tPlease Get in to sam/src/.debug/images/ Directory and Execute the Script.]\n"
        printf "\n[ PASSWORDLESS SSH ] : \n\n\t 1.ssh-keygen -t rsa [Just Enter for All Propmt's ]  \n\t 2.ssh-copy-id %s@savbu-blitz6.cisco.com \n\n\t Hurrah !! You're Done :) \n" "$ID"
        printf "\n[ Usage ] : \n\n\tSign the Image [ bash /nws/rameseka/Sign.sh [IMAGE NAME] ]\n"
        printf "\n\t -------------------------------------------------------------------------\n"
        ${EXIT_FAIL}
    }

    if [ $# -eq 1 ]
    then
        ${CLEAR}
        printf "\n\t\tPlease Provide the Name of the UCSM IMAGE to be Signed!!\n"
        SIGN_MAN
    fi

    local PI=$2
    CURRENT_PATH+='/'$2
    local DESCR="$3"
    # PI=$(python /nws/rameseka/scripts/Build_Tools/Parser.py UCSM_PI "$CURRENT_PATH")
    printf "\nUCSM IMAGE : %s \n" "$PI"

    if ! ssh -t "$ID"@$BLITZ6 "${SCRIPT}" "${CTRL_ARG}" "$CURRENT_PATH" "$PI" "${DESCR}" 2>/dev/null
    then
        printf "\nSorry...Something went wrong Either while connecting to Blitz Server / Signing might have Failed.\n\n"
        ${EXIT_FAIL}
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
    if ! SSH_CONNECT "${CTRL_ARG}" "${C1}" "${C2}" 2>/dev/null
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
    "SIGN" | "sign" )
                    SIGN "$@"
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
