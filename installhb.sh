set -e

INSTALL_DIR=$HOME/homebridge
DOCKER_VERSION=18.06 # 18.09 has issues on raspberry pi zero

LP="[oznu/homebridge installer]"


echo "$LP Docker Compose Installed"

# Step 3: Create Docker Compose Manifest

mkdir -p $INSTALL_DIR
cd $INSTALL_DIR

echo "$LP Created $INSTALL_DIR"

PGID=$(id -g)
PUID=$(id -u)

cat >$INSTALL_DIR/docker-compose.yml <<EOL
version: '2'
services:
  homebridge:
    image: oznu/homebridge:latest
    restart: always
    network_mode: host
    volumes:
      - ./config:/homebridge
    environment:
      - PGID=$PGID
      - PUID=$PUID
      - HOMEBRIDGE_CONFIG_UI=1
      - HOMEBRIDGE_CONFIG_UI_PORT=8080
EOL

echo "$LP Created $INSTALL_DIR/docker-compose.yml"

# Step 4: Pull Docker Image

echo "$LP Pulling Homebridge Docker image (this may take a few minutes)..."

sudo docker-compose pull

# Step 5: Start Container

echo "$LP Starting Homebridge Docker container..."

sudo docker-compose up -d

# Step 6: Wait for config ui to come up

echo "$LP Waiting for Homebridge to start..."

until $(curl --output /dev/null --silent --head --fail http://localhost:8080); do
  printf '.'
  sleep 5
done

echo

# Step 7: Success

IP=$(hostname -I)

echo "$LP"
echo "$LP Homebridge Installation Complete!"
echo "$LP You can access the Homebridge UI (oznu/homebridge-config-ui-x) via:"
echo "$LP"

for ip in $IP; do
  if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "$LP http://$ip:8080"
  else
    echo "$LP http://[$ip]:8080"
  fi
done

echo "$LP"
echo "$LP Username: admin"
echo "$LP Password: admin"
echo "$LP"
echo "$LP Installed to: $INSTALL_DIR"
echo "$LP Thanks for installing oznu/homebridge!"