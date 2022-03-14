# variables
$id = "crbpoinfo"
$name = "CRBPO Info"
$accounts = "@Le_Museum"
$tags ="#crbpo #news #biodiversity #science #ornithology"

# compare two title
[xml]$old_title = Get-Content ./$id/$id.xml -Encoding UTF8
$old = echo $old_title.feed.entry.title[0].InnerText

[xml]$new_title = (invoke-webrequest -Uri "https://crbpoinfo.blogspot.com/feeds/posts/default").Content
$new = echo $new_title.feed.entry.title[0].InnerText

if ( $new -eq $old ) {
echo "Le dernier article de $name est déjà existant dans la base de donnée"
} else {
Invoke-WebRequest -Uri "https://crbpoinfo.blogspot.com/feeds/posts/default" -OutFile "./$id/$id.xml"
[xml]$data = Get-Content ./$id/$id.xml -Encoding UTF8

$title = echo $data.feed.entry.title[0].InnerText
$link = echo $data.feed.entry[0].link |Where-Object {$_.rel -eq 'alternate'} |Select-Object -Expand href

./end_push.ps1
}