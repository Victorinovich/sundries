$client = new-object System.Net.WebClient
$client.DownloadFile("https://cdn.zabbix.com/zabbix/binaries/stable/6.0/6.0.4/zabbix_agent-6.0.4-windows-amd64-openssl.msi", "$env:USERPROFILE\Downloads\zabbix_agent-6.0.4-windows-amd64-openssl.msi")

Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main" -Name "DisableFirstRunCustomize" -Value 2

write-host "Vedite imya hosta: "
$hostname=read-host

$MYMSI="$env:USERPROFILE\Downloads\zabbix_agent-6.0.4-windows-amd64-openssl.msi"
$MYARGS="/I $MYMSI /qn SERVER=zabbix1.sys.ilogy.ru SERVERACTIVE=zabbix1.sys.ilogy.ru:57799 HOSTNAME=$hostname"
Start-Process "msiexec.exe" -ArgumentList $MYARGS -wait -nonewwindow
