# Script to prepare for vRLI lab03
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

## Process and import the ESXi log 
powershell -f ReDater/ESXiReDater_v04.ps1 MyLogs/ESX55HotDisk.log ./lab03.HotDisk.log
/usr/bin/loginsight-importer --source ./lab03.HotDisk.log --server 10.0.0.29 --honor_timestamp --username admin --password VMware1! --tags "{\"Lab\":\"Lab03a\"}"

## process and import the auth log
powershell -f ReDater/LinuxReDater_v02.ps1 MyLogs/A-SSH_Last_attack_auth.log ./Lab03.Auth.log
/usr/bin/loginsight-importer --source ./Lab03.Auth.log --server 10.0.0.29 --honor_timestamp --username admin --password VMware1! --tags "{\"Lab\":\"Lab03a\"}"

hostname $HN1 

