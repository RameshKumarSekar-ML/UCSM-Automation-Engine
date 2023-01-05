#!/bin/bash

#This Script will Capture the Live Logs for All AG's or Specific AG's According to the User Choice
#Usage : To Start the Script Eg : [ Logs.sh START] 
#
#To Stop the Script Once You're Done Eg : [  Logs.sh STOP ]

#Debugging Functionality
# set -x
# if [ "$LOGS" == "DEBUG" ]
# then
#         set -x
# else
#         set +x
# fi
IP=$2
CLI_Choice=$3
IP="${@: -1}"

TIMESTAMP="Timestamp.log"
OPERATION="Tailed_Logs"

NOHUP="nohup tail -F"
DISOWN="disown -h"
CLEAR="clear 2> /dev/null"
TAR="tar -czvf"
SLEEP="sleep"

DME="svc_sam_dme.log"
DMEOP="Livedme.log"
BLADE="svc_sam_bladeAG.log"
BLADEOP="LiveBladeAg.log"
CONTROLLER="svc_sam_controller.log"
CONTROLLEROP="LivecontrollerLogs.log"
DCOS="svc_sam_dcosAG.log"
DCOSOP="LiveDcosAG.log"
NICAG="svc_sam_nicAG.log"
NICAGOP="LiveNicAG.log"
PORTAG="svc_sam_portAG.log"
PORTAGOP="LivePortAG.log"
HOSTAG="svc_sam_hostagentAG.log"
HOSTAGOP="LiveHostAG.log"
STATS="svc_sam_statsAG.log"
STATSAGOP="LiveStatAG.log"
RSD="svc_sam_rsdAG.log" 
RSDAGOP="LiveRsdAG.log"
LicenseAG="svc_sam_licenseAG.log"
LICENSEAGOP="LiveLicenseAG.log"

function MAN()
{
        printf "\n\t -------------------------------------------------------------------------\n"
        printf "Usage : \n\tStart a Script [ Logs.sh START ]\n"
        printf "\n\tStop the Script [ Logs.sh STOP ]\n"
        printf "\n\tCheck the Status of  Script [ Logs.sh STATUS ]\n"
        printf "\n\t -------------------------------------------------------------------------\n"
}

function USER_WARNING()
{
        #  $CLEAR
         printf "\n\t -------------------------------------------------------------------------\n"
         printf "\n\t SCRIPT IS RUNNING \n "
         printf "NOTE : \n\t User can Stop the Script by [ Logs.sh STOP ]\n"
         printf "\n\t User can Check the Status of the Script by [ Logs.sh STATUS ]\n"
         printf "\n\t -------------------------------------------------------------------------\n"
}

function isCLIBased()
{
    if [ -z "${CLI_Choice}" ]
    then
        return 0
    else
        return 1
    fi

}

isAlreadyRunning()
{
        :
}

function Logging()
        {
                function Validate()
                {
                        Ret=$1
                        if [ "$Ret" == "PASS" ]
                        then 
                                Debug_Level=$2
                                printf "\nLog Level Changed to %s\n" "$Debug_Level"
                        else
                                printf "\nERROR : Something Went Wrong While Changing the Debug Level."
                        fi
                }

                read -rep $'\nWould you Like to Change the Debug Level (Y/N) : ' LogOpt 

                function Show_Current_Debug_Level()
                {
                        sshpass -p "Nbv12345" ssh -t admin@"$IP" "scope monitoring;scope sysdebug;scope mgmt-logging;show;" 2>/dev/null
                        Logging
                        
                }
                function setDebugLevel()
                {
                        DebugLevel="$1"
                        if ! sshpass -p "Nbv12345" ssh -t admin@"$IP" "scope monitoring;scope sysdebug;scope mgmt-logging;set all $DebugLevel;save;" 2>/dev/null
                        then
                                Validate "FAIL"
                        else
                                Validate "PASS" "$DebugLevel" | tr a-z A-Z
                        fi
                }
                
                if [[ "$LogOpt" == "Y" || "$LogOpt" == "y" ]];then
                       
                        echo "0.Debug0"
                        echo "1.Debug1"
                        echo "2.Debug2"
                        echo "3.Debug3"
                        echo "4.Debug4"
                        echo "5.Show Current Debug Level"
                        
                        read -rep $'\nEnter your Choice Number : ' LogChoice
                                case $LogChoice in
                                0) setDebugLevel "debug0";;
                                1) setDebugLevel "debug1";;
                                2) setDebugLevel "debug2";;
                                3) setDebugLevel "debug3";;
                                4) setDebugLevel "debug4";;
                                5) Show_Current_Debug_Level;;

                                *) setDebugLevel "debug4" ;;
                        esac        
                else
                        return
                fi
        }

