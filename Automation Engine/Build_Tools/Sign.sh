#!/usr/bin/env bash
#-------------------------------------------------------------------------------
#Created by : rameseka , khallike
#
#Usage : /nws/rameseka/scripts/Build_Tools/Sign.sh [IMAGE NAME] [ Any Description (Optional) ]
#
#--------------------------------------------------------------------------------

export PATH=$PATH:/nws/rameseka/
ID="$USER"
CURRENT_PATH=$PWD
CURRENT_PATH+='/'$1
DESCR="$2"
EXIT="exit 1"

function MAN()
{
        printf "\n\t -------------------------------------------------------------------------\n"
        printf "[ Instruction's] : \n\n\tPlease Get in to sam/src/.debug/images/ Directory and Execute the Script.]\n"
        printf "\n[ PASSWORDLESS SSH ] : \n\n\t 1.ssh-keygen -t rsa [Just Enter for All Propmt's ]  \n\t 2.ssh-copy-id %s@savbu-blitz6.cisco.com \n\n\t Hurrah !! You're Done :) \n" "$ID"
        printf "\n[ Usage ] : \n\n\tSign the Image [ bash /nws/rameseka/Sign.sh [IMAGE NAME] ]\n"
        printf "\n\t -------------------------------------------------------------------------\n"
        ${EXIT}
}

if [ $# -eq 0 ]
  then
    clear 2> /dev/null
    printf "\n\t\tPlease Provide the Name of the UCSM IMAGE to be Signed!!\n"
    MAN

elif [ "$1" == "MAN" ] || [ "$1" == "man" ]  || [ "$1" == "--help" ] ||  [ "$1" == "--h" ]
  then
    clear 2> /dev/null
    MAN

else
    PI=$(python /nws/rameseka/scripts/Build_Tools/Parser.py UCSM_PI "$CURRENT_PATH")
    printf "\nUCSM IMAGE : %s \n" "$PI"

    if ! ssh -t "$ID"@savbu-blitz6.cisco.com "cd /auto/wssjc-nuo11/$ID/temp/;bash /auto/wssjc-nuo11/rameseka/temp/Sign_Blitz.sh $CURRENT_PATH $PI '$DESCR';"  2>/dev/null
    then
        printf "\nSorry...Something went wrong Either while connecting to Blitz Server / Signing might have Failed.\n\n"
        ${EXIT}
    fi
fi
