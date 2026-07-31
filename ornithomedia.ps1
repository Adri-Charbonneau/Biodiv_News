# variables
$id = "ornithomedia"
$name = "Ornithomedia"
$accounts = "@Ornithomedia"
$tags = "#ornithomedia #biodiversité #science #ornithologie #actualité"

function Get-OrnithomediaRSS {
    $uri = "https://www.ornithomedia.com/feed/"
    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession

    # Récupération de la page challenge
    $challenge = Invoke-WebRequest `
        -Uri $uri `
        -WebSession $session

    $html = $challenge.Content

    # Extraction des paramètres du challenge
    $seed = [regex]::Match($html, 'seed\s*=\s*"([^"]+)"').Groups[1].Value
    $complexity = [int][regex]::Match($html, 'complexity\s*=\s*(\d+)').Groups[1].Value
    $ts = [regex]::Match($html, 'ts\s*=\s*(\d+)').Groups[1].Value

    if (!$seed -or !$ts) {
        throw "Impossible de trouver le challenge antibot"
    }

    Write-Host "Challenge détecté"
    Write-Host "Seed       : $seed"
    Write-Host "Complexité : $complexity"
    Write-Host "Timestamp  : $ts"

    # Calcul du nonce Proof-of-Work
    $sha1 = [System.Security.Cryptography.SHA1]::Create()

    $nonce = 0
    $prefix = "0" * $complexity

    while ($true) {
        $bytes = [Text.Encoding]::UTF8.GetBytes("$seed$nonce")
        $hash = $sha1.ComputeHash($bytes)
        $hex = ([BitConverter]::ToString($hash)).Replace("-", "").ToLower()

        if ($hex.StartsWith($prefix)) {
            break
        }
        $nonce++
    }

    Write-Host "Nonce trouvé : $nonce"
    Write-Host "Hash          : $hex"

    # Validation du challenge
    $validateUri = "$uri`?__pow=$nonce&__ts=$ts"

    try {
        Invoke-WebRequest `
            -Uri $validateUri `
            -WebSession $session `
            -MaximumRedirection 0 `
            -ErrorAction Stop | Out-Null

    }
    catch {

        # Le serveur répond normalement par un 302
        if ($_.Exception.Response.StatusCode.value__ -ne 302) {
            throw
        }
    }

    # Vérification du cookie antibot
    $token = $session.Cookies.GetCookies($uri) |
        Where-Object Name -eq "antibot_token"

    if (!$token) {
        throw "Cookie antibot_token absent"
    }

    Write-Host "Cookie antibot validé : $($token.Value)"

    # Récupération du RSS avec le cookie validé
    $rss = Invoke-WebRequest `
        -Uri $uri `
        -WebSession $session

    if ($rss.Headers."Content-Type" -notmatch "xml|rss") {
        Write-Host $rss.Content.Substring(0,300)
        throw "Le serveur n'a pas renvoyé un flux RSS"
    }
    return $rss.Content
}

# Lecture ancien flux
[xml]$old_title = Get-Content "./$id/$id.xml" -Encoding UTF8

$old = $old_title.rss.channel.item.title[0]

# Téléchargement unique du nouveau flux
$rssContent = Get-OrnithomediaRSS

[xml]$new_title = $rssContent

$new = $new_title.rss.channel.item.title[0]

if ($new -eq $old) {

    echo "Le dernier article d'$name' est déjà existant dans la base de donnée"

}
else {

    # Sauvegarde du nouveau flux
    $rssContent | Out-File "./$id/$id.xml" -Encoding UTF8

    [xml]$data = $rssContent

    $title = $data.rss.channel.item.title[0]

    $link = $data.rss.channel.item.link[0]

    ./end_push.ps1
}
