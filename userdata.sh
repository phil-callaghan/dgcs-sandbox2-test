#!/usr/bin/env bash

# General Guidelines
#
# * Directories using global variables may not exist.  A
#   function that relies upon them should ensure they
#   exist.

# The directory used for temporary downloads.
DOWNLOAD_DIR=/tmp/downloads

# The base directory for vendor-specific applications
# adhering to the Filesystem Hierarchy Standard guidelines.
VENDOR_APP_BASE=/opt/gcs

# The home directory of the Maven application
MAVEN_HOME=${VENDOR_APP_BASE}/maven

# The home directory of the Tenant application
TENANT_HOME=${VENDOR_APP_BASE}/tenant

# The username of the service account
TENANT_SERVICE_USER=svc_dgcs

# The name of the group of the service account
TENANT_SERVICE_GROUP=dgcs

# The directory used for building the application
BUILD_WORKDIR=/tmp/build

function cleanup {
    rm -rf ${DOWNLOAD_DIR}
    rm -rf ${BUILD_WORKDIR}
}

function update_os {
    yum update -y
}

function install_packaged_prerequisites {
    yum install -y \
        git \
        java-1.8.0-openjdk-devel
}

function maven_install {
    local maven_archive=${DOWNLOAD_DIR}/maven.tar.gz
    local maven_version="3.5.3"
    local maven_base="maven-${maven_version}"

    mkdir -p $(dirname ${maven_archive})

    curl --output ${maven_archive} \
        --silent http://apache.mirrors.lucidnetworks.net/maven/maven-3/${maven_version}/binaries/apache-maven-${maven_version}-bin.tar.gz

    mkdir -p ${VENDOR_APP_BASE}/${maven_base}
    tar --extract --directory ${VENDOR_APP_BASE}/${maven_base} --file ${maven_archive} --strip-components=1
    ln --symbolic --no-target-directory ${maven_base} ${MAVEN_HOME}
}

function maven_configure {
    alternatives --install /bin/mvn maven ${MAVEN_HOME}/bin/mvn 1
}

function httpd_install {
    yum install -y httpd
}

function httpd_configure {
    cat > /etc/httpd/conf/httpd.conf << HTTPD_CONF
Listen 80

ServerName tenant-api-gw.digitalglobe.com

User apache
Group apache

ServerAdmin dl-gcs-bldeng@digitalglobe.com

Include conf.modules.d/*.conf

<Directory />
    AllowOverride none
    Require all denied
</Directory>

ErrorLog "logs/error.log"

LogLevel warn

<IfModule log_config_module>
    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
    LogFormat "%h %l %u %t \"%r\" %>s %b" common

    <IfModule logio_module>
      # You need to enable mod_logio.c to use %I and %O
      LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %O" combinedio
    </IfModule>

    CustomLog "logs/access.log" combined
</IfModule>

<IfModule mime_module>
    TypesConfig /etc/mime.types

    AddType application/x-compress .Z
    AddType application/x-gzip .gz .tgz

    AddType text/html .shtml
    AddOutputFilter INCLUDES .shtml
</IfModule>

AddDefaultCharset UTF-8

<IfModule mime_magic_module>
    MIMEMagicFile conf/magic
</IfModule>

IncludeOptional conf.d/*.conf
HTTPD_CONF

    rm /etc/httpd/conf.d/*

    local proxy_hostname="tenant-rvrsprxy.digitalglobe.com"
    cat > /etc/httpd/conf.d/${proxy_hostname}.conf << TENANT_PROXY_CONF
<VirtualHost *:80>
    ServerName ${proxy_hostname}

    CustomLog logs/${proxy_hostname}/access.log combined
    ErrorLog logs/${proxy_hostname}/error.log

    ProxyRequests off

    ProxyPass "/" "http://localhost:8080/"
    ProxyPassReverse "/" "http://localhost:8080/"
</VirtualHost>
TENANT_PROXY_CONF

    mkdir -p /etc/httpd/logs/${proxy_hostname}
}

function tomcat_install {
    local tomcat_archive=${DOWNLOAD_DIR}/tomcat.tar.gz

    mkdir -p $(dirname ${tomcat_archive})

    curl --output ${tomcat_archive} \
        --silent http://apache.mirrors.tds.net/tomcat/tomcat-9/v9.0.7/bin/apache-tomcat-9.0.7.tar.gz

    mkdir -p ${TENANT_HOME}
    tar --extract --directory ${TENANT_HOME} --file ${tomcat_archive}  --strip-components=1
}

function tenant_install {
    local src_dir=${BUILD_WORKDIR}/tenant-app

    mkdir ~/.ssh
    chmod 700 ~/.ssh
    ssh-keyscan -H github.com >> ~/.ssh/known_hosts

    mkdir -p ${src_dir}
    git clone git@github.com:dgcs-sandbox/tenant-app ${src_dir}
    cd ${src_dir}

    mvn package

    tomcat_install

    cp target/tenant-*.war ${TENANT_HOME}/webapps/tenant.war

    groupadd ${TENANT_SERVICE_GROUP}
    useradd --no-create-home --shell /sbin/nologin --gid ${TENANT_SERVICE_GROUP} ${TENANT_SERVICE_USER}

    chown --recursive ${TENANT_SERVICE_USER}:${TENANT_SERVICE_GROUP} ${TENANT_HOME}
}

function tenant_configure {
    cat > /etc/systemd/system/tenant.service << TENANT_SERVICE
[Unit]
Description=Tenant Sample Application
After=syslog.target network.target

[Service]
Type=forking

ExecStart=${TENANT_HOME}/bin/startup.sh
ExecStop=${TENANT_HOME}/bin/shutdown.sh

User=${TENANT_SERVICE_USER}
Group=${TENANT_SERVICE_GROUP}

[Install]
WantedBy=multi-user.target
TENANT_SERVICE

    systemctl daemon-reload
}

function tenant_service {
    systemctl enable tenant
    systemctl start tenant
}

update_os
install_packaged_prerequisites

maven_install
maven_configure

httpd_install
httpd_configure

tenant_install
tenant_configure
tenant_service

#cleanup