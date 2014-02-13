sudo ./Script1-PreDeploymentCheckScript 

The script is shown below with comments for each function:

# Level 0 functions <------------

# Returns 1 if the number of processes in param1 is greater than 0
function isRunning {
PROCESS_NUM=$(ps -ef | grep "$1" | grep -v "grep" | wc -l)
if [ $PROCESS_NUM -gt 0 ] ; then
        echo $PROCESS_NUM
        return 1
else
        return 0
fi
}

#Return 1 if the number of TCP ports is greater than 1 for processes in param1 in listen state
function isTCPlisten {
TCPCOUNT=$(netstat -tupln | grep tcp | grep "$1" | wc -l)
if [ $TCPCOUNT -gt 0 ] ; then
        return 1
else
        return 0
fi
}

#Return 1 if the number of UDP ports is greater than 1 for processes in param1 #in listen state
function isUDPlisten {
UDPCOUNT=$(netstat -tupln | grep udp | grep "$1" | wc -l)
if [ $UDPCOUNT -gt 0 ] ; then
        return 1
else
        return 0
fi
}

#Return 1 if the remote TCP port on IP address param1 is open
function isTCPremoteOpen {
timeout 1 bash -c "echo >/dev/tcp/$1/$2" && return 1 ||  return 0
}

#Ping Local IP address
# Returns 1 if a single ping is sent and successful received  to ip address contained in param1
# If isLocalIPalive is true then logWrite Local IP address is alive else logWrite Local IP address is not alive
function isIPalive {
PINGCOUNT=$(ping -c 1 "$1" | grep "1 received" | wc -l)
if [ $PINGCOUNT -gt 0 ] ; then
        return 1
else
        return 0
fi
}

#Return 1 if process in param1 exceeds 50% utilisation

function getCPU {
app_name=$1
cpu_limit="5000"
app_pid=`ps aux | grep $app_name | grep -v grep | awk {'print $2'}`
app_cpu=`ps aux | grep $app_name | grep -v grep | awk {'print $3*100'}`
if [[ $app_cpu -gt $cpu_limit ]]; then
     return 0
else
     return 1
fi
}
The script will return an error count and it will be job of the Administrator to investigate the source of each error and see what can be done to fix the issue.
