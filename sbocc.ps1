# variables
$id = "sbocc"
$name = "Société Botanique d'Occitanie"
$accounts = ""
$tags ="#sbocc #botanique #biodiversité #science #nature"

$old = (Select-String -Path "./$id/$id.txt" -Pattern "(.*)").Matches.Groups[1].Value

$carnets = Invoke-WebRequest -Method GET -Uri "https://sbocc.fr/carnets-botaniques/"
$items = $carnets.ParsedHtml.body.getElementsByTagName('div') | Where {$_.getAttributeNode('class').Value -eq 'post-item-description'}

$new_item = $items[0].innerHTML
$new_item -match "<h2><a href=`"(.*?)`">(.*?)</a>"

$title = $matches[2]
$link = $matches[1]

if ( $title -eq $old ) {
echo "Le dernier article de $name est déjà existant dans la base de donnée"
} else {
    $title | Out-File "./$id/$id.txt"
./end_push.ps1
}
