#!/bin/bash

if [[ -f "OpenPortDescription.txt" ]]; then
rm OpenPortDescription.txt
fi

for file in $(ls Port*); do
port=$(echo $file | cut -d "-" -f2)
numberOfIPS=$(wc -l $file)
numOnly=$(echo $numberOfIPS | cut -d " " -f1)
random=$(shuf -i 1-$numOnly -n1)
ip=$(head -n $random $file | tail -1 )
echo $ip
nmapoutput="singleip"
finalFile="OpenPortDescription.txt"
nmap -sV -p $port $ip -oG $nmapoutput
cat $nmapoutput
#sleep 10
echo "here"
grep -e open -e closed $nmapoutput >> $finalFile
#rm -f $nmapoutput
done
