# variables
$id = "antarea"
$name = "AntArea"
$accounts = ""
$tags ="#antarea #news #biodiversity #science #fourmis"

# compare two title
[xml]$old_title = Get-Content ./$id/$id.xml -Encoding UTF8
$old = $old_title.rss.channel.item.title[0]

[xml]$new_title = (invoke-webrequest -Uri "https://antarea.fr/wp/feed/").Content
$new = $new_title.rss.channel.item.title[0]

if ( $new -eq $old ) {
echo 'Last title already exist'
} else {
Invoke-WebRequest -Uri "https://antarea.fr/wp/feed/" -OutFile "./$id/$id.xml"
[xml]$data = Get-Content ./$id/$id.xml -Encoding UTF8

$title = $data.rss.channel.item.title[0]
$link = $data.rss.channel.item.link[0]

./end_push.ps1
}
