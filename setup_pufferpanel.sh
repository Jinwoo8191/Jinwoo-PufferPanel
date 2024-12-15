#!/bin/bash

# Colors for messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo -e "${GREEN}Starting full configuration of PufferPanel...${NC}"

# 1. Check if Docker is installed
if ! command -v docker &> /dev/null; then
  echo -e "${YELLOW}Docker is not installed. Installing Docker...${NC}"
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
  rm get-docker.sh
else
  echo -e "${GREEN}Docker is already installed.${NC}"
fi

# 2. Create persistent volumes for configuration and data
echo -e "${YELLOW}Creating volumes for PufferPanel...${NC}"
docker volume create pufferpanel-config
docker volume create pufferpanel-data

# 3. Download and start the PufferPanel container
echo -e "${YELLOW}Starting the PufferPanel container...${NC}"
docker run -d --name pufferpanel \
  -p 8080:8080 \
  -p 5657:5657 \
  -v pufferpanel-config:/etc/pufferpanel \
  -v pufferpanel-data:/var/lib/pufferpanel \
  --restart=on-failure \
  pufferpanel/pufferpanel:latest

# 4. Wait a few seconds for the container to start
echo -e "${YELLOW}Waiting for PufferPanel to initialize...${NC}"
sleep 10

# 5. Check for the existence of config.json
CONFIG_PATH="/workspace/.docker-root/volumes/pufferpanel-config/_data"
if [ ! -f "$CONFIG_PATH/config.json" ]; then
  echo -e "${YELLOW}Creating config.json file...${NC}"
  docker exec -it pufferpanel pufferpanel configure # Generates the initial file in the container
  docker cp pufferpanel:/etc/pufferpanel/config.json "$CONFIG_PATH/config.json"
else
  echo -e "${GREEN}The config.json file already exists.${NC}"
fi

# 6. Ensure the config.json file is correctly placed
echo -e "${YELLOW}Setting correct permissions for config.json...${NC}"
docker exec -it pufferpanel chmod 600 /etc/pufferpanel/config.json
docker exec -it pufferpanel chown -R 1000:1000 /etc/pufferpanel
echo -e "${GREEN}Permissions set.${NC}"

# 7. Restart the container to apply configurations
echo -e "${YELLOW}Restarting PufferPanel to apply configurations...${NC}"
docker restart pufferpanel

# 8. Display access information
echo -e "${GREEN}Installation completed. You can access PufferPanel using:${NC}"
echo -e "${GREEN}http://localhost:8080${NC} (if you are on the same machine)"
echo -e "${GREEN}http://<your-IP>:8080${NC} (from another machine on the network)"

# Creating User
docker exec -it pufferpanel /pufferpanel/pufferpanel user add
