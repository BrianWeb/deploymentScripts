
#!/bin/bash
# Reference: fslyne 2013

ADMINISTRATOR=brianwebberley@yahoo.ie
MAILSERVER=mail1.eircom.net

# Level 1 functions <---------------------------------------

#Function to check if Apache is running
# returns  value of isRunning apache2
function isApacheRunning {
        isRunning apache2
        return $?
}

#Function to check if Apache is listening for TCP traffic on port 80
# Returns value of isTCPlisten 80
function isApacheListening {
        isTCPlisten 80
        return $?
}

#Function to check if MySQL is listening for TCP traffic on port 3306
# Returns value of isTCPlisten 3306
function isMysqlListening {
        isTCPlisten 3306
        return $?
}

# Returns value of isTCPremoteOpen localhost 80
function isApacheRemoteUp {
        isTCPremoteOpen 127.0.0.1 80
        return $?
}

# Function to check if MySQL is running
# Returns value of isRunning mysqld
function isMysqlRunning {
        isRunning mysqld
        return $?
}

# Returns value of isTCPremoteOpen localhost 3306
function isMysqlRemoteUp {
        isTCPremoteOpen 127.0.0.1 3306
        return $?
}


# Functional Body of monitoring script <----------------------------

# If isApacheRunning is true then logWrite Apache process is Running else logWrite Apache process is not Running
isApacheRunning
if [ "$?" -eq 1 ]; then
        echo Apache process is Running
else
        echo Apache process is not Running
        ERRORCOUNT=$((ERRORCOUNT+1))
fi

# If  isApacheListening is true then logWrite Apache  is Listening else logWrite Apache is not Listening
isApacheListening
if [ "$?" -eq 1 ]; then
        echo Apache is Listening
else
        echo Apache is not Listening
        ERRORCOUNT=$((ERRORCOUNT+1))
fi

# If isApacheRemoteUp is true then logWrite Remote Apache TCP port is up  is up else logWrite Remote Apache TCP port is down
isApacheRemoteUp
if [ "$?" -eq 1 ]; then
        echo Remote Apache TCP port is up
else
        echo Remote Apache TCP port is down
        ERRORCOUNT=$((ERRORCOUNT+1))
fi

#If isMyqlRunning is true then logWrite Mysql process is Running else logWrite Mysql process is not Running
isMysqlRunning
if [ "$?" -eq 1 ]; then
        echo Mysql process is Running
else
        echo Mysql process is not Running
        ERRORCOUNT=$((ERRORCOUNT+1))
fi

# If isMysqlListening is true then logWrite Mysql is Listening else logWrite Mysql is not Listening
isMysqlListening
if [ "$?" -eq 1 ]; then
        echo Mysql is Listening
else
        echo Mysql is not Listening
        ERRORCOUNT=$((ERRORCOUNT+1))
fi

#If isMysqlRemoteUp is true then logWrite Remote Mysql TCP port is up else logWrite Remote Mysql TCP port is down
isMysqlRemoteUp
if [ "$?" -eq 1 ]; then
        echo Remote Mysql TCP port is up
else
        echo Remote Mysql TCP port is down
        ERRORCOUNT=$((ERRORCOUNT+1))	
fi


if  [ $ERRORCOUNT -gt 0 ]
then
        echo "There is a problem with Apache or Mysql" | perl sendmail.pl $ADMINISTRATOR $MAILSERVER
fi

#The below Perl mailer utility would be used to email a log of the everything ‘echoed’ above.

#!/usr/bin/perl
# Reference: fslyne 2013
use Net::SMTP;

my $subj="Mailer message - ".convdatetimenow();
my $mailserver='mail1.eircom.net';
my $to=shift @ARGV;
my $from=$to;
my $m = shift @ARGV;
$mailserver=($m) ? $m : $mailserver;

# set up access to mailserver
$smtp = Net::SMTP->new($mailserver);
$smtp->mail($from);
$smtp->to($to);
$smtp->data();
$smtp->datasend("From: $from\n");
$smtp->datasend("To: $to\n");
$smtp->datasend("Subject: $subj\n");
$smtp->datasend("\n");
while(<STDIN>) {
        $smtp->datasend($_);
}
$smtp->dataend();
$smtp->quit;

exit;

sub convdatetimenow {
return convdatetime(time());
}

sub convdatetime {
my $time = shift;
return convdate($time)." ".convtime($time);
}

sub convdate {
my $time = shift;
my ($sec,$min,$hour,$day,$mon,$year,$wday,$yday,$isdst)=localtime($time);
$year = "1900"+$year;
$mon = $mon+1; $mon = "0".$mon if ($mon<10);
$day = "0".$day if ($day<10) ;
return "$year-$mon-$day";
}

sub convtime {
my $time = shift;
my ($sec,$min,$hour,$day,$mon,$year,$wday,$yday,$isdst)=localtime($time);
$hour= "0".$hour if ($hour<10);
$min = "0".$min  if ($min <10);
$sec = "0".$sec  if ($sec <10);
return "$hour:$min:$sec";
}

exit 0


