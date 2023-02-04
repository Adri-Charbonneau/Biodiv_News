# variables
$id = "xeno-canto"
$name = "Xeno-Canto"
$accounts = "@xenocanto"
$tags ="#xenocanto #news #biodiversity #science #nature"

# compare two title
$old = (Select-String -Path "./$id/$id.txt" -Pattern "(.*)").Matches.Groups[1].Value

Invoke-WebRequest -Uri "https://xeno-canto.org/collection/spotlights" -OutFile "./$id/$id.html"
  
$Source = Get-Content -path "./$id/$id.html" -raw

$Source -match 'spotlight-([0-9]+)'
$last = $matches[1]

$Source -match "spotlight/$last'>(.*?)</a></h1>"
$new = $matches[1]

$Source -match "a href='https://xeno-canto.org/([0-9]+)"
$sound = $matches[1]

Remove-Item "./$id/$id.html"

if ( $new -eq $old ) {
echo "Le dernier article de $name est déjà existant dans la base de donnée"
} else {
    $new | Out-File "./$id/$id.txt"
    
    $title = $new
    $link = "https://xeno-canto.org/collection/spotlight/$last | Son concerné : https://xeno-canto.org/$sound"
    ./end_push.ps1
}
