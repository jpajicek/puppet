## Checks whether the Transfer Cleanup script has created a file in C:\Transfer_Cleanup within the last 60 days
## to check if it has run 

$NewestFileDate = (get-date).AddDays(-365)
$NewestFile = "Check didn't work!" 
$NagiosStatus = "2"

ForEach ($Object in get-childitem C:\Transfer_Cleanup){
		
	if  (($Object.creationtime -gt $NewestFileDate) -and ($Object.creationtime -gt $NewestFile.creationtime)){
		$NewestFile = $Object
		if ($Object.creationtime -gt (get-date).AddDays(-62)){
			$NagiosStatus = "0"
		}	
	}	
}

if ($NagiosStatus -eq "0"){
write-host "OK: Script last ran " $NewestFile.creationtime
}
else{
write-host "CRITICAL: Script last ran " $NewestFile.creationtime
}
exit $NagiosStatus