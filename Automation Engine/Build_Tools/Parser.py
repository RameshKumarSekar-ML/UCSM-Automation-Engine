import sys
from datetime import datetime

if len(sys.argv)<=1:
    print("\nPlease Provide Sufficient Argments !!")
    sys.exit(0)

try:
    """
    Parse the Current Date time and Return the Four Digit Build Version
    """
    if sys.argv[1] == "DATE":
        Date=str(datetime.today())
        Parsed=Date.split()[0][-5:].replace("-","")
        print(Parsed)

        """
         Parse the Complete Private Image Path from a Given String 
         For Eg: [ I/P = "VERIFYING Md5 checksum for /nws/rameseka/bugs/L-KBMR1/ucsm/perfocarta/sam/src/.debug/images/ucs-manager-k9.4.2.0.3005A.gbin ......"]
                 [ O/P = "/nws/rameseka/bugs/L-KBMR1/ucsm/perfocarta/sam/src/.debug/images/ucs-manager-k9.4.2.0.3005A.gbin"] 

        """

    elif sys.argv[1] == "UCSM_PATH":
        P=sys.argv[2]
        print(P.split()[-2])
    
        """Parse the UCSM IMAGE from the Complete Path
           For Eg: [ I/P = "/nws/rameseka/bugs/L-KBMR1/ucsm/perfocarta/sam/src/.debug/images/ucs-manager-k9.4.2.0.3005A.gbin"]
           [ O/P = "ucs-manager-k9.4.2.0.3005A.gbin"] 
        """

    elif sys.argv[1] == "UCSM_PI":
        P=sys.argv[2]
        print(P.split('/')[-1])

except IndexError:
    print("\nPlease Enter the Proper Arguments !!")

