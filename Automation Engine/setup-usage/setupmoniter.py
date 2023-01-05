import json
import sys
import argparse
import pandas as pd
from tabulate import tabulate
from datetime import date, datetime,timedelta
import getpass

parser = argparse.ArgumentParser()
parser.add_argument('--status',default="na" ,nargs='?',help="Status of the Setup")
parser.add_argument('--acquire',default="na",nargs='?', help="Acquire  the Setup for use!")
parser.add_argument('--release',default="na",nargs='?',help="Release the Setup after use!")
args = parser.parse_args()

def printer(data):
    df = pd.DataFrame.from_dict(data,orient='index')
    print(tabulate(df,tablefmt='fancy_grid'))

def status(setup="Nil"):
    if setup == "Nil":
        return None
    if setup!="Nil":
        with open("Setups.json","r") as f:
            data=json.load(f)
        found=False
        for i,j in data.items():
            if setup ==i:
                found=True
                printer(j)
        if found==False:
            print("\nInvalid Setup Number !..Please Enter Proper Setup Number!!\n")
            

def acquire(setup="Nil"):
    if setup=="Nil":
        return None
    if setup!="Nil":
        with open("Setups.json","r") as f:
            data=json.load(f)
            t=data
        for i,j in t.items():
            if setup ==i:
                j["Status"]="Acquired"
                j["Engineer"]=getpass.getuser()
                j["Note"]=input("\nSetup usage Purpose : ")
                j["Duration"]=input("\nDuration : ")
                j["Acquired Time"]=datetime.now().strftime('%H:%M:%S')
                acq_tym=datetime.now()
                reltym=acq_tym+timedelta(hours=int(j["Duration"]))
                j["Release Time"]=reltym.strftime('%H:%M:%S')
                # remtym=reltym - datetime.now()
                # print(f'\n {remtym} Remainig for Setup to be Released. ')
                
        
                # temp=j["Duration"].split(":")
                # j["Release Time"]=j["Acquired Time"]+timedelta(hours=int(temp[0]))
                # if temp[0]:
                #     j["Release Time"]=j["Acquired Time"]+timedelta(hours=int(temp[0]),minutes=int(temp[1]))
                # else:
                #      j["Release Time"]=j["Acquired Time"]+timedelta(minutes=int(temp[1]))

        with open("Setups.json","w") as f:
            data=json.dump(t,f)
        print("\nSetup Acquired\n")
        print("\nPlease Don't forget to Release the Setup\n")
            
        
def release(setup="Nil"):
    if setup=="Nil":
        return None
    if setup!="Nil":
        with open("Setups.json","r") as f:
            data=json.load(f)
            t=data
        for i,j in t.items():
            if setup ==i:
                if j["Status"]=="Available":
                    print("\n Setup is Already Available!!..You can use!!\n")
                else:
                    if j["Engineer"]==getpass.getuser():
                        j["Status"]="Available"
                        j["Note"]="Available for use"
                        j["Duration"]="NA"
                        j["Engineer"]="NA"
                        j["Acquired Time"]="NA"
                        j["Release Time"]="NA"
                        with open("Setups.json","w") as f:
                            data=json.dump(t,f)
                        print("\n Thank you !! Setup Released !!")
                    else:
                        print('Only {} is Authorized to Release the Setup!!').format(j["Engineer"])


if args.status is None:
    print("\nPlease enter the Setup No!! ")
if args.acquire is None:
    print("\nPlease enter the Setup No!! ")
if args.release is None:
    print("\nPlease enter the Setup No!! ")


if args.status!="na":
    status(args.status)
    # print(args.status)
if args.acquire!="na":
    acquire(args.acquire)
    # print(args.acquire)
if args.release!="na":
    release(args.release)
    # print(args.release)

if len(sys.argv)<2:
    print("\nKindly Enter the Proper Flags!!\n")
    parser.print_help()
# elif len(sys.argv)==2:
#     print(" \n Kindly Enter the Setup No !!\n")


#To do

#1.Incorrect Arguments Error --DONE

#2.Time Functionalities  --OK

#3.If setup is already in available no release needed same as lik acquire --DONE

#4.Dont allow anybody to acquire --OK

#5.Add?Remove New Setps in Setups.json file  

#6.If Json file Not Found on Startup?

#7.If json decoderror dont touch file

# .Print in Color
