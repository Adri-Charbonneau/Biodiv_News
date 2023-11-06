# variables
$id = "faunepaca_publication"
$name = "Faune-PACA Publication"
$accounts = "@lpo_paca"
$tags ="#faunepaca #biodiversité #science #nature"

# compare two title
$old = (Select-String -Path "./$id/$id.txt" -Pattern "(.*)").Matches.Groups[1].Value

Invoke-WebRequest -Uri "https://paca.lpo.fr/association-protection-nature-lpo-paca/editions/faune-paca-publication" -OutFile "./$id/$id.html"
  
$Source = Get-Content -path "./$id/$id.html" -raw
$Source -match 'alt="(Faune-PACA Publication n.*?)"'
$new = $matches[1]

$Source -match 'href="\/images\/mediatheque\/fichiers\/section_association\/editions\/faune_paca_publication\/(.*?.pdf)'
$last = $matches[1]

Remove-Item "./$id/$id.html"

if ( $new -eq $old ) {
echo "Le dernier article de $name est déjà existant dans la base de donnée"
} else {
    $new | Out-File "./$id/$id.txt"
    
    $title = $new
    $link = "https://paca.lpo.fr/images/mediatheque/fichiers/section_association/editions/faune_paca_publication/$last"
    ./end_push.ps1
}
