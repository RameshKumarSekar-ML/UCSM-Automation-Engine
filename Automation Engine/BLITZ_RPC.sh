#!/bin/bash

CTRL_ARG=$1
USER_DIR="New_Bins"
BACKP_DIR="Backp_Bins"
SAM_LOGS="cd /var/sysmgr/sam_logs || exit"
SAM_LOGS_DIR="/var/sysmgr/sam_logs/"
SOCKETS_REFRESH="mkdir -p /root/.ssh/sockets"
LOGS_SRC="/nws/rameseka/scripts/Log_Tools/Logs.sh"
SAM_COPY="bash /isan/bin/sam-copy-v2-wrap.sh"
CLEAR="clear 2>/dev/null"

function PMON()
{
    if [ "$1" == "START" ];then
        sleep 0.5s
        pkill -USR2 pmon
        sleep 3s
        printf "\n\n============================ PROCESS RESTARTED ============================================\n"
        bash /isan/bin/sam_process_state.sh
        printf "\n============================ PROCESS RESTARTED ==============================================\n"
    elif [ "$1" == "STOP" ];then
        sleep 0.5s
        pkill -USR1 pmon
        sleep 3s  
        printf "\n\n============================ PROCESS TERMINATED ============================================\n"
        bash /isan/bin/sam_process_state.sh
        printf "\n============================ PROCESS TERMINATED ==============================================\n"
    fi
}

###########################################################################
# Transfer File from/to the Build Machine based on Retry Mechanism        #                                                                   #                                                              #
###########################################################################
function SCP()
{
    DIRECTION="$1"
    SERVER_DESTN="$2"
    SRC_FILE="$3"
    REMOTE_DESTN="$4"
    ID="$5"
    BUID_MACHINE_PASS="$6"
   
    $SOCKETS_REFRESH
    local RETRY=3
    while [ $RETRY -ne 0 ]
    do
        if  $SAM_COPY "scp" "$DIRECTION" "$SERVER_DESTN" "$SRC_FILE" "$REMOTE_DESTN" "$ID" "$BUID_MACHINE_PASS"  >& /dev/null ;
        then 
                RETRY=0
                break
        elif ! $SAM_COPY "scp" "$DIRECTION" "$SERVER_DESTN" "$SRC_FILE" "$REMOTE_DESTN" "$ID" "$BUID_MACHINE_PASS"  >& /dev/null  && [ $RETRY -eq 1 ]
        then
                printf "\n ERROR : Something went wrong while transferring the File between Setup & Build Machine.\n"
                printf "\nPlease try again & Make sure you Enter the Right CEC Password"
                return 1
        elif ! $SAM_COPY "scp" "$DIRECTION" "$SERVER_DESTN" "$SRC_FILE" "$REMOTE_DESTN" "$ID" "$BUID_MACHINE_PASS"  >& /dev/null ; 
        then 
                printf "\nHost is Busy...Retrying...\n"
                ((RETRY--))
                sleep 2s
        fi
    done
}

function COPY()
{
    BIN_PATH=$1
    BIN_File=$(basename "$BIN_PATH")
    ID=$2
    BUID_MACHINE=$3
    BUID_MACHINE_PASS=$4

    $SAM_LOGS

    mkdir -p $USER_DIR $BACKP_DIR
    sleep 0.5s

    #TBD :  If Can't Backup the Existing So , Exit from Script
    if cp /isan/sam/lib/"$BIN_File" $BACKP_DIR ;then
        printf "\nBackuped the Existing So File !! "
    else
        printf "\n ERROR : Failed to Backup the Existing So File . Something Went Wrong."
        exit 0
    fi

    PMON "STOP"

    printf "\nCopying the SO File from Build Server... Please Wait !! \n"  &
    if SCP "copyin" "${BUID_MACHINE}" "${SAM_LOGS_DIR}${USER_DIR}" "${BIN_PATH}" "${ID}" "${BUID_MACHINE_PASS}"; 
    then
        printf "\nTransferred the So File to FI.\n"
    else
        printf "\n ERROR : Failed to Transfer the so File to FI.\n"
    fi
    
    if  cp ${SAM_LOGS_DIR}New_Bins/"$BIN_File" /isan/sam/lib/"$BIN_File" ;then
        printf "\n--> Successfully Replaced the So File."
    else
        printf "\n ERROR : Failed to Replace the Copied So File. "
    fi

    PMON "START"

}

