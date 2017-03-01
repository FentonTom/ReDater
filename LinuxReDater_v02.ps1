[CmdletBinding()]
## To print verbose out use -Verbose on command line
## This PowerShell script will replace the dates of a Linux log file with current dates
## It extracts the date of the last entry in a file converts it to the current date and time
## and then updates all other dates in the file using that date as an ending point.
## v01 Created by Tom Fenton 1/31/2017
## v02 Updated by 
## to include the following

#Parse paramenters passed to this script or use defaults
 param(
    [string]$LogFile = "./auth01.log",
    [string]$NewLogFile = "./ReAuth.log"
 )
Write-Host " Log file to be read is $LogFile " -Foreground Green
Write-Host " Log file to be written is $NewLogFile " -Foreground Green

$CheckFile = Test-Path $LogFile -PathType Leaf
if ($CheckFile)
{
        Write-Host "File exist $Logfile"
} else
{
        Write-Host "File does not exist $Logfile"
        exit
}

Write-Host " Log file to be read is $LogFile " -Foreground Green
Write-Host " Log file to be written is $NewLogFile " -Foreground Green
$NumLines = 0
# Remove the old ne log file if needed
If (Test-Path $NewLogFile)
{
        Remove-Item $NewLogFile
}

$content = Get-Content $LogFile
$DTemplate = 'MMM d H:m:s'
# store the current time
$CurTime = Get-Date
$CurTimeS = Get-Date -Format "MMM %d %H:%m:%s"
# Get last line in file and extract date 
$LastDataRow = (Get-Content $LogFile -Last 1)
$LastRowTimeS = $LastDataRow.substring(0,15)
$LastRowTime = [datetime]::parseExact($LastRowTimeS, $DTemplate, $null)
# Compute delta date from file and current time
$DeltaTime = $CurTime - $LastRowTime

## Loop through each line in the file and change the time 
$t1 = Measure-Command {
foreach ($line in $content)
{
	$NumLines++ 
	# seperate the time and messages the line in syslog
	$var1=$line.substring(0,15)
	$var2=$line.substring(15)
	# convert the time string to a datetime 
	$LineTimeS = [datetime]::parseExact($var1, $DTemplate, $null)
	$LineTime = Get-Date -date "$LineTimeS"
# Compute Delta from last entry in log and current line
	$TimeDiff = $LastRowTime - $LineTime
# 	$TimeDiffS = Get-Date($TimeDiff) -Format "MMM %d %H:%m:%s"
# Create new date by subtracting delta from line date and newtime
	$NewTime = $CurTime - $TimeDiff
	$NewTimeS = Get-Date($NewTime) -Format "MMM %d %H:%m:%s"
# Write output 
  	Write-Verbose "Old message is $line" 
	$NewLogS = "$NewTimeS$var2" 
  	Write-Verbose $NewLogS 
  	Write-Verbose "time differance is $TimeDiff  `n" 
  	Write-Host "." -NoNewLine -foreground green
	Add-Content $NewLogFile $NewLogS
}
}

Write-Host " "
Write-Host "It took $t1 Total Seconds to process $NumLines Lines"
Write-Host "Input file was $LogFile"
Write-Host "Output file was $NewLogFile"
