#!/bin/bash

SERVICE="express-server"
LOGFILE="/var/log/express-health.log"

# Check if the service is running
if ! systemctl is-active --quiet $SERVICE; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $SERVICE was down. Restarting..." | tee -a $LOGFILE
    sudo systemctl restart $SERVICE
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $SERVICE is running fine." | tee -a $LOGFILE
fi
