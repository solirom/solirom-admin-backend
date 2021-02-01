#!/bin/bash

index_name="citation-corpus"
current_dir=$(pwd)
echo $current_dir
output_dir=$current_dir/../../../../tmp/citada/generate-index/
xml_files_dir=~/workspace/repositories/git/citada-data/
json_files_dir="$output_dir"json

cd $xml_files_dir
git pull

rm -rf "$json_files_dir"
mkdir "$json_files_dir"

time java -jar ~/workspace/repositories/git/solirom-xquery-service/bin/saxon9he.jar -s:"./input/" -xsl:"generate-index.xsl" inputCollection="$xml_files_dir" -o:"$json_files_dir/"

cd "$current_dir"
time for file_name in  "$json_files_dir"/*.json
do
    base_name=$(basename "$file_name" | cut -d. -f1)
    curl -f -X PUT http://188.212.37.221:8095/api/$index_name/$base_name -d @$file_name
done

