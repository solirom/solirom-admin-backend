
#!/bin/bash

service_name=solirom-admin-backend
credentials=claudius@85.186.121.41
index_name="citada"

target_dir=/home/claudius/services/$service_name/
current_dir=$(pwd)
echo $current_dir

# stop the service
ssh -t $credentials sudo systemctl stop $service_name

time rsync -P --delete -rsh=ssh $current_dir/../../../../indexes/$index_name $credentials:$target_dir/indexes

# start the service
ssh -t $credentials sudo systemctl start $service_name
