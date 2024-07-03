#!/bin/bash

go mod tidy
go build -o uuidgo uuid.go

echo "
| days | size |
| ---- | ---- |" | tee uuidgo.md

for f in `seq 1 $DAYS`; do

./uuidgo $DAILY

sleep 5

while [ -f data/temp-* ]; do sleep 1; done

echo '|' $f '|' `du -m data | sed 's#data#/1024#' | bc -l` '|'

done | tee -a uuidgo.md
