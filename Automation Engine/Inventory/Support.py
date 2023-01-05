import sys
import json

with open("c.json","r") as f:
    data=json.load(f)

def Adder():
    print("Adding New Entry!! ")
    data[str(sys.argv[2])]=[str(sys.argv[2]),str(sys.argv[3]),str(sys.argv[4])]
    with open("c.json","w") as f:
        json.dump(data,f)
    print("Added New Setup Entry")

def Add():
    Present=False
    for ip in data.keys():
        if sys.argv[2]==ip:
            print("Details Already Exists")
            Present=True
            break
    if not Present:
        Adder()

def Delete():
    t=data.copy()
    for ip in list(data.keys()):
        if sys.argv[2]==ip:
            del data[ip]
    with open("c.json","w") as ff:
        json.dump(data,ff)
    print("Entry Deleted Successfully!!")


if sys.argv[1]=="--Add":
    Add()
elif sys.argv[1]=="--Del":
    Delete()
