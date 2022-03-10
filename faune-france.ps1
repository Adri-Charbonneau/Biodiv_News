# compare two title
$old = (Get-Content ./faune-france/faune-france.json | ConvertFrom-Json).data[0].title

$new = (Invoke-WebRequest "https://www.faune-france.org/index.php?m_id=1351&content=news" | ConvertFrom-Json).data[0].title

if ( $new -eq $old ) {
echo 'Last title already exist'
} else {
Invoke-WebRequest -Uri "https://www.faune-france.org/index.php?m_id=1351&content=news" -OutFile "./faune-france/faune-france.json"

$title = (Get-Content ./faune-france/faune-france.json | ConvertFrom-Json).data[0].title
$nid = (Get-Content ./faune-france/faune-france.json | ConvertFrom-Json).data[0].nid
$link = "https://www.faune-france.org/index.php?m_id=1164&a=$nid#FN$nid"

# git and create tag
git config --local user.email "bi.alive@outlook.fr"
git config --local user.name "JACK"
git add .
git commit -m "[Bot] Update Faune-France"
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
Send-TwitterStatuses_Update -status "Nouvel article de Faune-France ! $title

Lien : $link
@biolovision
#faunefrance #biodiversity #ornithology #science
"
}

# send telegram notification
Function Send-Telegram {
Param([Parameter(Mandatory=$true)][String]$Message)
$Telegramtoken = "$env:TELEGRAM"
$Telegramchatid = "$env:CHAT_ID"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Response = Invoke-RestMethod -Uri "https://api.telegram.org/bot$($Telegramtoken)/sendMessage?chat_id=$($Telegramchatid)&text=$($Message)"}

Send-Telegram -Message "Nouvel article de Faune-France : $title - $link"
}
