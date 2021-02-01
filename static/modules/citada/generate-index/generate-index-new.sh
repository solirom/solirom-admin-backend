
#!/bin/bash

index_name="citada"
current_dir=$(pwd)
echo $current_dir
output_dir=$current_dir/../../../../tmp/$index_name/generate-index/
xml_files_dir=~/workspace/repositories/git/citada-data/
json_files_dir=${output_dir}json/
index_path=$current_dir/../../../../indexes/$index_name

cd $xml_files_dir
git pull

cd $current_dir

rm -rf "$json_files_dir" $index_path
mkdir -p "$json_files_dir"

# generate the json files for indexes
time java -jar ~/workspace/repositories/git/solirom-xquery-service/bin/saxon9he.jar -s:"./input/" -xsl:"generate-index.xsl" inputCollection="$xml_files_dir" -o:"$json_files_dir"

# create the index files
time ~/workspace/repositories/go/bin/bleve create -i scorch $index_path --mapping index.json

#index the json files
~/workspace/repositories/go/bin/bleve index $index_path "$json_files_dir"

# ~/workspace/repositories/go/bin/bleve query /home/claudius/workspace/repositories/go/src/solirom.ro/solirom/solirom-admin-backend/indexes/citada/ "a:nistor*"

# curl -v -X POST localhost:7007/api/search/citada -d '{"size": 2000, "from": 0, "query": {"query": "title:etno*"}, "fields": ["collection", "title"]}'
