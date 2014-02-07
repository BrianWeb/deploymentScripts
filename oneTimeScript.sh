START!!!
#!/bin/bash


# ------- REMOVE AND THEN INSTALL APACHE & MYSQL CLEANLY --------------

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

#Install Apache2
sudo apt-get -q -y install apache2

#Install mySQL
echo mysql-server mysql-server/root_password password password | debconf-set-selections
echo mysql-server mysql-server/root_password_again password password | debconf-set-selections
apt-get -q -y install mysql-server mysql-client
 

# --------- INSTALLING PERL -------------

#Install perl library helper routines:
sudo apt-get -q -y install curl gcc-4.7
sudo curl -L http://cpanmin.us | perl - --sudo App::cpanminus
# Install Perl CGI handling module:
sudo cpanm CGI
# Install Perl database connector:
sudo cpanm DBI


# ---- DOWNLOAD APPLICATION ----  

#Create a sandbox with random salt added to name 
cd  /tmp
mkdir sandbox_$RANDOM
echo Using sandbox $SANDBOX
cd $SANDBOX/

# Download Web app from Github into Sandbox
git clone https://github.com/FSlyne/NCIRL.git
cd NCIRL/

#Copy all files (i.e. HTML files) from NCIRL/Apache/www (downloaded from GitHUb) to the local Apache www folder
sudo cp -r Apache/www/* /var/www

#Copy all files (i.e. script files) from NCIRL/Apache/cgi-bin (downloaded from GitHUb) to the local Apache cgi-bin folder
sudo cp -r Apache/cgi-bin/* /usr/lib/cgi-bin

#set permissions appropriately
sudo chmod a+x usr/lib/cgi-bin/*
sudo chmod a+x /var/www/*

#Start Apache and MySQL services
sudo service apache2 start
sudo service mysql start

----CREATE MYSQL TABLES---

#Connect to MySQL
cat <<FINISH | mysql -uroot -ppassword

#Create database
drop database if exists dbtest;
CREATE DATABASE dbtest;

#Create user
DROP USER ‘dbtestuser’@‘localhost’;
CREATE USER 'dbtest'@'localhost' IDENTIFIED BY 'dbpassword';
GRANT ALL PRIVILEGES ON dbtest.* TO dbtestuser@localhost IDENTIFIED BY 'dbpassword';


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

exit 0

