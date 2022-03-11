# variables
$id = "ascete"
$name = "Ascete"
$accounts = ""
$tags ="#ascete #news #biodiversity #orthoptere #entomology"

# compare two title
[xml]$old_title = Get-Content ./$id/$id.xml -Encoding UTF8
$old = $old_title.rss.channel.item.title[0]

[xml]$new_title = (invoke-webrequest -Uri "https://ascete.org/feed").Content
$new = $new_title.rss.channel.item.title[0]

if ( $new -eq $old ) {
echo "Le dernier article de $name est déjà existant dans la base de donnée"
} else {
Invoke-WebRequest -Uri "https://ascete.org/feed" -OutFile "./$id/$id.xml"
[xml]$data = Get-Content ./$id/$id.xml -Encoding UTF8

$title = $data.rss.channel.item.title[0]
$link = $data.rss.channel.item.link[0]

./end_push.ps1
}