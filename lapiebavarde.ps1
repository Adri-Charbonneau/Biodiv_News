# variables
$id = "lapiebavarde"
$name = "La Pie Bavarde"
$accounts = ""
$tags ="#lapiebavarde #news #revue #biodiversity #science #environnement"

# compare two title
[xml]$old_title = Get-Content ./$id/$id.xml -Encoding UTF8
$old = echo $old_title.rss.channel.item.title[0].InnerText

[xml]$new_title = (invoke-webrequest -Uri "https://www.la-pie-bavarde.com/blog-feed.xml").Content
$new = echo $new_title.rss.channel.item.title[0].InnerText

if ( $new -eq $old ) {
echo "Le dernier article de $name est déjà existant dans la base de donnée"
} else {
Invoke-WebRequest -Uri "https://www.la-pie-bavarde.com/blog-feed.xml" -OutFile "./$id/$id.xml"
[xml]$data = Get-Content ./$id/$id.xml -Encoding UTF8

$title = echo $data.rss.channel.item.title[0].InnerText
$link = $data.rss.channel.item.link[0]

./end_push.ps1
}
