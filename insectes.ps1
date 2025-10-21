# variables
$id = "insectes"
$name = "Revue Insectes"
$accounts = ""
$tags ="#insectes #opie #biodiversité #science #entomologie"

# compare two title
$old = (Select-String -Path "./$id/$id.txt" -Pattern "(.*)").Matches.Groups[1].Value

$num = [int]$old + 1
$num_url = "insectes_" + $num
$url = "https://www.insectes.org/img/cms/$num_url.pdf"

try {
    $response = Invoke-WebRequest -Uri $url -Method Head -UseBasicParsing -ErrorAction Stop
    
    $num | Out-File "./$id/$id.txt"
    
    $title = "Nouveau numéro de la revue Insectes"
    $link = $url
    ./end_push.ps1

} catch {
    if ($_.Exception.Response.StatusCode.Value__ -eq 404) {
        echo "Le dernier numéro de $name est déjà existant dans la base de donnée"
    }
}