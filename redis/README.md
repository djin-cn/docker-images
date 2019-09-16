docker-compose.yml默认有7个实例, redis0为单机实例, redis1-redis6为集群实例.  
redis0可用于日常开发, redis1-redis6可用于实际生产环境.  
redis.conf为集群环境的配置文件, 端口为7000  
redis.sh为在docker swarm环境下使用的命令  

docker-compose为集群实例设置了volumns, 挂载到容器内的/data目录, volumns目录需要事先创建, 当容器宕机后重启数据不会丢失, 且会自动重新连接集群  
docker-compose使用了外部的app网卡, 所以需要事先创建好网卡  
创建app和volumns的命令可在redis.sh找到  
