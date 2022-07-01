# variables
$id = "plumedenaturaliste"
$name = "Plume de Naturaliste"
$accounts = ""
$tags ="#plumedenaturaliste #news #biodiversity #science #nature"

# compare two title
$old = (Select-String -Path "./$id/$id.txt" -Pattern "(.*)").Matches.Groups[1].Value

Invoke-WebRequest -Uri "http://www.plume-de-naturalistes.fr/index.php/numeros/articles-et-essais/" -OutFile "./$id/$id.html"
$did = Get-ChildItem "./$id/$id.html" -Recurse `
  | Get-Content `
  | Select-String -Pattern 'download_id\=([0-9]+)' -AllMatches `
  | % { $_.Matches } `
  | % { $_.Value } `
  | Sort-Object `
  | Get-Unique
  
$last = $did[-1]
$text = select-string -path "./$id/$id.html" -Pattern "$last" | select line
$text = $text.line
$text = $text -replace '<[^>]+>',''
$text = $text -replace '^[0-9]+\)',''
$text = $text -replace '&#8211;','-'
$new = $text

Remove-Item "./$id/$id.html"

if ( $new -eq $old ) {
echo "Le dernier article de $name est déjà existant dans la base de donnée"
} else {
    $new | Out-File "./$id/$id.txt"

$title = $new
$link = "http://www.plume-de-naturalistes.fr/?smd_process_download=1&$last"

./end_push.ps1
}
