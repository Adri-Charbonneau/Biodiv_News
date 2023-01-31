# variables
$id = "ar_gaouenn"
$name = "Ar Gaouenn"
$accounts = ""
$tags ="#faune #news #biodiversity #science #nature"

# compare two title
$old = (Select-String -Path "./$id/$id.txt" -Pattern "(.*)").Matches.Groups[1].Value

Invoke-WebRequest -Uri "https://www.lpo.fr/lpo-locales/lpo-bretagne/mediatheque/ar-gaouenn" -OutFile "./$id/$id.html"

$Source = Get-Content -path "./$id/$id.html" -raw
$Source -match '(Ar Gaouenn .*?)<'
$new = $matches[1]
$new = $new -replace 'Â°','°'

$Source -match '(/content/download/.*?)"'
$last = $matches[1]

Remove-Item "./$id/$id.html"

if ( $new -eq $old ) {
echo "Le dernier article de $name est déjà existant dans la base de donnée"
} else {
    $new | Out-File "./$id/$id.txt"
    
    $title = $new
    $link = "https://www.lpo.fr/$last"
    ./end_push.ps1
}
