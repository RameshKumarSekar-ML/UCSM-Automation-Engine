#!/bin/bash
MAX=4

echo  "Starting the Log's Merger"

mkdir MergedLogsGEN
Parser()
{
        echo "Parsing $1 Logs"
        LOG="svc_sam_$1.log"
        OPLOG="$1.log"
                cat $LOG >> $OPLOG
        for i in `seq 1 $MAX`
                do
                  echo $LOG"."$i
                  FILE=$LOG"."$i
                  if [ -f "$FILE" ]; then
                          echo "$FILE exists"
                          cat $FILE >> $OPLOG
                  fi
                done
       #Organizing the Log's
       mv $OPLOG MergedLogsGEN
}


#Invoking the Function
Parser dme
Parser bladeAG
Parser controller
Parser dcosAG
Parser nicAG
Parser portAG
Parser hostagentAG
Parser statsAG
Parser rsdAG
Parser licenseAG