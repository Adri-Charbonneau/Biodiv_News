# git and create tag
git config --local user.email "bi.alive@outlook.fr"
git config --local user.name "JACK"
git add .
git commit -m "[Bot] Update $name"
git push -f

# post tweet
## length of tweet
if ( $title.Length -ge 110 )
{ 
$titletweet = $title.Substring(0, 110)
$titletweet = -join($titletweet,"...")
}else{
  $titletweet = $title
}

## replace character
$tmtitle = $title
$tmtitle -replace '&','&amp;'
$tmtitle -replace '<','&lt;'
$tmtitle -replace '>','&gt;'

## post tweet
$twitter = (Select-String -Path "config.txt" -Pattern "twitter=(.*)").Matches.Groups[1].Value
if ( $twitter -eq "y" )
{
Install-Module PSTwitterAPI -Force
Import-Module PSTwitterAPI
$OAuthSettings = @{
ApiKey = "$env:PST_KEY"
ApiSecret = "$env:PST_KEY_SECRET"
AccessToken = "$env:PST_TOKEN"
AccessTokenSecret = "$env:PST_TOKEN_SECRET"
}
Set-TwitterOAuthSettings @OAuthSettings
Send-TwitterStatuses_Update -status "Nouvel article de $name ! $titletweet

Lien : $link
$accounts
$tags
"
}

# send telegram notification
Function Send-Telegram {
Param([Parameter(Mandatory=$true)][String]$Message)
$Telegramtoken = "$env:TELEGRAM"
$Telegramchatid = "$env:CHAT_ID"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Response = Invoke-RestMethod -Uri "https://api.telegram.org/bot$($Telegramtoken)/sendMessage?chat_id=$($Telegramchatid)&text=$($Message)"}

Send-Telegram -Message "Nouvel article de $name : $tmtitle - $link"
