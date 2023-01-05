#!/bin/bash 
# set -x
CURRENT_PATH=$(pwd)
VERSION=$(python /nws/rameseka/scripts/Build_Tools/Parser.py DATE)
# ID="$USER"
DISOWN="disown -h"
NOHUP_MAKE="nohup make"
NOHUP_MAKE_SAM="nohup make sam"
CLEAR="clear 2> /dev/null"
TAIL="tail -f logfile"
BUILD_TYPE=$1
SIGN_CLI_OPT=$2

function Success_Check(){
    #Adding Sleep to Create a Log File on First Execution / Try Removing Old LogFile If Possible
    # sleep 2m
    i=1
    while [ $i -ne 0 ];do
        grep "dcc-img-diff.py" logfile
        i=$?
        if [[ $i == 0 ]];then
            printf "\nBuild Completed !!\n"
            #To Parse the Image Complete UCSM PI Path from Log File "For Eg : /nws/rameseka/bugs/L-KBMR1/ucsm/perfocarta/sam/src/.debug/images/ucs-manager-k9.4.2.0.3005A.gbin"
            Image_Path=$(grep "VERIFYING Md5 checksum for" logfile | grep "ucs-mana*")
            UCSM_PATH=$(python /nws/rameseka/scripts/Build_Tools/Parser.py UCSM_PATH "$Image_Path")
            
            # printf "\n Hi %s , \n\n This is to Notify that UCSM Build is Completed !!\n" "$ID" | mail -s "UCSM BUILD SUCCESSFULL" "$ID"@cisco.com 

            #TBD : Get the Parameter from CLI and Sign it Forcefully
            read -rp "Do you Wanna Sign the Image ?(Y/N) " SignOpt
            if [[ $SignOpt == "y" || $SIGN_CLI_OPT == "sign" ]];then
                ${CLEAR}
                printf "\nProceeding to SIGN the Image\n"
                #Parse Only the PI Name from Complete UCSM PATH to the Image and Passing Both the Path and PI name to the Remote Server Script.
                PI=$(python /nws/rameseka/scripts/Build_Tools/Parser.py UCSM_PI "$UCSM_PATH")
                bash /nws/rameseka/scripts/Auto.sh sign "${UCSM_PATH}" "${PI}"
            fi
            break
            return 0
        fi
    done
}

#Function Which Trigger's UCSM Build
function Build()
{
    export PYTHONHTTPSVERIFY=0;
    export BUILD_VERSION="4.2(3.$1a)";
    rm sam/src/.debug/install-ucsm/isan/lib/libxml2* 2> /dev/null;
  
    #Check if it's an Already Build Repo / Fresh Repo
    if [ -d "sam/src/.debug/images/" ]
    then
        if [[ $BUILD_TYPE == "sam" || $BUILD_TYPE == "SAM" || $BUILD_TYPE == "sambuild" || $BUILD_TYPE == "make-sam" ]]
        then
            printf "\n\nAlready Built Repo.\n"
            ${CLEAR}
            ${NOHUP_MAKE_SAM} >& logfile &
            ${DISOWN}
            # Success_Check &
            ${TAIL}
            printf "\nUCSM SAM Build Triggered\n"
        else
            printf "\n\nSeems Already Built Repo ... Cool ;)\n"
            ${CLEAR}
            ${NOHUP_MAKE} >& logfile & 
            ${DISOWN}
            # Success_Check
            ${TAIL}
            printf "\nUCSM FULL Build Triggered\n"
        fi
        # sleep 5m  #Wondering Why Sleep is Required ??
    else
        printf "\n\nFresh Repo .... Sit Back and Switch to Some Work for a While :(\n"
        ${CLEAR}
        ${NOHUP_MAKE}
        ${DISOWN}
        ${TAIL}
        printf "\nUCSM Build Triggered\n"
        # sleep 2h 15m
    fi

}


#Either user Can Pass their Own Build Version [ Build.sh "2706" ] 
if [ -z "${1}"  ]
then
    VERSION=$(python /nws/rameseka/scripts/Build_Tools/Parser.py DATE)
# else
#     VERSION=$1
fi

if [[ $CURRENT_PATH == *"perfocarta"* ]]
then 
    Build "$VERSION" &
    BUILD_STATUS=$!
    ${CLEAR}
    echo ${BUILD_STATUS}
    if ${BUILD_STATUS}
    then
        Success_Check    #Invoking Success Check since sometime's Build may fail at Anytime after trigger
    fi
else
    printf "\nWARNING : Please Trigger Build Inside the Perfocarta Directory !!\n\n"
fi
