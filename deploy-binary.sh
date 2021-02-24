
#!/bin/bash

service_name=${PWD##*/}

credentials=claudius@85.186.121.41
target_dir=/home/claudius/services/$service_name/

rm ${service_name}
go build -tags netgo -a -v

# stop the service
ssh -t $credentials sudo systemctl stop $service_name

time rsync -P --delete -rsh=ssh $service_name $credentials:$target_dir

# start the service
ssh -t $credentials sudo systemctl start $service_name
