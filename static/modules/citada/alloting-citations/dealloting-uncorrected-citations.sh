
#!/bin/bash

citations_dir=/home/claudius/workspace/repositories/git/github.com/solirom/citada-data/
redactor=$1

# get the number of uncorrected citations
total_citations=$(grep -rl "$redactor" "$citations_dir" | wc -l)
uncorrected_citations=$(grep -rl "$redactor" "$citations_dir" | while read n; do grep -l "elaborated" "$n"; done | wc -l)

# deallocate the uncorrected citations
#grep -rl "$redactor" "$citations_dir" | while read n; do grep -l "elaborated" "$n"; done | xargs sed -i 's/"former-redactor"/"redactor"/g'
grep -rl "$redactor" "$citations_dir" | while read n; do grep -l "elaborated" "$n"; done | xargs sed -i "s/$redactor//g"


# users= cat /home/claudius/workspace/repositories/git/gitlab.com/solirom-citada/admin-site/edit/users.txt
# users=$(cat <<-END
# END
# )

# IFS='
# '
# set -f
# for line in $users; do
#     IFS=" | " read email name affiliation <<< $line
#     echo $email
#     grep -rl "$email" "$citations_dir" | while read n; do grep -l "elaborated" "$n"; done | xargs sed -i 's/"former-redactor"/"redactor"/g'
#     grep -rl "$email" "$citations_dir" | while read n; do grep -l "elaborated" "$n"; done | xargs sed -i "s/$email//g"
#     IFS='
#     '    
# done
# set +f
# unset IFS