function START()
{
        
        printf "\nCurrent Directory : %s \n" "$(pwd)"
        DME()
        {
                printf "\nCapturing DME Logs"
                $NOHUP $DME >> $DMEOP 2> /dev/null &
                $DISOWN
        }
        BladeAG()
        {
                printf "\nCapturing BladeAG Logs"
                $NOHUP $BLADE >> $BLADEOP 2> /dev/null & 
                $DISOWN
        }

        ControllerLogs()
        {
                printf "\nCapturing Controller Logs"
                $NOHUP $CONTROLLER >> $CONTROLLEROP 2> /dev/null &
                $DISOWN
        }

        DcosAG()
        {
                printf "\nCapturing DcosAG Logs"
                $NOHUP $DCOS >> $DCOSOP 2> /dev/null &
                $DISOWN
        }

        NicAG()
        {
                printf "\nCapturing NicAG Logs"
                $NOHUP $NICAG >> $NICAGOP 2> /dev/null &
                $DISOWN
        }

        PortAG()
        {
                printf "\nCapturing PortAG Logs"
                $NOHUP  $PORTAG >> $PORTAGOP 2> /dev/null &
                $DISOWN
        }

        HostagentAG()
        {
                printf "\nCapturing HostAgentAG Logs"
                $NOHUP  $HOSTAG >>  $HOSTAGOP 2> /dev/null &
                $DISOWN
        }

        StatsAG()
        {
                printf "\nCapturing StatsAG Logs"
                $NOHUP  $STATS >>  $STATSAGOP 2> /dev/null &
                $DISOWN
        }

        RsdAG()
        {
                printf "\nCapturing RsdAG Logs"
                $NOHUP  $RSD >>  $RSDAGOP 2> /dev/null &
                $DISOWN
        }

        LicenseAG()
        {
                printf "\nCapturing LicenseAG Logs"
                $NOHUP  $LicenseAG >> $LICENSEAGOP 2> /dev/null &
                $DISOWN
        }

        All_AG()
        {
                printf "\nCapturing All Log's"
                DME &
                BladeAG &
                ControllerLogs &
                DcosAG &
                NicAG &
                PortAG & 
                HostagentAG &
                StatsAG &
                RsdAG &
                LicenseAG &
        }

        AG_Choice(){
                echo "0.All Logs"
                echo "1.DME"
                echo "2.BladeAG"
                echo "3.Controller Logs"
                echo "4.DcosAG"
                echo "5.NicAG"
                echo "6.PortAG"
                echo "7.HostagentAG"
                echo "8.StatsAG"
                echo "9.RsdAG"
                echo "10.LicenseAG"
        }

        isCLIBased
        Ret_Val=$?
        if [ "${Ret_Val}" -eq 0 ]
        then
                AG_Choice
                read -rep $'\nEnter your Choice Number : ' Choice
        else
                Choice="${CLI_Choice}"
        fi

        case $Choice in
                0 | "All" | "all" ) All_AG ;;
                1 | "dme" | "DME" ) DME & ;;
                2 | "bladeag" | "bladeAG" ) BladeAG & ;;
                3 | "controller" ) ControllerLogs & ;;
                4 | "dcosag" | "dcosAG" ) DcosAG & ;;
                5 | "nicag" | "nicAG" ) NicAG & ;;
                6 | "portag" | "portAG" ) PortAG & ;;
                7 | "hostag" | "hostAG" ) HostagentAG & ;;
                8 | "statsag" | "statsAG" ) StatsAG & ;;
                9 | "rsdag" | "rsdAG" ) RsdAG & ;;
                10| "licenseag" | "licenseAG" ) LicenseAG & ;;

                *)All_AG ;;

                esac

        if [[ $Choice -ne 0 ]] && [[ -z "${CLI_Choice}" ]]
        then
        read -rep $'\n\nDo you Want to Capture Any Other AG Logs ?(Y/N) ' Opt
        while [[ "$Opt" == "Y" ||  "$Opt" == "y" ]]
        do 
                START
        done 
                return
        fi
        
        ${SLEEP} 2s
}

