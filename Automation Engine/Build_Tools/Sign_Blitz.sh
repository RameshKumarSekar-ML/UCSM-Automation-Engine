#!/usr/bin/env bash
#-----------------------------------------------------------------------------------------
#Created by : rameseka , khallike 
#
#Descr : Wrapper Script for Sign.sh , Driver scriot needs to be invoked from Build Machine.
#
#Usage : bash /nws/rameseka/Sign.sh [IMAGE NAME] 
#------------------------------------------------------------------------------------------

ID="$USER"
HOST_IP=$( hostname -i)
SAVBU="savbu-blitz6.cisco.com"
PI_PATH="/auto/wssjc-nuo11/$ID/temp/sam/src/.debug/images/"
DESCR="$3"
EXIT="exit 1"

function sign()
    {
        printf  "\nCopying PI\n\n"

        if scp "$ID"@ucs-build03.cisco.com:"$1" /auto/wssjc-nuo11/"$ID"/temp/sam/src/.debug/images/ 
        then
            printf "\nCopied the PI\n"
        else
            printf "\nSomething went wrong while copying the PI\n\n"
            printf  "\n Hi %s , \n\n Something went wrong while copying the PI from Build Machine to Blitz Server. \n Kindly Please Check and Re-Trigger the Sign . \n\n Thanks " "$ID"  | mailx -s "RE: Failed to Sign the Image" "$ID"@cisco.com
            ${EXIT}
        fi

        printf "\nSigning the Image ....Please Wait\n\n"

        if /auto/wssjc-nuo11/"$ID"/temp/sign4gfiimage.sh -image_file /auto/wssjc-nuo11/"$ID"/temp/sam/src/.debug/images/"$2"
        then
            printf "\nSIGNED THE IMAGE SUCCESSFULLY\n\n"
            printf  "\n Hi %s , \n\nSigned the Image [ %s ] Successfully. \n\nPlease Find the Required Details Below \n\n IP : %s , \n\n IMAGE NAME : %s, \n\n PATH : %s ,\n\n Description : %s , \n\nThank You \nHappy Signing:) \n  " "$ID" "$2" "$HOST_IP" "$2" "$PI_PATH" "$DESCR"  | mailx -s "RE: Image Signing Succeeded :) " "$ID"@cisco.com
        else
            printf "\nSomething Went Wrong While Signing the PI\n\n"
            printf  "\n Hi %s , \n\n Something Went Wrong While Signing the PI [ %s ] in Blitz Server [ %s ] . \n Kindly Please have a Look. \n\n Thanks " "$ID" "$2" "$SAVBU" | mailx -s "RE: Failed to Sign the Image" "$ID"@cisco.com
            ${EXIT}
        fi
    }

#Driver Code
sign "$1" "$2" "$DESCR"

