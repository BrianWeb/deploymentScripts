#!/bin/bash


#Stop apache & mysql (if they are running)
sudo service apache2 stop 
sudo service mysql stop

# Clean Apache and Mysql environment
sudo apt-get -q -y --purge remove apache
sudo apt-get -q -y --purge remove mysql-server mysql-client mysql-common
sudo apt-get -q -y autoremove
sudo apt-get -q -y autoclean
#(Purge command removes apache package including all configuration files)

#Refresh apt-get package repository
sudo apt-get update

Once the operating system is at a ‘clean’, up to date state, Apache and MySql can be installed, as the commands from the Bash script show, below.

 #Install Apache2
sudo apt-get -q -y install apache2

#Install MySQL
echo mysql-server mysql-server/root_password password password | debconf-set-selections
echo mysql-server mysql-server/root_password_again password password | debconf-set-selections
apt-get -q -y install mysql-server mysql-client
 
Once Apache and MySQL were installed the Perl libraries and modules were installed so that Apache could handle Perl extensions, allowing Perl files to execute commands to the MySQL database.

#Below command enables ‘make’ command on Ubuntu which is needed to install the libraries.
sudo apt-get install build-essential

#Install perl library helper routines:
sudo apt-get -q -y install curl gcc-4.7
sudo curl -L http://cpanmin.us | perl - --sudo App::cpanminus
# Install Perl CGI handling module:
sudo cpanm CGI
# Install Perl database connector:
sudo cpanm DBI

Once the perquisites for the web application are running, we can download the application from GitHub to a sandbox;

cd /tmp
#
SANDBOX=sandbox_$RANDOM
mkdir $SANDBOX
cd $SANDBOX
ERRORCHECK=0
#
# Make the process directories
mkdir build
mkdir integrate
mkdir test
mkdir deploy
#
cd /webpackage

# Download Web app from Github into Sandbox

git clone https://github.com/FSlyne/NCIRL.git

# Tar up the webpackage and call it webpacage_preBuild.tgz
# Check if the MD5 checksum of the file has changed
# Store MD5 checksum in the file –
# If MD5 checksum hasn’t changed then exit the script. Otherwise proceed
tar -zcvf webpackage_preBuild.tgz webpackage
MD5SUM=$(md5sum webpackage_preBuild.tgz | cut -f 1 -d' ')
PREVMD5SUM=$(cat /tmp/md5sum)
FILECHANGE=0
if [[ "$MD5SUM" != "$PREVMD5SUM" ]]
then
        FILECHANGE=1
        echo $MD5SUM not equal to $PREVMD5SUM
else
        FILECHANGE=0
        echo $MD5SUM equal to $PREVMD5SUM
fi
echo $MD5SUM > /tmp/md5sum
if [ $FILECHANGE -eq 0 ]
then
        echo no change in files, doing nothing and exiting
        exit
fi
#

# BUILD
# Move Webpackage tar file to build directory
mv webpackage_preBuild.tgz build
rm -rf webpackage
cd build
# 
# Untar the webpacke-preBuild
tar -zxvf webpackage_preBuild.tgz
#
cd NCIRL/

Once they have been downloaded into the sandbox, they are then copied into the default Apache folders for HTML and CGI files respectively –

#Copy all files (i.e. HTML files) from NCIRL/Apache/www (downloaded from GitHUb) to the local Apache www folder
sudo cp -r Apache/www/* /var/www

#Copy all files (i.e. script files) from NCIRL/Apache/cgi-bin (downloaded from GitHUb) to the local Apache cgi-bin folder
sudo cp -r Apache/cgi-bin/* /usr/lib/cgi-bin

#set permissions appropriately
cd /
sudo chmod a+x /usr/lib/cgi-bin/*
sudo chmod a+x /var/www/*

#Start Apache and MySQL services
sudo service apache2 start
sudo service mysql start

# Tar/zip up webpackage, call it webpackage_preIntegrate.tgz
tar -zcvf webpackage_preIntegrate.tgz webpackage
#
#Set ERRORCHECK if any errors
ERRORCHECK=0

# INTEGRATE:
# Move Webpackage tar file to integrate directory
mv webpackage_preIntegrate.tgz ../integrate
rm -rf webpackage
cd ../integrate
#
# Untar/unzip file
tar -zxvf webpackage_preIntegrate.tgz
#
# Script commands as per the build process
#
# Tar/zip up webpackage, call it webpackage_preTest.tgz
tar -zcvf webpackage_preTest.tgz webpackage
#
# Set ERRORCHECK if any errors
ERRORCHECK=0

# TEST
# Move Webpackage tar file to the test directory
mv webpackage_preTest.tgz ../test
rm -rf webpackage
cd ../test
#
# Untar/unzip file
tar -zxvf webpackage_preTest.tgz
#
#Connect to MySQL
cat <<FINISH | mysql -uroot -ppassword

#Create database
drop database if exists dbtest;
CREATE DATABASE dbtest;

#Create user
CREATE USER 'dbtestuser'@'localhost' IDENTIFIED BY 'dbpassword';
GRANT ALL PRIVILEGES ON dbtest.* TO ‘dbtestuser’@’localhost’ IDENTIFIED BY 'dbpassword';

#Create table
use dbtest;
drop table if exists custdetails;
create table if not exists custdetails
 (
name VARCHAR(30)   NOT NULL DEFAULT '',
address VARCHAR(30)   NOT NULL DEFAULT ''
);

#Insert test data into table
insert into custdetails (name,address) values ('John Smith','Street Address');

select * from custdetails;
FINISH

#Restart services
sudo service apache2 restart 
sudo service mysql restart

#Cleanup - remove Sandbox directory
cd /tmp
rm -rf $SANDBOX

# Tar/zip up webpackage, call it webpackage_preDeploy.tgz
tar -zcvf webpackage_preDeploy.tgz webpackage
#
# Set ERRORCHECK if any errors
ERRORCHECK=0
#

exit 0

