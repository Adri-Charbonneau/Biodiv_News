# variables
$id = "odf"
$name = "Oiseaux de France"
$accounts = "@biolovision @LPOFrance"
$tags ="#oiseauxdefrance #odf #biodiversity #ornithology #science"

# download json
Invoke-WebRequest -Uri "https://oiseauxdefrance.org/_content/fr/actualites" -OutFile "./$id/$id.json"
$odf = Get-Content "./$id/$id.json" -Encoding UTF8 | ConvertFrom-Json
$date = Get-Date -Format "yyyy-MM-dd"
$testdate = $odf | Where { $_.date -eq "$date" }

if ( $testdate -eq $null ) { 
echo "Pas de nouvel article ce jour pour $name"

} else { 

$title = $testdate.title
$slug = $testdate.slug
$link = "https://oiseauxdefrance.org/news/$slug"

$old = Get-Content "./$id/$id.txt" -Encoding UTF8

if ( $title -eq $old ) {
echo "Le dernier article de $name est déjà existant dans la base de donnée"
} else {
$title | Out-File "./$id/$id.txt"
echo "$title et $link"
#./end_push.ps1
}

}