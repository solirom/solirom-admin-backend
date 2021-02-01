#!/bin/bash

cd /home/angel/data/citada-data/
git add .
git commit -m "$1 alloted $2 citations"
git push origin master
