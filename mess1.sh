#!/bin/bash
#Connect to MySQL
cat <<FINISH | mysql -uroot -ppassword

#Create database
drop database if exists dbtest;
CREATE DATABASE dbtest;

#Create user
CREATE USER 'dbtestuser'@'localhost' IDENTIFIED BY 'dbpassword';
GRANT ALL PRIVILEGES ON dbtest.* TO 'dbtestuser'@'localhost' IDENTIFIED BY 'dbpassword';

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

exit 0
