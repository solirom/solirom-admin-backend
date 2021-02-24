
#!/bin/bash

index_name="citation-corpus"
current_dir=$(pwd)
echo $current_dir
output_dir=$current_dir/../../../../tmp/citada/alloting-citations/
output_xml_files_dir=${output_dir}xml/
json_files_dir=${output_dir}json/
xml_files_dir=~/workspace/repositories/git/citada-data/
credentials=claudius@188.212.37.221
remote_target_dir=/home/angel/data/citada-data/

cd $xml_files_dir
git pull

cd $current_dir

rm -rf "$output_xml_files_dir" "$json_files_dir"
mkdir -p "$output_xml_files_dir" "$json_files_dir"

# allot the citations
time java -jar ~/workspace/software/saxon-he/saxon-he.jar -s:"./input/" -xsl:"alloting-citations.xsl" redactorId=$1 numberOfEntries=$2 inputCollection="$xml_files_dir" -o:"$output_xml_files_dir"

# generate the index files
time java -jar ~/workspace/software/saxon-he/saxon-he.jar -s:"./input/" -xsl:"../generate-index/generate-index.xsl" inputCollection="$output_xml_files_dir" -o:"$json_files_dir"

# change owner of data folder
ssh -t $credentials sudo chown -R claudius:claudius "$remote_target_dir"

# copy the alloted files
time rsync -P -rsh=ssh $output_xml_files_dir $credentials:$remote_target_dir

# change owner of data folder
ssh -t $credentials sudo chown -R angel:angel "$remote_target_dir"

# git push the changes
ssh -t claudius@188.212.37.221 sudo bash /home/claudius/manual-indexing/citada/git-push.sh "$1 $2"

# generate the index records
cd "$json_files_dir"
for file_name in  *.json
do
    base_name=$(basename "$file_name" | cut -d. -f1)
    curl -f -X PUT https://bleve-explorer.solirom.ro/api/$index_name/$base_name -d @$file_name --fail --silent --show-error
done

# ./alloting-citations.sh "nicoletapinghireac" "120"
