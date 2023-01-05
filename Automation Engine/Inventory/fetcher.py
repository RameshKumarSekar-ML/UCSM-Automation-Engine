#!/users/rameseka/python3.10/bin/python3.10
#from __future__ import print_function
#from __future__ import unicode_literals
from json.decoder import JSONDecodeError
import requests
from requests.api import get
requests.urllib3.disable_warnings()
from xml.etree import cElementTree as ET
from xml.dom import minidom
#import pandas as pd
import sys
from tabulate import tabulate
import json
import argparse
import urllib3
from requests.packages.urllib3.exceptions import InsecureRequestWarning
import Requester
import textwrap

D={}

parser = argparse.ArgumentParser(
        prog='Cisco UCS Automation : ',
        description="This Cisco UCS Script will let's you to Fetch Equipment information from UCS Manager via XML API and Display the Searched Component details in a User Friendly Tabular Format.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=textwrap.dedent('''\
         Additional information:
         ''')
    )
parser.add_argument('--getAdaptors',nargs='?',default="defi",help="An Optional String that will Search for the Specific Adapters in all the Setup's , You can Search for Adaptor Model/Vendor/Serial ",metavar="")
parser.add_argument('--getBladeServers',nargs='?',default="defi",help="An Optional Parameter that will Fetch all the Blade Servers You can Search for Blade Model/Vendor/Serial ",metavar="")
parser.add_argument('--getRackServers',nargs='?',default="defi",help="An Optional Parameter that will Fetch all the Rack Mount Servers You can Search for Rack Model/Vendor/Serial ",metavar="")
parser.add_argument('--getControllers',nargs='?',default="defi",help="An Optional Parameter that will Fetch all the Storage Controllers You can Search for Controller Model/Vendor/Serial ",metavar="")
parser.add_argument('--getFIs',nargs='?',default="defi",help="An Optional parameter that will fetch all the Fabric Interconnect(FI) Details",metavar="")
parser.add_argument('--getDisks',nargs='?',default="defi",help="An Optional Parameter that will Fetch all the Storage Controllers Disks You can Search for Disk State/Model/Vendor/Serial ",metavar="")
# parser.print_help()
args = parser.parse_args()

def FETCHER(IPaddr,Uname,Passwd):
    
    """  
    Usually when Dealing with Request's , Intrepreter Might Raise warning about Insecure Connection Request, In order to Resolve thiis warning and Make most user friendly script we must ignore this Warning using the Following snippet ! 
    """
    urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
    requests.packages.urllib3.disable_warnings(InsecureRequestWarning)
    IP_Addr=IPaddr  
    IP=IP_Addr.strip().split('/')[-1] 
    USERNAME=Uname 
    PASSWORD=Passwd 
    """
    XML_ALTERNATOR Function takes XML_CODE as an Argument and Makes Request to the Specified IP Using POST Requests Library and Return XML_Response Code
    """
    def XML_ALTERNATOR(Response):
        Login_Response = Response
        XML_Element_Tree = ET.fromstring(Login_Response)
        COOKIE=XML_Element_Tree.attrib['outCookie']
        configResolveClass_Server_Query ='<configResolveClasses cookie="1617209698/8bf08bee-8e3c-463a-bb7a-b51c59545cf0" inHierarchical="true"> <inIds> <Id value="computeItem"/> <Id value="computeRackUnit" /> </inIds> </configResolveClasses>'
        DOM = minidom.parseString(configResolveClass_Server_Query)
        ELEMENT = DOM.getElementsByTagName('configResolveClasses')
        ELEMENT[0].setAttribute('cookie', COOKIE)
        CONFIG_QUERY_WITH_NEW_COOKIE=DOM.toprettyxml(indent='    ')
        t=ET.fromstring(CONFIG_QUERY_WITH_NEW_COOKIE)
        XML_ALTERNATOR.New_cookie=t.attrib['cookie']
        return CONFIG_QUERY_WITH_NEW_COOKIE

    """
    FI_FETCHER Function takes Response Returned from XML_ALTERNATOR Function Which Mainly Replaces the New Response Cookie Returned from UCS Login Request
    """
    def FI_FETCHER(Cookie):
        FI_CONFIG_QUERY_WITH_NEW_COOKIE=('<configResolveClasses cookie="{}" inHierarchical="true"> <inIds> <Id value="computeItem"/> <Id value="networkElement" /> </inIds> </configResolveClasses>').format(Cookie)
        return FI_CONFIG_QUERY_WITH_NEW_COOKIE

    # """Login Request XML Code"""
    try:
        Login_Query=('<aaaLogin inName= {} inPassword= {} ></aaaLogin>').format(USERNAME,PASSWORD)
        Login_Response = Requester.REQUESTER(Login_Query,IP)
        print("hi")
        print(Login_Response)
        Config_Response=Requester.REQUESTER(XML_ALTERNATOR(Login_Response),IP)
        print(Config_Response)
        Fi_Response=Requester.REQUESTER(FI_FETCHER(XML_ALTERNATOR.New_cookie),IP)
        Server_ElementTree=ET.ElementTree(ET.fromstring(Config_Response))
        FI_ElementTree=ET.ElementTree(ET.fromstring(Fi_Response))
    except requests.exceptions.RequestException:
        #print('\n {} Unreachable').format(IP)
        print("\n Incorrect IP/Credentials or Connection Error")
        print("\n Might be Setup Unreachable/Please Try Again!!")
        # quit()
        return None
    
    def Logout():
        Logout_Query=("<aaaLogout inCookie={}/>").format(XML_ALTERNATOR.New_cookie)
        Requester.REQUESTER(Logout_Query,IP)
        # print("Logged Out")

    Logout()
    SERVERS={}
    FI={}
    DUP=[]
    FI_counter=0
    counter=0
    """
    This Section of Code Extracts the Specific Fabric Interconnect Attributes from the ConfigResolveClasses XML Response and Save's in the Nested Dictionary Format
    """
    for node in FI_ElementTree.findall('.//outConfigs/'):
        FI_counter += 1
        if node.tag=="networkElement":
            FI[FI_counter]={
                                "UCS IP":IP,
                                "FI Name":node.attrib['dn'],
                                "FI Model":node.attrib['model'],
                                "FI Serial":node.attrib['serial'],
                                "IP Address":node.attrib['oobIfIp'],
                                "Subnet Mask":node.attrib['oobIfMask'],
                                "Default Gateway":node.attrib['oobIfGw']
                         }
        else:
            break

    def Adapters():
        Adps=[]
        ADAPTERS={}
        c=0
        for node in Server_ElementTree.findall('.//outConfigs/*'):
            for adapter in node.findall('.//adaptorUnit'):
                if adapter.attrib['serial'] not in Adps:
                    ADAPTERS[c]= {      "Setup IP":IP_Addr,
                                        "Server ID" : node.attrib["serverId"],                     
                                        "Adapter ID":adapter.attrib['id'],
                                        "Adapter Model":adapter.attrib['model'],
                                        "Adapter Serial":adapter.attrib['serial'],
                                        "Adapter Vendor":adapter.attrib['vendor']  
                                }
                    c+=1
                Adps.append(adapter.attrib['serial'])
        Adaps={"Adapters":ADAPTERS}
        D[IP_Addr]=Adaps
        

    def Blades():
        Blds=[]
        BLADES={}
        c=0
        for node in Server_ElementTree.findall('.//outConfigs/*'):
            if node.tag=="computeBlade" and node.attrib['serial'] not in Blds:
                BLADES[c]={   
                               "Setup IP":IP_Addr,
                               "Server ID":node.attrib['serverId'],
                               "Server Type": "Blade Server",
                               "Chassis ID":node.attrib['chassisId'],
                               "Blade Slot ID":node.attrib['slotId'],
                               "Blade Model":node.attrib['model'],
                               "Blade Serial":node.attrib['serial'],
                               "No of Adaptors":node.attrib['numOfAdaptors']
                          }
                c+=1
            Blds.append(node.attrib['serial'])
        Blades={"Blades":BLADES}
        D[IP_Addr].update(Blades)


    def Racks():
        c=0
        DUP=[]
        RACKS={}
        for node in Server_ElementTree.findall('.//outConfigs/*'):
            if node.tag=="computeRackUnit" and node.attrib['serial'] not in DUP: 
                RACKS[c]={
                            "Setup IP":IP_Addr,
                            "Server ID":node.attrib['serverId'],
                            "Server Type": "Rack Server",
                            "Model" : node.attrib['model'],
                            "Serial" : node.attrib['serial'],
                            "Adapter's" : node.attrib['numOfAdaptors']
                        }
                c+=1
            DUP.append(node.attrib['serial'])
        Racks={"Racks":RACKS}
        D[IP_Addr].update(Racks)

    def Fi():
        Fi={"Fi":FI}
        D[IP_Addr].update(Fi)

    def Controllers():
        Contls=[]
        CONTROLLERS={}
        c=0
        for node in Server_ElementTree.findall('.//outConfigs/*'):
            for controller in node.findall('.//computeBoard/storageController'):
                disks=[disk for disk in node.findall('.//storageLocalDisk')]
                if controller.attrib['serial'] not in Contls:
                    CONTROLLERS[c]={
                                    "Setup IP":IP_Addr,
                                    "Server ID":node.attrib['serverId'],
                                    "S Controller ID":controller.attrib['id'],
                                    "S Controller Name":controller.attrib['rn'],
                                    "S Controller Type":controller.attrib['type'],
                                    "S Controller Model":controller.attrib['model'],
                                    "S Controller Serial":controller.attrib['serial'],
                                    "S Controller Vendor":controller.attrib['vendor'],
                                    "S Controller Security Flag":controller.attrib['controllerFlags'],
                                    "No of Disks Present":str(len(disks))
                                }
                    c+=1
                Contls.append(controller.attrib['serial'])
        Controllers={"Controllers":CONTROLLERS}
        D[IP_Addr].update(Controllers)
    
    def Disks():
        Dsks=[]
        DISKS={}
        c=0
        for node in Server_ElementTree.findall('.//outConfigs/*'):
            for disk in node.findall('.//computeBoard/storageController/storageLocalDisk'):
                if disk.attrib['serial'] not in Dsks:
                    DISKS[c]={
                            "Setup IP":IP_Addr,
                            "Server ID":node.attrib['serverId'],
                            "Disk ID":disk.attrib['id'],
                            "Disk Type":disk.attrib['deviceType'],
                            "Disk Serial":disk.attrib['serial'],
                            "Disk Vendor":disk.attrib['vendor'],
                            "Disk Speed":disk.attrib['linkSpeed'],
                            "Disk State":disk.attrib['diskState']
                        }
                    c+=1
                Dsks.append(disk.attrib['serial'])
        Disks={"Disks":DISKS}
        D[IP_Addr].update(Disks)
        

    # Adapters()
    # Fi()
    # Racks()
    # Blades()
    # Controllers()
    # Disks()
    if args.getAdaptors:
        Adapters()
    if args.getFIs:
        Fi()
    if args.getRackServers:
        Racks()
    if args.getBladeServers:
        Blades()
    if args.getControllers:
        Controllers()
    if args.getDisks:
        Disks()
with open("config.json","r") as f:
   data=json.load(f)

if len(sys.argv)<2:
    print("\n Kindly Provide the Proper Flags !! \n ")
    parser.print_help()

elif len(sys.argv)==2:
    print(" \n Please Enter your Search Query !!\n")

else:
    for x in data.values():
        #FETCHER(x[0],x[1],x[2])
        try:
           STATUS=requests.get("http://"+x[0],verify=False)
           if STATUS.status_code == 200:
               print("OK")
           else:
               print("FAILL")
        except requests.exceptions.RequestException as e:
            print("FAIL")
            print(e)
      #def printer(data):
       # df = pd.DataFrame.from_dict(data,orient='index')
        #print(tabulate(df,tablefmt='fancy_grid'))"""


    if args.getAdaptors!="defi":
        found=False
        for k,v in D.items():
            for v1,v2 in v.items():
                if v1=="Adapters":
                    for vv1,vv2 in v2.items():
                        for x1,x2 in vv2.items():
                            if args.getAdaptors.lower() in x2.lower():
                                found=True
                                print(vv2)
        if not found:
            print("\n<---Adapter Not Availble in Any of the Setups!--->\n")

    if args.getBladeServers!="defi":
        found=False
        for k,v in D.items():
            for v1,v2 in v.items():
                if v1=="Blades":
                    for vv1,vv2 in v2.items():
                        for x1,x2 in vv2.items():
                            if args.getBladeServers.lower() in x2.lower():
                                found=True
                                print(vv2)
        if not found:
            print("\n<---Blade Not found in any of the Setups!!--->\n")


    if args.getRackServers!="defi":
        found=False
        for k,v in D.items():
            for v1,v2 in v.items():
                if v1=="Racks":
                    for vv1,vv2 in v2.items():
                        for x1,x2 in vv2.items():
                            if args.getRackServers.lower() in x2.lower():
                                found=True
                                print(vv2)
        if not found:
            print("\n<---Rack Not Present in Any of the Available Setups!!--->\n")

    if args.getControllers!="defi":
        found=False
        for k,v in D.items():
            for v1,v2 in v.items():
                if v1=="Controllers":
                    for vv1,vv2 in v2.items():
                        for x1,x2 in vv2.items():
                            if args.getControllers.lower() in x2.lower():
                                found=True
                                print(vv2)
        if not found:
            print("\n<---Controller Not Present in Any of the Setups!!--->\n")

    if args.getFIs!="defi":
        found=False
        for k,v in D.items():
            for v1,v2 in v.items():
                if v1=="Fi":
                    for vv1,vv2 in v2.items():
                        for x1,x2 in vv2.items():
                            if args.getFIs.lower() in x2.lower():
                                found=True
                                print(vv2)
        if not found:
            print("\n<--FI Not avilable in any of our Setups!!--->\n")

    if args.getDisks!="defi":
        found=False
        for k,v in D.items():
            for v1,v2 in v.items():
                if v1=="Disks":
                    for vv1,vv2 in v2.items():
                        for x1,x2 in vv2.items():
                            if args.getDisks.lower() in x2.lower():
                                found=True
                                print(vv2)
        if not found:
            print("\n<---Disk Not Available in any of our Setups!!--->\n")

    # Argss=[args.getAdaptors=="defi",args.getFIs=="defi",args.getControllers=="defi",args.getDisks=="defi",args.getBladeServers=="defi",args.getRackServers=="defi"]   
    # res=all(Argss)
    # if res:
    #     print("\n Kindly Provide the Proper Flags !! \n ")

    # if len(sys.argv)<1:
    #     print("\n Kindly Provide the Proper Flags !! \n ")
    # if len(sys.argv)<2:
    #     print("\n Kindly Provide the Proper Flags !! \n ")
    # elif len(sys.argv)==2:
    #     print(" Please Enter your Search Query !!")
