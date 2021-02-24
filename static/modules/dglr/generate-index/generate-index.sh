
#!/bin/bash

current_dir=$(pwd)
echo $current_dir
repo_name="dglr-data"
site_name="dglr-site"
xml_files_dir="/var/tmp/$repo_name/html/"
index_name="dglr"
json_files_dir="/var/tmp/$repo_name/json"

cd /home/git/solirom/"$repo_name".git/
/usr/bin/git archive --format=tar HEAD | (cd /var/tmp/ && rm -rf "$repo_name" && mkdir "$repo_name" && cd "$repo_name" && tar xf -)

curl -X DELETE http://localhost:8095/api/$index_name
curl -X PUT http://localhost:8095/api/$index_name -d @"/var/web/$site_name/modules/generate-index/index.json"

cd $current_dir
for file_name in  /var/tmp/dglr-data/json/*
do
    echo "Processing $file_name"
    base_name=$(basename "$file_name" | cut -d. -f1)
    echo "$base_name"
    curl -X PUT http://localhost:8095/api/$index_name/$base_name -d @$file_name
done

