# DevOps-CI-CD-and-Compose

Project Setup and Deployment Guide


1. Linux System Administration

1.1 Systemd Service for Express.js Backend

To create a systemd service that runs your Express.js backend:
	1.	Create a new service file:

sudo nano /etc/systemd/system/express-server.service


	2.	Add the following content:

[Unit]
Description=Express Web Server
After=network.target

[Service]
ExecStart=/usr/bin/node /home/mustafa/express-server/server.js
Restart=always
User=mustafa
Group=mustafa
Environment=NODE_ENV=production
WorkingDirectory=/home/mustafa/express-server

[Install]
WantedBy=multi-user.target


	3.	Reload systemd, enable, and start the service:

sudo systemctl daemon-reload
sudo systemctl enable express-server
sudo systemctl start express-server


	4.	Check the service status:

sudo systemctl status express-server

1.2 Kernel Tuning

To increase net.core.somaxconn for better network performance:
	1.	Open the sysctl config file:

sudo nano /etc/sysctl.conf


	2.	Add this line:

net.core.somaxconn = 1024


	3.	Apply the changes:

sudo sysctl -p

1.3 Firewall Setup (UFW)

To allow only HTTP (80) and HTTPS (443) traffic and block everything else:

sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw deny incoming
sudo ufw enable

2. Bash Scripting

2.1 Health Check Script

This script checks if the backend is running, restarts it if necessary, and logs the event.
	1.	Create the script:

nano ~/health_check.sh


	2.	Add the following:

#!/bin/bash

SERVICE="express-server"
LOG_FILE="/var/log/express-health.log"

if ! systemctl is-active --quiet $SERVICE; then
    echo "$(date) - $SERVICE was down. Restarting..." | sudo tee -a $LOG_FILE
    sudo systemctl restart $SERVICE
fi


	3.	Give execution permissions:

chmod +x ~/health_check.sh


	4.	Add to cron to run every 5 minutes:

crontab -e

Add this line:

*/5 * * * * ~/health_check.sh

2.2 Log Analysis Script

This script finds the top 3 IP addresses with the most requests.
	1.	Create the script:

nano ~/log_analysis.sh


	2.	Add this:

#!/bin/bash

LOG_FILE="~/webserver.log"

echo "Top 3 IP addresses with the most requests:"
awk '{print $1}' $LOG_FILE | sort | uniq -c | sort -nr | head -3


	3.	Give execution permissions:

chmod +x ~/log_analysis.sh


	4.	Run the script:

~/log_analysis.sh

3. Docker & Docker Compose Setup

3.1 Dockerfile for Backend
	1.	Create a Dockerfile in your backend directory:

FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 5000

CMD ["node", "server.js"]

3.2 Dockerfile for Frontend

If using React.js:

FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

RUN npm run build

FROM nginx:alpine

COPY --from=builder /app/build /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

If using Next.js:

FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

RUN npm run build

FROM nginx:alpine

COPY --from=builder /app/.next /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

3.3 Docker Compose Setup

Create docker-compose.yml in the root of the project:

version: '3.8'

services:
  backend:
    build: ./backend
    ports:
      - "5000:5000"
    environment:
      - NODE_ENV=production
    depends_on:
      - database
    restart: always

  frontend:
    build: ./frontend
    ports:
      - "80:80"
    depends_on:
      - backend
    restart: always

  database:
    image: postgres:15-alpine
    container_name: postgres-db
    restart: always
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
      POSTGRES_DB: mydb
    ports:
      - "5432:5432"
    volumes:
      - pg_data:/var/lib/postgresql/data

volumes:
  pg_data:

3.4 Running the Docker Containers
	1.	Build all images:

docker-compose build --no-cache


	2.	Start all services:

docker-compose up -d


	3.	Check running containers:

docker ps


	4.	View logs:

docker logs <container_id>


	5.	Stop all services:

docker-compose down

4. Troubleshooting

Express.js Service Not Starting?
	•	Check logs:

sudo journalctl -u express-server --no-pager --lines=20


	•	If EADDRINUSE error appears, stop the running process:

sudo lsof -i :3000
sudo kill -9 <PID>



Frontend Not Building?
	•	Make sure React uses build/ and Next.js uses .next/ in the COPY command.

Database Connection Issues?
	•	Make sure the database container is running:

docker ps


	•	Check logs:

docker logs postgres-db

5. Deployment

For deployment:
	•	Use Docker Compose on a cloud server.
	•	Use systemd for backend if deploying without Docker.
	•	Secure the server with UFW and kernel optimizations.
