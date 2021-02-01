
#!/bin/bash

current_dir=$(pwd)
echo $current_dir
repo_name="delr-data"
site_name="delr-site"
xml_files_dir="/var/tmp/$repo_name/2/html/"
index_name="delr2"
json_files_dir="$current_dir"/json

cd /home/git/solirom/"$repo_name".git/
/usr/bin/git archive --format=tar HEAD | (cd /var/tmp/ && rm -rf "$repo_name" && mkdir "$repo_name" && cd "$repo_name" && tar xf -)

rm -rf "$json_files_dir"
mkdir "$json_files_dir"
java -jar /var/web/solirom-xquery-service/saxon9he.jar -s:"$xml_files_dir" -xsl:"/var/web/$site_name/modules/generate-index/generate-index.xsl" -o:"$current_dir/json/"
rm -rf /var/tmp/"$repo_name"

curl -X DELETE http://localhost:8095/api/$index_name
curl -X PUT http://localhost:8095/api/$index_name -d @"/var/web/$site_name/modules/generate-index/index.json"
cd "$current_dir"
for file_name in  "$json_files_dir"/*.json
do
    echo "Processing $file_name"
    base_name=$(basename "$file_name" | cut -d. -f1)
    echo "$base_name"
    curl -X PUT http://localhost:8095/api/$index_name/$base_name -d @$file_name
done

