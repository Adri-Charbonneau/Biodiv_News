# git and create tag
git config --local user.email "bi.alive@outlook.fr"
git config --local user.name "JACK"
git add .
git commit -m "[Bot] Mise à jour $name"
git push -f

# correct characters
$title = $title -replace '&#233;','é'

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
$tmtitle = $tmtitle -replace '&nbsp;',' '
$tmtitle = $tmtitle -replace '&','&amp;'
$tmtitle = $tmtitle -replace '<','&lt;'
$tmtitle = $tmtitle -replace '>','&gt;'

$tmlink = $link
$tmlink = $tmlink -replace '&','%26'

## post twitter tweet
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

Send-Telegram -Message "Nouvel article de $name : $tmtitle - $tmlink"

# post mastodon toot
$Uri = 'https://piaille.fr/api/v1/statuses'
$headers = @{
	Authorization = "Bearer $env:MASTODON"
}
$form = @{
	status = "Nouvel article de $name ! $titletweet
	
	Lien : $link
	$tags"
}
Invoke-WebRequest -Uri $Uri -Headers $headers -Method Post -Form $form
