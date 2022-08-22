[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$client = new-object System.Net.WebClient
$client.DownloadFile("https://cdn.zabbix.com/zabbix/binaries/stable/6.2/6.2.1/zabbix_agent-6.2.1-windows-amd64-openssl.msi", "$env:USERPROFILE\Downloads\zabbix_agent-6.2.1-windows-amd64-openssl.msi")
write-host "Введите имя хоста - не обязательно, чтобы оно совпадало с реальным хостнеймом. Это имя используйте при создании узла сети на сервере Zabbix"
$hostname=read-host
$MYMSI="$env:USERPROFILE\Downloads\zabbix_agent-6.2.1-windows-amd64-openssl.msi"
$MYARGS="/I $MYMSI /qn SERVER=zabbix1.sys.ilogy.ru SERVERACTIVE=zabbix1.sys.ilogy.ru:57799 HOSTNAME=$hostname"
Start-Process "msiexec.exe" -ArgumentList $MYARGS -wait -nonewwindow
