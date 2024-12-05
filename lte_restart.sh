URL="http://192.168.9.1"

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

cmd_output=$(curl -s -X GET "${URL}/api/webserver/SesTokInfo")
COOKIE=$(echo $cmd_output | cut -b 58-185)
TOKEN=$(echo $cmd_output | cut -b 205-236)

#Reboot modem
curl --connect-timeout 5 -s -X POST "${URL}/api/device/control" -b "SessionID=$COOKIE" -H "__RequestVerificationToken: $TOKEN" -H "Content-Type: text/xml" -d '<request><Control>1</Control></request>'

if [ $? == 0 ]
    then
        echo -e "\n${GREEN}-------------------"
        echo -e "Successfully sent command to reboot LTE modem${NC}"
#         read -p "Press Enter to exit"

    else
        echo -e "\n${RED}-------------------"
        echo -e "Did not pass request to reboot LTE modem${NC}"
#         read -p "Press Enter to exit"
fi
