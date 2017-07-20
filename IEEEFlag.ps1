function Send-ToEmail([string]$email, [string]$subject, [string]$body){

    $message = new-object Net.Mail.MailMessage;
    $message.From = $mailfrom;
    $message.To.Add($email);
    $message.Subject = $subject;
    $message.Body = $body;

    $smtp = new-object Net.Mail.SmtpClient($smtserver, $mailport);
    $smtp.EnableSSL = $true;
    $smtp.Credentials = New-Object System.Net.NetworkCredential($Username, $Password);
    $smtp.send($message);
    write-host "Mail Sent" ;
 }


$configfile="c:\ezproxy\psconfig.ini"
#$args[0]

Get-Content $configfile | foreach-object -begin {$h=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { $h.Add($k[0], $k[1]) } }

#variables from ini file
$smtserver = $h.'smtp '
$mailfrom=$h.'fromemail '
$Username =$h.'account '
$Password= $h.'password '
$ezproxypath = $h.'ezproxypath '
$ezproxylogfilepath = $ezproxypath+$h.'ezproxylogfile '
$EzProxyLogFilespath = $h.'ezproxylogfilespath '
$rejectedip = $ezproxypath + $h.rejectedipfile
$shibuser = $ezproxypath + $h.shibuserfile
$IEEEflagtemp = $h.'ezproxyIEEEflagpath '
$IEEFlagstr = $h.IEEEflag
$ezproxyip = $h.'ezproxyip '
$USERsubject=$h.'USERSsubject '
$IPSubject =$h.'IPsubject '
$IPtoEmails=$h.'IPToEmails '
$UserstoEmail=$h.USERSToEmails
$ezproxyservice = $h.'ezproxyservicename '
$ezproxyip=$h.ezproxyip


#Add folder name for current date
#Check to see if Path exists. If not create the new Path

If(!(test-path $IEEEflagtemp))
{
    New-Item -ItemType Directory -Force -Path $IEEEflagtemp
}


#Clear temp folder 
Remove-Item –path ($IEEEflagtemp + "\*.*") –recurse -force

$outfile = $IEEEflagtemp + $h.'tempoutfile '
New-Item $outfile -ItemType File

$txt =  select-string -path $ezproxylogfilepath -Pattern $IEEFlagstr

select-string -path $ezproxylogfilepath -Pattern $IEEFlagstr | select line | out-file $outfile -append


$shibuserdenylist = "USERS:`n"
$rejectediplist = "IP:`n"

$IEEFlags = Get-Content $outfile
$IEEFlags | foreach {
  $test = $_ -split ' '
  #check that flag is none proxyIP

  if($test[0].ToString().Length -gt 5){
      if(-NOT ($test[0].CompareTo($ezproxyip) -eq 0)){
        #Check rejectedip file for IP
        #If not, then add to list
        $temptxt =  select-string -path $rejectedip -Pattern $test[0]
   
        if($temptxt -eq $null){
        #write to rejectedIP file            
            
            Add-Content $rejectedip ("RejectIP " + $test[0])
            $rejectediplist += $test[0] + "`n"
        }

        #Check shib file for user
        #If not, then add to list
        $temptxt =  select-string -path $shibuser -Pattern $test[2]
   
        if($temptxt -eq $null){
        #write to rejectedIP file            
            
            
            Add-Content $shibuser ("If auth:userid eq `"" +  $test[2] + "`"; Deny deny.htm")
            $shibuserdenylist += $test[2] + "`n"
        }
      
  
        }
    }
}


if(-NOT ($shibuserdenylist.CompareTo("USERS:`n") -eq 0)){    

    $emailaddrs  = $UserstoEmail -split ','

    foreach ($element in $emailaddrs) {  
        Send-ToEmail  -email $element -subject $USERsubject -body $shibuserdenylist; 
    }
    stop-service $ezproxyservice –Passthru 
    start-service $ezproxyservice –Passthru 
}

if(-NOT ($rejectediplist.CompareTo("IP:`n") -eq 0)){
    
    $emailaddrs  = $UserstoEmail -split ','

    foreach ($element in $IPtoEmails) {  
        Send-ToEmail  -email $element -subject $IPsubject -body $rejectediplist;
    }

    stop-service $ezproxyservice –Passthru 
    start-service $ezproxyservice –Passthru 
}
