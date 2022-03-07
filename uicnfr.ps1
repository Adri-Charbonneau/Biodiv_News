# compare two title
[xml]$old_title = Get-Content ./uicnfr/uicnfr.xml -Encoding UTF8
$old = $old_title.rss.channel.item.title[0]

[xml]$new_title = (invoke-webrequest -Uri "https://uicn.fr/feed").Content
$new = $new_title.rss.channel.item.title[0]

if ( $new -eq $old ) {
echo 'Last title already exist'
} else {
Invoke-WebRequest -Uri "https://uicn.fr/feed" -OutFile "./uicnfr/uicnfr.xml"
[xml]$data = Get-Content ./uicnfr/uicnfr.xml -Encoding UTF8

$title = $data.rss.channel.item.title[0]
$link = $data.rss.channel.item.link[0]

# git and create tag
git config --local user.email "bi.alive@outlook.fr"
git config --local user.name "JACK"
git add .
git commit -m "[Bot] Update UICN-FR"
git push -f

# post tweet
$twitter = (Select-String -Path config.txt -Pattern "twitter=(.*)").Matches.Groups[1].Value
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
Send-TwitterStatuses_Update -status "Nouvel article de l'UICN France ! $title

Lien : $link
@UICNfrance
#uicn #news #biodiversity #conservation
"
}

# send telegram notification
Function Send-Telegram {
Param([Parameter(Mandatory=$true)][String]$Message)
$Telegramtoken = "$env:TELEGRAM"
$Telegramchatid = "$env:CHAT_ID"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Response = Invoke-RestMethod -Uri "https://api.telegram.org/bot$($Telegramtoken)/sendMessage?chat_id=$($Telegramchatid)&text=$($Message)"}

Send-Telegram -Message "[BN] Nouvel article de l'UICN France : $title - $link"
}
