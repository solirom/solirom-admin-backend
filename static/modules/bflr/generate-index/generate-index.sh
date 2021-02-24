
#!/bin/bash

index_name="bflr"
current_dir=$(pwd)
echo $current_dir
output_dir=$current_dir/../../../../tmp/$index_name/generate-index/
xml_files_dir=~/workspace/repositories/git/bflr-data/
json_files_dir=${output_dir}json/
index_path=$current_dir/../../../../indexes/$index_name

cd $xml_files_dir
git pull

cd $current_dir

rm -rf "$json_files_dir" $index_path
mkdir -p "$json_files_dir"

# generate the json files for indexes
time java -jar ~/workspace/software/saxon-he//saxon-he.jar -s:"$xml_files_dir" -xsl:"/home/claudius/workspace/repositories/git/solirom-admin-site/modules/bflr/generate-index/generate-index.xsl" -o:"$json_files_dir"

# create the index files
~/workspace/repositories/go/bin/bleve create -i scorch $index_path --mapping index.json

#index the json files
~/workspace/repositories/go/bin/bleve index $index_path "$json_files_dir"

# curl -v localhost:7007/api/search/bflr -d '{"size": 2000, "from": 0, "query": {"query": "siglum:test*"}, "fields": ["*"]}'
# ~/workspace/repositories/go/bin/bleve query /home/claudius/workspace/repositories/go/src/solirom.ro/solirom/solirom-admin-backend/indexes/bflr/ "siglum:test"
