# variables
$id = "reseau_cen"
$name = "Réseau CEN"
$accounts = "@RESEAU_CEN"
$tags ="#cen #news #biodiversity #science"

# compare two title
[xml]$old_title = Get-Content ./$id/$id.xml -Encoding UTF8
$old = $old_title.rss.channel.item.title[1]

[xml]$new_title = (invoke-webrequest -Uri "https://reseau-cen.org/rss").Content
$new = $new_title.rss.channel.item.title[1]

if ( $new -eq $old ) {
	echo "Le dernier article de $name est déjà existant dans la base de donnée"
	} else {
	Invoke-WebRequest -Uri "https://reseau-cen.org/rss" -OutFile "./$id/$id.xml"
	[xml]$data = Get-Content ./$id/$id.xml -Encoding UTF8
	
	$title = $data.rss.channel.item.title[1]
	$link = $data.rss.channel.item.link[1]
	
	./end_push.ps1
}
