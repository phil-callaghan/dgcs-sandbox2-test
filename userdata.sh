#!/bin/bash

# Install Requirements (Git, Java)
yum install -y wget git java-1.8.0-openjdk-devel

# Install Tomcat
cd /opt
wget http://apache.mirrors.tds.net/tomcat/tomcat-9/v9.0.7/bin/apache-tomcat-9.0.7.tar.gz
tar xzf apache-tomcat-9.0.7.tar.gz
ln -s apache-tomcat-9.0.7 tomcat
rm -f apache-tomcat-9.0.7.tar.gz
groupadd tomcat
useradd -s /bin/nologin -g tomcat -d /opt/tomcat tomcat
chown -hR tomcat:tomcat tomcat

# Install Maven
cd /usr/local
wget http://apache.mirrors.lucidnetworks.net/maven/maven-3/3.5.3/binaries/apache-maven-3.5.3-bin.tar.gz
tar xzf apache-maven-3.5.3-bin.tar.gz
ln -s apache-maven-3.5.3 maven
cat << EOF > /etc/profile.d/maven.sh
export M2_HOME=/usr/local/maven
export PATH=${M2_HOME}/bin:${PATH}
EOF
source /etc/profile.d/maven.sh
rm -f /usr/local/apache-maven-3.5.3-bin.tar.gz

# Clone tenant app

# Compile Maven project

# Move artifacts to system location
