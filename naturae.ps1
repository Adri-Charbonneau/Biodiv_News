# variables
$id = "naturae"
$name = "Naturae"
$accounts = "@Le_Museum @Publi_MNHN"
$tags ="#naturae #news #biodiversity #science #museum"

# compare two title
[xml]$old_title = Get-Content ./$id/$id.xml -Encoding UTF8
$old = echo $old_title.rss.channel.item.title[0].InnerText

[xml]$new_title = (invoke-webrequest -Uri "https://sciencepress.mnhn.fr/fr/periodique/rss/17836/Naturae").Content
$new = echo $new_title.rss.channel.item.title[0].InnerText

if ( $new -eq $old ) {
echo 'Last title already exist'
} else {
Invoke-WebRequest -Uri "https://sciencepress.mnhn.fr/fr/periodique/rss/17836/Naturae" -OutFile "./$id/$id.xml"
[xml]$data = Get-Content ./$id/$id.xml -Encoding UTF8

$title = echo $data.rss.channel.item.title[0].InnerText
$link = $data.rss.channel.item.link[0]

./end_push.ps1
}
