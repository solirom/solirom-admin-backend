
#!/bin/bash

index_name="citada"
current_dir=$(pwd)
echo $current_dir
citations_dir=/home/claudius/workspace/repositories/git/github.com/solirom/citada-data/
output_dir=$current_dir/../../../../tmp/$index_name/generate-index/
json_files_dir=${output_dir}json/
index_path=$current_dir/../../../../indexes/$index_name
xslt_file_path=/home/claudius/workspace/repositories/git/gitlab.com/solirom-citada/admin-site/edit/generate-index/generate-index.xsl

cd $citations_dir
git pull

cd $current_dir

rm -rf "$json_files_dir" $index_path
mkdir -p "$json_files_dir"

# generate the json files for indexes
time java -jar ~/workspace/software/saxon-he/saxon-he.jar -s:"./input/" -xsl:"$xslt_file_path" inputCollection="$citations_dir" -o:"$json_files_dir"

# create the index files
time ~/workspace/repositories/go/bin/bleve create -i scorch $index_path --mapping index.json

#index the json files
~/workspace/repositories/go/bin/bleve index $index_path "$json_files_dir"

# ~/workspace/repositories/go/bin/bleve query ~/workspace/repositories/go/src/solirom.ro/solirom/solirom-admin-backend/indexes/citada/ "a:anapuiulet*"

# curl -v -X POST localhost:7007/api/search/citada -d '{"size": 2000, "from": 0, "query": {"query": "title:etno*"}, "fields": ["collection", "title"]}'
