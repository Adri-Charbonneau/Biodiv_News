# variables
$id = "inpn"
$name = "INPN"
$accounts = "@INPN_MNHN"
$tags ="#inpn #news #biodiversity #science"

# compare two title
[xml]$old_title = Get-Content ./$id/$id.xml -Encoding UTF8
$old = $old_title.rss.channel.item.title[0]

[xml]$new_title = (invoke-webrequest -Uri "https://inpn.mnhn.fr/accueil/actualites/sommaire").Content
$new = $new_title.rss.channel.item.title[0]

if ( $new -eq $old ) {
echo 'Last title already exist'
} else {
Invoke-WebRequest -Uri "https://inpn.mnhn.fr/accueil/actualites/sommaire" -OutFile "./$id/$id.xml"
[xml]$data = Get-Content ./$id/$id.xml -Encoding UTF8

$title = $data.rss.channel.item.title[0]
$link = $data.rss.channel.item.link[0]

./end_push.ps1
}