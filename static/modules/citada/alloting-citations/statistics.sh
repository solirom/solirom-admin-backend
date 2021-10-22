
#!/bin/bash

citations_dir=/home/claudius/workspace/repositories/git/github.com/solirom/citada-data/
redactor=$1

# get the number of uncorrected citations
total_citations=$(grep -rl "$redactor" "$citations_dir" | wc -l)
uncorrected_citations=$(grep -rl "$redactor" "$citations_dir" | while read n; do grep -l "elaborated" "$n"; done | wc -l)
#available_citations=$(grep -rl 'elaborated' "$citations_dir" | while read n; do grep -l '<editor role="redactor">' "$n"; done)

echo "total citations = $total_citations"
echo "corrected citations = $(($total_citations - $uncorrected_citations))"
echo "uncorrected citations = $uncorrected_citations"
#echo "available citations = $available_citations"
