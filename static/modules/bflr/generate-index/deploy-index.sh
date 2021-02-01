
#!/bin/bash

service_name=solirom-admin-backend
credentials=claudius@188.212.37.221
index_name="bflr"

target_dir=/home/angel/$service_name/
current_dir=$(pwd)
echo $current_dir

# stop the service
ssh -t $credentials sudo systemctl stop $service_name

# change owner of indexes' folder
ssh -t $credentials sudo chown -R claudius:claudius "$target_dir"indexes 

time rsync -P --delete -rsh=ssh $current_dir/../../../../indexes/$index_name $credentials:$target_dir/indexes

# change owner of indexes' folder
ssh -t $credentials sudo chown -R angel:angel "$target_dir"indexes 

# start the service
ssh -t $credentials sudo systemctl start $service_name
