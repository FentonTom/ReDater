## This PowerShell script will replace the dates of an ESXi log file with current dates.
## It extracts the date of the last entry in a file converts it to the current date and time
## and then updates all other dates in the file using that date as an ending point.
## v01 Created by Tom Fenton 1/31/2017
## v02 Updated by 
## to include the following

#Parse paramenters passed to this script or use defaults
 param(
    [string]$LogFile = "./vmkernel.log",
    [string]$NewLogFile = "./ESXiNewLog"
 )
Write-Host " hello world "
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

$DayT = 'yyyy-MM-dd'
$TimeT = 'HH:mm:ss'
$LastRowDayS = $LastDataRow.substring(0,10)
$LastRowTimeS = $LastDataRow.substring(11,8)
$LastRowDayTimeS = "$LastRowDayS $LastRowTimeS"
$LastRowTime = Get-Date -date "$LastRowDayTimeS"

# Compute delta date from file and current time
$DeltaTime = $CurTime - $LastRowTime

Write-Host " last row time is $LastRowTime "
Write-Host " delta time is $DeltaTime "
Write-Host " delta time is $DeltaTimeS "


## Loop through each line in the file and change the time 
$t1 = Measure-Command {
foreach ($line in $content)
{
	$NumLines++ 
	# seperate the time and messages the line in syslog
	# convert the time string to a datetime 
        $RowDayS = $line.substring(0,10)
        $RowTimeS = $line.substring(11,8)
        $var2=$line.substring(24)
        $RowDayTimeS = "$RowDayS $LastRowTimeS"
        $LineTime = Get-Date -date "$RowDayTimeS"

# Compute Delta from last entry in log and current line
	$TimeDiff = $LastRowTime - $LineTime
# Create new date by subtracting delta from line date and newtime
	$NewTime = $CurTime - $TimeDiff
	$NewTimeS = Get-Date($NewTime) -Format "MMM %d %H:%m:%s"
# Write output 
	Write-Host "Old message is $line" -foreground yellow
	$NewLogS = "$NewTimeS$var2" 
	Write-Host "$NewLogS" -foreground green
	Add-Content $NewLogFile $NewLogS
} # end of foreach loop
} # end of time loop

Write-Host " It took $t1 Total Seconds to process $NumLines Lines"
Write-Host " Input file was $LogFile"
Write-Host " Output file was $NewLogFile"
