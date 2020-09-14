#!/bin/bash
# Copyright (c) 2019, 2020 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#
#
# Description: Sets up Mushop Basic a.k.a. "Monolite".
# Return codes: 0 =
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#

get_object() {
    out_file=$1
    os_uri=$2
    success=1
    for i in $(seq 1 9); do
        echo "trying ($i) $2"
        http_status=$(curl -w '%%{http_code}' -L -s -o $1 $2)
        if [ "$http_status" -eq "200" ]; then
            success=0
            echo "saved to $1"
            break 
        else
             sleep 15
        fi
    done
    return $success
}

get_media_pars() {
    input_file=$1
    field=1
    success=1
    count=`sed 's/[^,]//g' $input_file | wc -c`; let "count+=1"
    while [ "$field" -lt "$count" ]; do
            par_url=`cat $input_file | cut -d, -f$field`
            printf "."
            curl -OLs --retry 9 $par_url
            let "field+=1"
    done
    return $success
}

# Configure firewall
firewall-offline-cmd --add-port=80/tcp
systemctl restart firewalld

# Install the yum repo
yum clean metadata
yum-config-manager --enable ol7_latest

# Install tools
yum -y erase nodejs
yum -y install unzip httpd jq

# Get metadata
ATP_DB_NAME=$(curl -L http://169.254.169.254/opc/v1/instance/metadata | jq -j ".db_name")
ATP_PW=$(curl -L http://169.254.169.254/opc/v1/instance/metadata | jq -j ".atp_pw")
CATALOGUE_SQL_URI=$(curl -L http://169.254.169.254/opc/v1/instance/metadata | jq -j ".catalogue_sql_par")
APACHE_CONF_URI=$(curl -L http://169.254.169.254/opc/v1/instance/metadata | jq -j ".apache_conf_par")
ENTRYPOINT_URI=$(curl -L http://169.254.169.254/opc/v1/instance/metadata | jq -j ".entrypoint_par")
MUSHOP_APP_URI=$(curl -L http://169.254.169.254/opc/v1/instance/metadata | jq -j ".mushop_app_par")
WALLET_URI=$(curl -L http://169.254.169.254/opc/v1/instance/metadata | jq -j ".wallet_par")
ASSETS_URL=$(curl -L http://169.254.169.254/opc/v1/instance/metadata | jq -j ".assets_url")
ORACLE_CLIENT_VERSION=$(curl -L http://169.254.169.254/opc/v1/instance/metadata | jq -j ".oracle_client_version")
MUSHOP_MEDIA_VISIBILITY=$(curl -L http://169.254.169.254/opc/v1/instance/metadata | jq -j ".mushop_media_visibility")
MUSHOP_MEDIA_PARS_LIST=$(curl -L http://169.254.169.254/opc/v1/instance/metadata | jq -j ".mushop_media_pars_list_par")

# Install Oracle Instant Client
yum -y install oracle-release-el7
yum-config-manager --enable ol7_oracle_instantclient
yum -y install oracle-instantclient$${ORACLE_CLIENT_VERSION}-basic oracle-instantclient$${ORACLE_CLIENT_VERSION}-jdbc oracle-instantclient$${ORACLE_CLIENT_VERSION}-sqlplus

# Install NodeJs
yum -y install oracle-nodejs-release-el7
yum -y install --disablerepo=ol7_developer_EPEL nodejs

# Enable and start services
systemctl daemon-reload

# get artifacts from object storage
get_object /root/wallet.64 $${WALLET_URI}
# Setup ATP wallet files
base64 --decode /root/wallet.64 > /root/wallet.zip
unzip /root/wallet.zip -d /usr/lib/oracle/$${ORACLE_CLIENT_VERSION}/client64/lib/network/admin/

# Init DB
get_object /root/catalogue.sql $${CATALOGUE_SQL_URI}
sqlplus admin/$${ATP_PW}@$${ATP_DB_NAME}_tp @/root/catalogue.sql

# Get http server config
get_object /etc/httpd/conf/httpd.conf $${APACHE_CONF_URI}

# Get binaries
get_object /root/mushop-bin.tar.gz $${MUSHOP_APP_URI}
tar zxvf /root/mushop-bin.tar.gz -C /

# If visibility set to private, get MuShop Media Assets
if [[ "$MUSHOP_MEDIA_VISIBILITY" == Private ]]; then
        echo "MuShop Media Private Visibility selected"
        get_object /root/mushop_media_pars_list.txt $${MUSHOP_MEDIA_PARS_LIST}
        mkdir -p /root/images
        cd /root/images        
        echo "Loading MuShop Media Images to Catalogue..."
        get_media_pars /root/mushop_media_pars_list.txt
        echo "Images loaded"
fi

# setup init script
get_object /root/entrypoint.sh $${ENTRYPOINT_URI}
chmod +x /root/entrypoint.sh

# Setup app variables
export OADB_USER=catalogue_user
export OADB_PW=default_Password1
export OADB_SERVICE=$${ATP_DB_NAME}_tp
export STATIC_MEDIA_URL=$${ASSETS_URL}
cd /root
/root/entrypoint.sh >/root/mushop.log 2>&1 &
