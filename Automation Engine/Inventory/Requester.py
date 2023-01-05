#!/users/rameseka/Python3.9/bin/python3.9
import requests
#import urllib3
#from urllib3.exceptions import InsecureRequestWarning

#requests.packages.urllib3.disable_warnings(category=InsecureRequestWarning)
#urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)


"""
The Requestor is a Function that takes XML CODE as a argument , makes a Request to the user Specified IP and Return the Response from the Server in the form of XML Format
"""
def REQUESTER(xml_code,IP):
    payload=xml_code
    URL="http://{}/nuova".format(IP)
    headers={'Content-Type': 'application/xml'}
    Response_data=requests.post(URL,data=payload,headers=headers,verify=False)
    return Response_data.text


XML='<configConfMos cookie="1656355307/b6eeaabe-43de-4bbd-b6b7-96534a76f07b" inHierarchical="false"><inConfigs><pair key="sys/fw-catalogue/dnld-ucs-manager-k9.4.2.0.2206b.gbin"><firmwareDownloader fileName="ucs-manager-k9.4.2.0.2206b.gbin" pwd="RamSRK321@#" remotePath="/auto/wssjc-nuo11/rameseka/temp/sam/src/.debug/images" server="10.193.241.68" user="rameseka" dn="sys/fw-catalogue/dnld-ucs-manager-k9.4.2.0.2206b.gbin" status="created" sacl="addchild,del,mod" /></pair></inConfigs></configConfMos>'
IP="10.127.56.65"
R=REQUESTER(XML,IP)
print(R)
