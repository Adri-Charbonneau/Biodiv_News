##### GIT #####
git config --local user.email "github-actions[bot]@users.noreply.github.com"
git config --local user.name "github-actions[bot]"
git add .
git commit -m "[Bot] Mise à jour $name"
git push -f

##### CORRECTION #####
## Name
$tmname = $name -replace '&','&amp;'

## Title
$title_html = $title # Telegram
$title = $title -replace "<(.*?)>",""
$title = $title -replace '&#233;','é'
$title = $title -replace '&nbsp;',' '
$title = $title -replace '&rsquo;',"'"

$tmtitle = $title_html
#$tmtitle = $tmtitle -replace '&nbsp;',' '
$tmtitle = $tmtitle -replace '&','%26'
#$tmtitle = $tmtitle -replace '<','&lt;'
#$tmtitle = $tmtitle -replace '>','&gt;'

## length of title for Twitter
if ( $title.Length -ge 110 )
{ 
	$titletweet = $title.Substring(0, 110)
	$titletweet = -join($titletweet,"...")
	}else{
	$titletweet = $title
}

## length of title for Bluesky
if ( ($name.Length + $title.Length + $link.Length + 10) -ge 300 ) #10 = others characters in $text
{ 
	$other_length = 300 - ($name.Length + $link.Length + 10)
	$title_blue = $title.Substring(0, $other_length)
	$title_blue = -join($title_blue,"...")
	}else{
	$title_blue = $title
}

## Link
$link = $link -replace "\/\?utm(.*?)$"

$tmlink = $link
$tmlink = $tmlink -replace '&','%26'

## RESUME
echo "Valeurs de $name :"
echo "------------------"
echo "title = $title"
echo "tmtitle = $tmtitle"
echo "titletweet = $titletweet"
echo "title_blue = $title_blue"
echo "------------------"
echo "link = $link"
echo "tmlink = $tmlink"
echo "------------------"

##### TELEGRAM #####
$tmtext = "[<b>$tmname</b>] $tmtitle
$tmlink"
$tmtoken = "$env:TELEGRAM"
$tmchatid = "$env:CHAT_ID"
Invoke-RestMethod -Uri "https://api.telegram.org/bot$tmtoken/sendMessage?chat_id=$tmchatid&parse_mode=html&text=$tmtext"

##### MASTODON #####
$mastodonheaders = @{Authorization = "Bearer $env:MASTODON"}
$mastodonform = @{status = "[$name] $titletweet
	
Lien : $link
$tags"}
Invoke-WebRequest -Uri "https://piaille.fr/api/v1/statuses" -Headers $mastodonheaders -Method Post -Form $mastodonform

##### TWITTER #####
$twitter = (Select-String -Path "config.txt" -Pattern "twitter=(.*)").Matches.Groups[1].Value
if ( $twitter -eq "y" ) {
	Install-Module PSTwitterAPI -Force
	Import-Module PSTwitterAPI
	$OAuthSettings = @{
		ApiKey = "$env:PST_KEY"
		ApiSecret = "$env:PST_KEY_SECRET"
		AccessToken = "$env:PST_TOKEN"
		AccessTokenSecret = "$env:PST_TOKEN_SECRET"
	}
	Set-TwitterOAuthSettings @OAuthSettings
	Send-TwitterStatuses_Update -status "[$name] $titletweet
	
Lien : $link
$accounts
$tags
"
}

##### BLUESKY #####
$session_url = "https://bsky.social/xrpc/com.atproto.server.createSession"

$session_body = @{
    "identifier" = "$env:BSKY_mail"
    "password" = "$env:BSKY_pass"
} | ConvertTo-Json

$session_headers = @{
    "Content-Type" = "application/json"
}

$session_response = Invoke-RestMethod -Uri $session_url -Method Post -Headers $session_headers -Body $session_body

## Création du message pour l'API
$post_url = "https://bsky.social/xrpc/com.atproto.repo.createRecord"
$token = $session_response.accessJwt
$did = $session_response.did
$text = "[$name] $title_blue

$link"

$start = $text.IndexOf($link)
$end = $start + $link.Length

$post_body = @{
	"collection" = "app.bsky.feed.post"
	"repo" = $did
	"record" = @{
		"text" = "$text"
		"`$type" = "app.bsky.feed.post"
		"createdAt" = Get-Date (Get-Date).ToUniversalTime() -UFormat '+%Y-%m-%dT%H:%M:%S.000Z'
		"facets" = @( 
			@{
				"index" = @{
					"byteStart" = $start
					"byteEnd" = $end
				}
				"features" = @(
					@{
						"`$type" = "app.bsky.richtext.facet#link"
						"uri" = "$link"
					}
				)
			}
		)
	}
} | ConvertTo-Json -Depth 5

$post_headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json;charset=UTF-8"
}

