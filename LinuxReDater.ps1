# Set Files
$LogFile = "/var/log/syslog.1"
$NewLogFile = "./NewLog.log"
$NumLines = 0
# Remove the file 
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
	Write-Host "Old message is $line" -foreground yellow
	$NewLogS = "$NewTimeS$var2" 
	Write-Host $NewLogS -foreground green
	Write-Host "time differance is $TimeDiff  `n" -foreground yellow
	Add-Content $NewLogFile $NewLogS
}
}

Write-Host " It took $t1 Total Seconds to process $NumLines Lines"
Write-Host " Input file was $LogFile"
Write-Host " Output file was $NewLogFile"
