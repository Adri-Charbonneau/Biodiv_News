# git and create tag
git config --local user.email "bi.alive@outlook.fr"
git config --local user.name "JACK"
git add .
git commit -m "[Bot] Mise à jour $name"
git push -f

# correct characters
$title = $title -replace '&#233;','é'
$title = $title -replace '&nbsp;',' '
$title = $title -replace '&rsquo;',"'"

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
$tmname = $name
$tmname = $tmname -replace '&','&amp;'

$tmtitle = $title
#$tmtitle = $tmtitle -replace '&nbsp;',' '
$tmtitle = $tmtitle -replace '&','%26'
#$tmtitle = $tmtitle -replace '<','&lt;'
#$tmtitle = $tmtitle -replace '>','&gt;'

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
$tmtext = "Nouvel article de $tmname : $tmtitle - $tmlink"
$tmtoken = "$env:TELEGRAM"
$tmchatid = "$env:CHAT_ID"
Invoke-RestMethod -Uri "https://api.telegram.org/bot$tmtoken/sendMessage?chat_id=$tmchatid&text=$tmtext"

# post mastodon toot
$mastodonheaders = @{Authorization = "Bearer $env:MASTODON"}
$mastodonform = @{status = "Nouvel article de $name ! $titletweet
	
	Lien : $link
	$tags"}
Invoke-WebRequest -Uri "https://piaille.fr/api/v1/statuses" -Headers $mastodonheaders -Method Post -Form $mastodonform