function STOP()
{
        $CLEAR
        Validate()
        {
                Ret=$1
                if [ "$Ret" == "PASS" ]
                then 
                        LOG_DIR=$2
                        echo "Stopping Timestamp : $(date)" >> $TIMESTAMP 
                        printf "\n\nCaptured Directory : %s/%s  \n" "$PWD" "$LOG_DIR" >> $TIMESTAMP 

                        #Copying the Timestamp File Instead of Moving , To Grep the Stored the Directory in Driver Script
                        cp $TIMESTAMP "$LOG_DIR"
                        $TAR "$LOG_DIR".gz "$LOG_DIR" >& /dev/null

                        printf "\nPlease Find the Captured Logs and Timestamp Info in [ %s/%s.gz ] . \n" "$PWD" "$LOG_DIR"
                        printf "\n-----------------------------------------------------------------------------------------\n"
                else
                        printf "\nERROR : Something Went Wrong\n"
                        printf "\nWARNING : Seems Script isn't Started Yet. Please Checkout the MAN .\n"
                        MAN
                        exit 1
                fi

        }
            
        if pkill -9 -f tail
        then
                printf "\n-----------------------------------------------------------------------------------------\n"
                printf "\nSTOPPING THE PROCESS \n"  
                printf "\nSUCCESSFULLY STOPPED TAILING THE PROCESS \n"
        else
                Validate "FAIL"
        fi

        clean()
        {
                if [ -d "$OPERATION" ];then
                        printf "\nAlready Captured Log Directory Exists with a Same Name!!\n"

                        read -rep $'\nDo you want to Override it ? (Y/N) ?' Opt
                        if [[ "$Opt" == "y" ||  "$Opt" == "Y" ]];then
                                mv *Live* $OPERATION >& /dev/null 
                                if  [ $? -eq 0 ]
                                then
                                        Validate "PASS" "$OPERATION"
                                else
                                        Validate "FAIL"
                                fi
                        else
                            read -rep $'\nPlease Enter the Name of the Directory Where Logs Needs to be Stored  ' NEWDIR

                            mkdir -p "$NEWDIR"
                            mv *Live* "$NEWDIR" >& /dev/null
                            if  [ $? -eq 0 ]
                            then
                                Validate "PASS" "$NEWDIR"
                           else
                                rm -rf "$NEWDIR" >& /dev/null
                                Validate "FAIL"
                                
                           fi

                        fi
                else
                    mkdir $OPERATION
                    mv Live* $OPERATION 
                    if  [ $? -eq 0 ]
                    then
                                Validate "PASS" "$OPERATION"
                    else
                                rm -rf "$OPERATION" >& /dev/null
                                Validate "FAIL"
                                
                    fi
                fi
                        
        }

        #Moving the Captured Logs to the Specific Directory
        clean     
}

function STATUS()
{
        $CLEAR
        printf "\n\t\t\t LIVELOGS - SCRIPT STATUS \n "
        printf "\n\t -------------------------------------------------------------------------\n"
       
        ps -eaf | grep tail
        printf "\n\t -------------------------------------------------------------------------\n"
}

#Driver Code
if [ -z "$1" ]
then
    MAN
    exit 1
fi

case $1 in 

        "" )
           MAN
           ;;
        "START" | "start" | "TAIL" | "tail" )
                # $CLEAR
                printf "\n\t\t\tLive Logs Capture V1.0\n"
                printf "\nStarting Timestamp : %s\n\n" "$(date)" >> $TIMESTAMP
                
                isCLIBased
                Ret_Val=$?
                if [ "${Ret_Val}" -eq 0 ]
                then
                     Logging
                fi
                
                START 
                # USER_WARNING
                ;;
        "STATUS" | "status" )
                $CLEAR
                STATUS
                ;;
        "STOP" | "stop" )
                $CLEAR
                STOP
                ;;
        "MAN" | "man" | "--help" | "-h" ) 
                MAN 
                ;;

        *) MAN 
                ;;
esac
# set +x