###########################################################################
# Revert to the Previoius Binary If It's Found in Backup_Bin Directory    #                                                                   #                                                              #
###########################################################################
function REVERT(){
    #Check if Backup_Bin Exists
    if [ -d "/var/sysmgr/sam_logs/Backp_Bins/" ];then
        $SAM_LOGS
        PMON "STOP"
        BIN_File=$(basename $BACKP_DIR/*)  #To Identify the Destn So File Name (Eg: libmodel.so,lib_svc_dme.so )
        if cp $BACKP_DIR/* /isan/sam/lib/"$BIN_File";then
            printf "\n Roll Backed to the Standard Binary (So) File !! "
            PMON "START"
        else
            printf "\n ERROR : Failed to Roll Back to the Standard Bindary (So ) File . Something Went Wrong. "
            PMON "START"
        fi
    else
        printf "\n WARNING :No Backup So File Exist's."
        printf "\n WARNING : Seems So File Haven't even replaced. Please start the Script.\n\n"
    fi
}

#Clean If the Data Already Exists / Whenever the Script Start's
function CLEAN()
{
    if rm -r ${SAM_LOGS_DIR}*Bins* 2>/dev/null ;then
        printf "\nOld Backup Data Found - Purging it..\n"
    fi
}

###########################################################################
# Collect the Techsupport Directly from Setup & Copy back to Build Machine# 
###########################################################################
function TS(){
    #Purging the Techsupport Bundle and it's ts Log File
    CLEAN_TS()
    {
        if rm -r /workspace/techsupport/"$TS_File"
        then 
            printf "\nCleaning up the TechSupport from FI.\n"
            rm ts    
        fi
    }

    ID=$1
    BUID_MACHINE=$2
    BUID_MACHINE_PASS=$3
    BM_DESTN_PATH=$4

    $SAM_LOGS

    stty /isan/bin/showtechsupport 2>/dev/null ;

    printf "\nGenerating TechSupport Bundle... Please wait...\n\n" &
    # bash /isan/bin/showtechsupport  --detail --sam 2>&1 | tee ts  2>/dev/null;
    bash /isan/bin/showtechsupport  --detail --sam 2>/dev/null | tee ts ;

    sleep 1s

    TS_File=$(grep -ir "detailed" ts | cut -c78-)
    TechSupport_Path="/workspace/techsupport/${TS_File}"

    sleep 0.5s

    if SCP "copyout" "${BUID_MACHINE}" "${TechSupport_Path}" "${BM_DESTN_PATH}" "${ID}" "${BUID_MACHINE_PASS}";
    then
        CLEAN_TS
    else
        ${CLEAR}
        printf "\nERROR : Something Went wrong while Copying Back the TechSupport Bundle to Build Server . Please Try again !! "
        CLEAN_TS
        exit 1
    fi 
}

function START()
{
    ID=$1
    BUID_MACHINE=$2
    BUID_MACHINE_PASS=$3
    IP=$4

    $SAM_LOGS

    if ! SCP "copyin" "${BUID_MACHINE}" ${SAM_LOGS_DIR} "${LOGS_SRC}" "${ID}" "${BUID_MACHINE_PASS}"; 
    then 
        exit 1
    fi
}

function STATUS()
{
    ${CLEAR}

    #Check if a Timestamp File/Logs File Exists or Not , WSo We'll Terminate the Script If a User Tries to STOP a Script Which is not even Started
    if [[ ! -f ${SAM_LOGS_DIR}Timestamp.log || ! -f ${SAM_LOGS_DIR}Logs.sh ]]
    then
        printf "\n\n[ WARNING : Script isn't Started Yet. Please Start the Script and Checkout the MAN Page for Instructions.]\n\n"
        exit 0
    fi

    bash ${SAM_LOGS_DIR}Logs.sh STATUS
}

function STOP()
{
    ID=$1
    BUID_MACHINE=$2
    BUID_MACHINE_PASS=$3
    BM_DESTN_PATH=$4

    $SAM_LOGS

    #Check if a Timestamp File/Logs File Exists or Not , If so We'll Terminate the Script If a User Tries to STOP a Script Which is not even Started
    if [[ ! -f ${SAM_LOGS_DIR}Timestamp.log || ! -f ${SAM_LOGS_DIR}Logs.sh ]]
    then
        printf "\n\n[ WARNING : Script isn't Started Yet. Please Start the Script and Checkout the MAN Page for Instructions.]\n\n"
        exit 0
    fi

    bash ${SAM_LOGS_DIR}Logs.sh STOP
    sleep 2s

    SRC=$(grep -s "sam_logs" Timestamp.log  | cut -b 22-)
    SRC_RETVAL=$?
    if [ $SRC_RETVAL -eq 0 ]
    then
        rm -f ${SAM_LOGS_DIR}Timestamp.log
    fi

    if SCP "copyout" "$BUID_MACHINE" "${SAM_LOGS_DIR}Tailed_Logs.gz" "${BM_DESTN_PATH}" "${ID}" "${BUID_MACHINE_PASS}";
    then
        ${CLEAR}
        printf "\nSuccessfully Copied the Tailed Logs to the [ %s/Tailed_Logs ] \n\n" "${BM_DESTN_PATH}"
        if [ $SRC_RETVAL -eq 0 ]
        then
            rm -rf ${SAM_LOGS_DIR}Tailed_Logs* 2>/dev/null
        else
            printf "\nERROR : !!! Something Went Wrong , Seems %s Doesn't Exist.\n\n" "$SRC"
        fi
    else
        printf "\nERROR : !!! Something Went Wrong while Copying Back the Logs from Setup to Build Machine !!\n\n" 
    fi
}

#Main Driver Code 
if [[ "$CTRL_ARG" == "COPY" ||  $CTRL_ARG == "copy"  ||  $CTRL_ARG == "REPLACE" ||  $CTRL_ARG == "replace" ]]
then
    ID=$2
    BUID_MACHINE=$3
    BUID_MACHINE_PASS=$4
    BIN_PATH=$5
    BIN_File=$(basename "$BIN_PATH")

    CLEAN
    COPY "$BIN_PATH" "$ID" "$BUID_MACHINE" "$BUID_MACHINE_PASS"

elif [[ "$CTRL_ARG" == "REVERT" || "$CTRL_ARG" == "revert" || "$CTRL_ARG" == "ROLLBACK" || "$CTRL_ARG" == "rollback" ]]
then
    REVERT 

elif [[ "$CTRL_ARG" == "TS" || "$CTRL_ARG" == "ts" || "$CTRL_ARG" == "techsupport" || "$CTRL_ARG" == "Techsupport" ]]
then
    ID=$2
    BUID_MACHINE=$3
    BUID_MACHINE_PASS=$4
    BM_DESTN_PATH=$5

    TS "$ID" "$BUID_MACHINE" "$BUID_MACHINE_PASS" "$BM_DESTN_PATH"

elif [[ "$CTRL_ARG" == "START" || "$CTRL_ARG" == "start" || "$CTRL_ARG" == "tail" ]]
then
    ID=$2
    BUID_MACHINE=$3
    BUID_MACHINE_PASS=$4
    IP=$5

    START "$ID" "$BUID_MACHINE" "$BUID_MACHINE_PASS" "$IP"

elif [[ "$CTRL_ARG" == "STATUS" || "$CTRL_ARG" == "status" ]]
then
    STATUS

elif [[ "$CTRL_ARG" == "STOP" || "$CTRL_ARG" == "stop" ]]
then

    ID=$2
    BUID_MACHINE=$3
    BUID_MACHINE_PASS=$4
    BM_DESTN_PATH=$5

    STOP "$ID" "$BUID_MACHINE" "$BUID_MACHINE_PASS" "$BM_DESTN_PATH"

else 
    #Check when It will be invoked
    CLEAN
fi

#TBD
#Based on Command Success , Print Message  --DONE
#Copy the So File From Build Machine --DONE
#Clean the Directory At the End and Starting of the Script --DONE 