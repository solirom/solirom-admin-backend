
#!/bin/bash

citations_dir=/home/claudius/workspace/repositories/git/citada-data/

grep -rl "$1" "$citations_dir" | xargs sed -i 's/"redactor"/"former-redactor"/g'
