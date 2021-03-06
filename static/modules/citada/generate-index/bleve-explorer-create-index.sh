#!/bin/bash

index_name="citation-corpus"
current_dir=$(pwd)
echo $current_dir
output_dir=$current_dir/../../../../tmp/citada/generate-index/
xml_files_dir=~/workspace/repositories/git/citada-data/
json_files_dir="$output_dir"json

cd $xml_files_dir
git pull

cd $current_dir

rm -rf "$json_files_dir"
mkdir "$json_files_dir"

# generate the json files for indexes
time java -jar ~/workspace/software/saxon-he/saxon-he.jar -s:"./input/" -xsl:"/home/claudius/workspace/repositories/git/solirom-admin-site/modules/citations/generate-index/generate-index.xsl" inputCollection="$xml_files_dir" -o:"$json_files_dir/"

curl -X DELETE https://bleve-explorer.solirom.ro/api/$index_name
curl -X PUT https://bleve-explorer.solirom.ro/api/$index_name -d @"index.json"

cd "$current_dir"
time for file_name in "$json_files_dir"/*.json
do
    base_name=$(basename "$file_name" | cut -d. -f1)
    curl -f -X PUT https://bleve-explorer.solirom.ro/api/$index_name/$base_name -d @$file_name
done
