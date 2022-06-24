$RemotePath = "\\192.168.1.5\smbuser\cryptocurrency\curr\"
$LocalPath = "C:\odb19\DIR_FILES\cryptocurrency\curr\"
$Max_hours = "-23"
$Curr_date = get-date

#Checking date and then copying file from RemotePath to LocalPath
Foreach($file in (Get-ChildItem $RemotePath))
{
    if($file.LastWriteTime -gt ($Curr_date).AddHours($Max_hours))
    {

        Copy-Item -Path $file.fullname -Destination $LocalPath
        #Move-Item -Path $file.fullname -Destination $LocalPath
    }
    ELSE
    {
		#Remove-Item -Path $file.fullname $LocalPath
		Remove-Item -Path C:\odb19\DIR_FILES\curr\curr.json
    }

}