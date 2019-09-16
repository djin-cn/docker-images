#!/bin/sh

rm -rf redis{1..6} && \
mkdir redis{1..6}
#docker network create --attachable -d overlay --subnet 172.19.0.0/24 app
#docker run -dit -p 6379:6379 --name redis redis:5.0-alpine
docker stack deploy -c docker-compose.yml redis

docker run -it --rm --network app redis:5.0-alpine redis-cli --cluster create --cluster-replicas 1 \
$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker ps | grep redis1 | awk '{print $1}')):7000 \
$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker ps | grep redis2 | awk '{print $1}')):7000 \
$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker ps | grep redis3 | awk '{print $1}')):7000 \
$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker ps | grep redis4 | awk '{print $1}')):7000 \
$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker ps | grep redis5 | awk '{print $1}')):7000 \
$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker ps | grep redis6 | awk '{print $1}')):7000
