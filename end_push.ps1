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


## length of title for Mastodon

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
echo "title_blue = $title_blue"
echo "titletweet = $titletweet"
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

##### LINKEDIN #####
$link_token = "$env:LINKEDIN"

$headers = @{
    "Authorization" = "Bearer $link_token"
    "Content-Type"  = "application/json"
    "X-Restli-Protocol-Version" = "2.0.0"
}

$link_body = @{
    author = "urn:li:company:100237476"
    lifecycleState = "PUBLISHED"
    specificContent = @{
        "com.linkedin.ugc.ShareContent" = @{
            shareCommentary = @{
                text = "[$name] $title
				
$tags"
            }
            shareMediaCategory = "ARTICLE"
            media = @(
                @{
                    status = "READY"
                    description = @{
                        text = "$title"
                    }
                    originalUrl = "$link"
                    title = @{
                        text = "🔗 Lien vers l'article"
                    }
                }
            )
        }
    }
    visibility = @{
        "com.linkedin.ugc.MemberNetworkVisibility" = "PUBLIC"
    }
}

$link_jsonBody = $link_body | ConvertTo-Json -Depth 10 -Compress
Invoke-RestMethod -Uri "https://api.linkedin.com/v2/ugcPosts" -Method Post -Headers $headers -Body ([System.Text.Encoding]::UTF8.GetBytes($link_jsonBody))

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

$post_body = @{
	"collection" = "app.bsky.feed.post"
	"repo" = $did
	"record" = @{
		"text" = "[$name] $title_blue"
		createdAt = (Get-Date).ToString("o") 
        embed = @{
            '$type' = "app.bsky.embed.external"
            external = @{
                uri = "$link"
				title = "🔗 Lien vers l'article"
				description = "$link"
            }
        }
           
    }
} | ConvertTo-Json -Depth 10 

$post_headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json;charset=UTF-8"
}

## Envoi de la requête POST
Invoke-RestMethod -Uri $post_url -Method Post -Headers $post_headers -Body ([System.Text.Encoding]::UTF8.GetBytes($post_body))

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
$data = Invoke-WebRequest -Uri "https://biodivnews.charbonneau.fr/api/v1/links?searchterm=$encodeurl" -Headers $auth_header | ConvertFrom-Json

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
	
	Invoke-RestMethod -Uri "https://biodivnews.charbonneau.fr/api/v1/links" -Method Post -Headers $post_headers -Body ([System.Text.Encoding]::UTF8.GetBytes($post_body))
	
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
	
	Invoke-RestMethod -Uri "https://biodivnews.charbonneau.fr/api/v1/links/$id" -Method Put -Headers $post_headers -Body ([System.Text.Encoding]::UTF8.GetBytes($post_body))
}

##### ARCHIVE.ORG #####
Invoke-WebRequest -Uri "https://web.archive.org/save/$link"