## Envoi de la requête POST
Invoke-RestMethod -Uri $post_url -Method Post -Headers $post_headers -Body ([System.Text.Encoding]::UTF8.GetBytes($post_body))

##### ARCHIVE.ORG #####
Invoke-WebRequest -Uri "https://web.archive.org/save/$link"

##### SITE #####
## Edition des tags
$tags = $tags -replace '#',''
$tags = $tags.Split(' ')

## Fonction de création de token
function Generate-JWT (
[Parameter(Mandatory = $True)]
[ValidateSet("HS256", "HS384", "HS512")]
$Algorithm = $null,
[Parameter(Mandatory = $True)]
$SecretKey = $null
){
	
    $iat = [int][double]::parse((Get-Date -Date $((Get-Date).ToUniversalTime()) -UFormat %s)) # Grab Unix Epoch Timestamp
	
    [hashtable]$header = @{alg = $Algorithm; typ = "JWT"}
    [hashtable]$payload = @{iat = $iat}
	
    $headerjson = $header | ConvertTo-Json -Compress
    $payloadjson = $payload | ConvertTo-Json -Compress
    
    $headerjsonbase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($headerjson)).Split('=')[0].Replace('+', '-').Replace('/', '_')
    $payloadjsonbase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($payloadjson)).Split('=')[0].Replace('+', '-').Replace('/', '_')
	
    $ToBeSigned = $headerjsonbase64 + "." + $payloadjsonbase64
	
    $SigningAlgorithm = switch ($Algorithm) {
        "HS256" {New-Object System.Security.Cryptography.HMACSHA256}
        "HS384" {New-Object System.Security.Cryptography.HMACSHA384}
        "HS512" {New-Object System.Security.Cryptography.HMACSHA512}
	}
	
    $SigningAlgorithm.Key = [System.Text.Encoding]::UTF8.GetBytes($SecretKey)
    $Signature = [Convert]::ToBase64String($SigningAlgorithm.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($ToBeSigned))).Split('=')[0].Replace('+', '-').Replace('/', '_')
    
    $token = "$headerjsonbase64.$payloadjsonbase64.$Signature"
    $token
}

## Génération du token + variable d'authentification
$token = Generate-JWT -Algorithm 'HS512' -SecretKey "$env:BN_API_KEY"
$auth_header = @{Authorization = "Bearer $token"}

## Encodage de l'url + Vérification du lien
$encodeurl = [System.Web.HttpUtility]::UrlEncode($link)
$data = Invoke-WebRequest -Uri "https://biodivnews.ddns.net/api/v1/links?searchterm=$encodeurl" -Headers $auth_header | ConvertFrom-Json

if ([string]::IsNullOrEmpty($data)) {
	# Création du lien car inexistant
    Write-Host "Création du lien car inexistant"
	$post_body = @{
		"url" = "$link"
		"title" = "$title"
		#"description" = ""
		"private" = "false"
		"tags" = @(
			$tags
		)
	} | ConvertTo-Json
	
	$post_headers = @{
		"Authorization" = "Bearer $token"
		"Content-Type" = "application/json;charset=UTF-8"
	}
	
	Invoke-RestMethod -Uri "https://biodivnews.ddns.net/api/v1/links" -Method Post -Headers $post_headers -Body ([System.Text.Encoding]::UTF8.GetBytes($post_body))
	
	} else {
	# Mise à jour des détails du lien car existant
    Write-Host "Mise à jour des détails du lien car existant"
	
	$id = $data.id
	
	$post_body = @{
		"url" = "$link"
		"title" = "$title"
		#"description" = ""
		"private" = "false"
		"tags" = @(
			$tags
		)
	} | ConvertTo-Json
	
	$post_headers = @{
		"Authorization" = "Bearer $token"
		"Content-Type" = "application/json;charset=UTF-8"
	}
	
	Invoke-RestMethod -Uri "https://biodivnews.ddns.net/api/v1/links/$id" -Method Put -Headers $post_headers -Body ([System.Text.Encoding]::UTF8.GetBytes($post_body))
}
