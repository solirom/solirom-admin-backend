
#!/bin/bash

citations_dir=/home/claudius/workspace/repositories/git/github.com/solirom/citada-data/
users=$(cat /home/claudius/workspace/repositories/git/gitlab.com/solirom-citada/admin-site/edit/users.txt)

IFS='
'
set -f
for line in $users; do
    IFS=" | " read email name affiliation <<< $line
    echo $email
    grep -rl "$email" "$citations_dir" | while read n; do grep -l "corrected" "$n"; done | xargs sed -i 's/"redactor"/"former-redactor"/g'
    IFS='
    '    
done
set +f
unset IFS
