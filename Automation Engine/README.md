## UCSM Dev Tools
>A Versatile Automation Script that will help you in all the way it can...

## Pre-Requisite
In order to utilise the script seemlessly , Please do the following One_Time Operation 
<br>     
- Make sure to set the Passwordless SSH between Build Machine and Blitz Server.
- Export the Required Enviornment Variable's.

### **Passwordless-SSH**
        
         1.ssh-keygen -t rsa [Just Enter for All Propmt's ]
         2.ssh-copy-id <CEC ID>@savbu-blitz6.cisco.com

         Hurrah !! You're Done :)
### **Environment Variable's ( Optional )**
Setting the Following Environment varaible will prevent the Setup IP & CEC Password to be entered every time you invoke the script. <br>

Note : **'UCSIP'** Variable can be changed whenever it is required. 

        export UCSIP="Setup IP"
        export CEC="CEC Passwd"

## Usage :
### **TechSupport** :
#

    /nws/rameseka/scripts/Auto.sh [ techsupport | TS | ts ]

Create a Techsupport on a Support , once TechSupport Bundle is available will copy back and Extract the bundle to your current working directory.

### **Signing the Image** :
#

    /nws/rameseka/scripts/Auto.sh [ sign | SIGN ] [ UCSM Image Name ] [ Description about Image ](Optional)

Transfer the Image from Build Machine to Blitz to Sign the Image and Sends an Automated E-mail with Appropriate details all in a One Line command.

### **Library Replacement** :
#
To Replace the Library in a System

    /nws/rameseka/scripts/Auto.sh [ replace | COPY | copy ]
You'll be asked to enter the Absolute Path of the Generated Binary (.so) <br><br> From there , Existing Library File will be automatically backup up and New Library will be Replaced & eventually all the processes will be resumed automatically.
<br>

### **Reverting the Binary**
# 
    /nws/rameseka/scripts/Auto.sh [ revert | REVERT  ]

Note : You can always Revert to the previous shared Library (.So) binary, If you find something Fishy on a setup.

### **Tailing Live Logs**
#
Capture's the Live AG's Logs right there from a Build Machine .<br><br>Note : Logs will still be Captured Even If the File get to Rotate. <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Script works in a Interactive way as well If the AG is Not specified
<br>

     /nws/rameseka/scripts/Auto.sh [ tail | START | start ] [ AG Specific Name | all ] (Optional)

     i.e : 
     /nws/rameseka/scripts/Auto.sh tail -- Works in a Interactive way

     /nws/rameseka/scripts/Auto.sh tail dme -- Tail only DME Logs

     /nws/rameseka/scripts/Auto.sh tail all -- Tail All AG Logs

### **Moniter the Tailing Logs**
#
Moniter the Tailing Process to Ensure the Logs are being Captured

    /nws/rameseka/scripts/Auto.sh  [ status | STATUS ]
### **Stop the Tailing Logs**
#
Stop capturing the Tailing Logs and Zip the Files bring it back to the current directory of the Build Machine 

     /nws/rameseka/scripts/Auto.sh  [ stop | STOP ]

### **Generate CIMC Challenge String**
#
    /nws/rameseka/scripts/Auto.sh [ CIMC | cimc ] [C1 String] [ C2 String ]

## Features

- Generate & Export the TechSupport Bundle & Extract it right there from the Build Machine on a Single Command.
- Export the So File to the FI
- Revert to the Standard So File , If Something goes wrong
- Capture the respective LiveLogs for each and every process with Accurate Timestamp
- Export the Captured Logs to the Build Machine along with it's Start/End Timestamp metadata.
- Much more to Come.. :)
