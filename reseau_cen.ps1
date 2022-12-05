# variables
$id = "reseau_cen"
$name = "Réseau CEN"
$accounts = "@RESEAU_CEN"
$tags ="#cen #news #biodiversity #science"

# delete some item
[xml]$download = (invoke-webrequest -Uri "https://reseau-cen.org/rss").Content
$first_title = $download.rss.channel.item.title[0]

if ( $first_title -eq "Emplois - services civiques & stages" ) {
	$new_title = $download.rss.channel.item.title[1]
	} else {
	$new_title = $download.rss.channel.item.title[0]
}

# compare two title
[xml]$old_title = Get-Content ./$id/$id.xml -Encoding UTF8
$old = $old_title.rss.channel.item.title[0]

$new = $new_title

if ( $new -eq $old ) {
	echo "Le dernier article de $name est déjà existant dans la base de donnée"
	} else {
	Invoke-WebRequest -Uri "https://reseau-cen.org/rss" -OutFile "./$id/$id.xml"
	[xml]$data = Get-Content ./$id/$id.xml -Encoding UTF8
	
	$title = $data.rss.channel.item.title[0]
	$link = $data.rss.channel.item.link[0]
	
	./end_push.ps1
}
