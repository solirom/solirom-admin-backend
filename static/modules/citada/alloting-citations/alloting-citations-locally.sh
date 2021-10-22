
#!/bin/bash

current_dir=$(pwd)
echo $current_dir
output_dir=$current_dir/../../../../tmp/citada/alloting-citations/
output_citations_dir=${output_dir}xml/
citations_dir=/home/claudius/workspace/repositories/git/github.com/solirom/citada-data/

cd $citations_dir
git pull

cd $current_dir

rm -rf "$output_citations_dir"
mkdir -p "$output_citations_dir"

# allot the citations
time java -jar ~/workspace/software/saxon-he/saxon-he.jar -s:"./input/" -xsl:"alloting-citations.xsl" redactorId=$1 numberOfEntries=$2 inputCollection="$citations_dir" -o:"$output_citations_dir"

# copy the alloted files
time rsync -av $output_citations_dir $citations_dir

# git push the changes
cd $citations_dir
git add .
git commit -m "$1 $2"
git push

