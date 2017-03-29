# Script to prepare for vRLI lab05
## v02 Create 3/1/2017 by Tom Fenton
## v01 Create 3/1/2017 by Tom Fenton

## This script does the following:
## Stores the current hostname in $HN1
## Changes the hostname as the vRLI import tool reads uses it when it tags the files
## Redates the the log files to the current date and time (powershell script)
## Imports the file the file tagging it with Lab Lab03
## Restores the hostname to the orginal hostname

HN1=`hostname`
hostname Ubuntu03
echo $HN1
powershell -f ReDater/ESXiReDater_v04.ps1 MyLogs/Lab05b.log MyLogs/NewLab05b.log
/usr/bin/loginsight-importer --source MyLogs/NewLab05b.log --server 10.0.0.29 --honor_timestamp --username admin --password VMware1! --tags "{\"Lab\":\"Lab05a\"}"
hostname $HN1 
