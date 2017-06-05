#!/bin/bash

# ########################################################################################
#
# Created by TAB - 23rd May 2017
# 
#    Terraform build script for civicrm
#


# ########################################################################################
#
# Parse command line args
: ${3?$'\n\n'"Invalid number of parameters."$'\n\n'"Usage:"$'\n\n'"  $0 -t=APPLY|PLAN|DESTROY -a=AWS_ACCESS_KEY -s=AWS_SECRET_KEY"$'\n\n'}


# ########################################################################################
#
# Configure script
# 
# Set input script variables
#
CLIENT="CiviCRM"
CLIENTDESC='"CiviCRM Cloud Build"'
REGION="eu-west-2"
AMI="ami-c22236a6"
# Set derived script variables
#
DIR=${PWD}
KEY=$CLIENT'_KEY_PAIR'
KEYPEM=$KEY'.pem'
KEYPUB=$KEY'.pub'
NETPATH="$DIR/terraform"
KEYPATH="$NETPATH/KEYS/$KEYPUB"
PEMKEYPATH="$NETPATH/KEYS/$KEYPEM"
PUBKEYPATH="$NETPATH/KEYS/$KEYPUB"
PRIVKEYPATH="$NETPATH/KEYS/$KEY"

#
# Now workout which action to perform from args
# ACTION=  APPLY | PLAN | DESTROY
TYPE="UNKNOWN"
ACCESS="UNKNOWN"
SECRET="UNKNOWN"
for i in "$@"
do
case $i in
    -t=*)
    TYPE="${i#*=}"
    ;;
    -a=*)
    ACCESS="${i#*=}"
    ;;
    -s=*)
    SECRET="${i#*=}"
    ;;
    *)
    echo "Unrecognized parameter."
    exit 2
    ;;
esac
done
ACTION=${TYPE^^}
if ! [[ "$ACTION" == "APPLY" || "$ACTION" == "PLAN"  || "$ACTION" == "DESTROY" ]]
then
    echo "Unrecognized parameter"
    exit 2
fi
#
# End of script config



# ########################################################################################
#
# Check if the key pair exists if not create it 
#
if [ ! -d ./terraform/KEYS ]; then
  mkdir -p ./terraform/KEYS;
fi
cd ./terraform/KEYS/
#  Create rsa key pair [  ssh-keygen -t rsa -f filename -C "contact@example.com"  ]
if [ ! -f $KEY ]; then
    ssh-keygen -t rsa -f $KEY -C "hello@78-o.com";
fi
#  Create .pem file [  ssh-keygen -f id_rsa.pub -m 'PEM' -e > id_rsa.pem ]
if [ ! -f $KEYPEM ]; then
    ssh-keygen -f $KEY -m 'PEM' -e > $KEYPEM;
fi
#  Now change the permissions on all the files
chmod 0600 ./*
cd ..



# ########################################################################################
#
# BUILD CLOUD INSTANCES
#
echo "****************************************************************************"
echo ""
echo "Trying to build the Cloud ... "
echo ""
cd $NETPATH
echo ""

# Run for all PLAN terraform runs
if [ "$ACTION" == "PLAN" ]
then
terraform plan -var 'client_short_name='$CLIENT -var 'region_name='$REGION -var 'key_name='$KEY -var 'private_key='$PRIVKEYPATH -var 'public_key_path='$PUBKEYPATH -var "client_desc=$CLIENTDESC" -var 'ami_id='$AMI -var 'access_key='$ACCESS -var 'secret_key='$SECRET -var 'exec_path='$DIR
# -var 'db_name='$DBNAME -var 'db_user_name='$DBUSER -var 'db_user_pass='$DBPASS
fi
# Run for all APPLY terraform runs
if [ "$ACTION" == "APPLY" ]
then
terraform apply -var 'client_short_name='$CLIENT -var 'region_name='$REGION -var 'key_name='$KEY -var 'private_key='$PRIVKEYPATH -var 'public_key_path='$PUBKEYPATH -var "client_desc=$CLIENTDESC" -var 'ami_id='$AMI -var 'access_key='$ACCESS -var 'secret_key='$SECRET -var 'exec_path='$DIR
# -var 'db_name='$DBNAME -var 'db_user_name='$DBUSER -var 'db_user_pass='$DBPASS
fi
# Run for all DESTROY terraform runs
if [ "$ACTION" == "DESTROY" ]
then
terraform destroy -var 'client_short_name='$CLIENT -var 'region_name='$REGION -var 'key_name='$KEY -var 'private_key='$PRIVKEYPATH -var 'public_key_path='$PUBKEYPATH -var "client_desc=$CLIENTDESC" -var 'ami_id='$AMI -var 'access_key='$ACCESS -var 'secret_key='$SECRET -var 'exec_path='$DIR
# -var 'db_name='$DBNAME -var 'db_user_name='$DBUSER -var 'db_user_pass='$DBPASS
fi


echo ""
echo " ... cloud settings applied with action: $ACTION."
echo ""
echo ""