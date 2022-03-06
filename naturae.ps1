# compare two title
[xml]$old_title = Get-Content ./naturae/naturae.xml -Encoding UTF8
$old = echo $old_title.rss.channel.item.title[0].InnerText

[xml]$new_title = (invoke-webrequest -Uri "https://sciencepress.mnhn.fr/fr/periodique/rss/17836/Naturae").Content
$new = echo $new_title.rss.channel.item.title[0].InnerText

if ( $new -eq $old ) {
echo 'Last title already exist'
} else {
Invoke-WebRequest -Uri "https://sciencepress.mnhn.fr/fr/periodique/rss/17836/Naturae" -OutFile "./naturae/naturae.xml"
[xml]$data = Get-Content ./naturae/naturae.xml -Encoding UTF8

$title = echo $data.rss.channel.item.title[0].InnerText
$link = $data.rss.channel.item.link[0]

# git and create tag
git config --local user.email "bi.alive@outlook.fr"
git config --local user.name "JACK"
git add .
git commit -m "[Bot] Update Naturae"
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
Send-TwitterStatuses_Update -status "Nouvel article de Naturae ! $title

Lien : $link
@Le_Museum @Publi_MNHN
#naturae #news #biodiversity #science #museum
"
}

# send telegram notification
Function Send-Telegram {
Param([Parameter(Mandatory=$true)][String]$Message)
$Telegramtoken = "$env:TELEGRAM"
$Telegramchatid = "$env:CHAT_ID"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Response = Invoke-RestMethod -Uri "https://api.telegram.org/bot$($Telegramtoken)/sendMessage?chat_id=$($Telegramchatid)&text=$($Message)"}

Send-Telegram -Message "[BN] Nouvel article de Naturae : $title - $link"
}
