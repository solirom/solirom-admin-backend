
#!/bin/bash

service_name=solirom-admin-backend
credentials=claudius@188.212.37.221
target_dir=/home/angel/$service_name/

# stop the service
ssh -t $credentials sudo systemctl stop $service_name

time rsync -P --delete -rsh=ssh $service_name $credentials:$target_dir

# start the service
ssh -t $credentials sudo systemctl start $service_name
