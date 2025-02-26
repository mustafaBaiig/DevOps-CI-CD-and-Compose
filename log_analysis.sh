#!/bin/bash

LOGFILE="$HOME/webserver.log"

echo "Top 3 IP addresses with the most requests:"
awk '{print $1}' $LOGFILE | sort | uniq -c | sort -nr | head -3
