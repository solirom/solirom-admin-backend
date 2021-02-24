
#!/bin/bash

index_name="citation-corpus"
current_dir=$(pwd)
echo $current_dir
output_dir=$current_dir/../../../../tmp/citada/refactor-editor/
xml_files_dir=${output_dir}xml/

rm -rf "$xml_files_dir"
mkdir -p "$xml_files_dir"

# refactor the citations
time java -jar ~/workspace/software/saxon-he/saxon-he.jar -s:"./input/" -xsl:"refactor-editor.xsl" -o:"$xml_files_dir"



