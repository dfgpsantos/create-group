#!/bin/bash

NSXUSER='youruserhere'
#NSXPASS='yourpasswordhere'
NSXMAN='yournsxmanagerhere'

read -s -p "Password: " NSXPASS

#txt files cleanup

rm -rf *.txt


#Group Configuration

GROUPLIST="groups.list"
GROUPSEQ=0

for GROUPLINE in `cat $GROUPLIST`

do

GROUPSEQ=$(( $GROUPSEQ + 1))

GROUPNAME=`echo $GROUPLINE | awk '{print $1}' FS=\;`

echo $GROUPNAME

GROUPCONTENT=`echo $GROUPLINE | awk '{print $2}' FS=\;`

echo $GROUPCONTENT

#Group Creation

cat > Group$GROUPNAME.txt << EOL
{
    "expression": [
      {
        "ip_addresses" : [ $GROUPCONTENT ],
        "resource_type" : "IPAddressExpression"
      }
    ],
    "display_name": "$GROUPNAME"
}
EOL

echo `cat Group$GROUPNAME.txt`

sed -i 's/\"\,\"/\"\,\ \"/g' Group$GROUPNAME.txt

echo "Creating Group $GROUPNAME with the IP Addresses $GROUPCONTENT"

curl -k --user $NSXUSER:$NSXPASS https://$NSXMAN/policy/api/v1/infra/domains/default/groups/$GROUPNAME -X PATCH --data @Group$GROUPNAME.txt -H "Content-Type: application/json"

sleep 1


done


#Clean up

read -p "Do you want to delete the .txt files created for migration? (Y/N)"  -r CHOICE
echo
if [[ $CHOICE =~ ^[Yy]$ ]];

then

echo "Deleting .txt files"
rm -rf *.txt

else
echo "Saving the .txt files"

fi

echo "Task completed! $GROUPSEQ Groups(s) have been configured in NSX $NSXMAN."
