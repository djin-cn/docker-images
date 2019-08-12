#支持server.properties所有配置, 在配置是需要在配置项最前方添加下划线区分(示例: _broker.id: 1)
#容器运行时默认启动zookeeper, 如果不需要启动zookeeper, 可通过配置(_zookeeper: "false")禁止zookeeper启动
#容器默认设置分区数20, 网络线程数和IO线程数根据CPU数量自动设置
#kafka版本为2.3.0, 系统时区默认为东8区
FROM java:8-alpine
MAINTAINER djin(273218159@qq.com)

ENV GROUP_INITIAL_REBALANCE_DELAY_MS=3 \
    NUM_PARTITIONS=20
COPY docker-entrypoint.sh /

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk --update add --no-cache bash \
    && apk --update add --no-cache --virtual mytools tzdata \
    && cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apk del mytools \
    && ln -s /docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh \
    && mkdir -p /data/logs \
    && chmod +x /usr/local/bin/docker-entrypoint.sh \
    && wget -P /root http://mirror.bit.edu.cn/apache/kafka/2.3.0/kafka_2.12-2.3.0.tgz \
    && tar -zxvf /root/kafka_2.12-2.3.0.tgz -C /root \
    && rm -f /root/kafka_2.12-2.3.0.tgz \
    && sed -i "s#group.initial.rebalance.delay.ms=0#group.initial.rebalance.delay.ms=$GROUP_INITIAL_REBALANCE_DELAY_MS#g" /root/kafka_2.12-2.3.0/config/server.properties \
    && sed -i "s#log.dirs=/tmp/kafka-logs#log.dirs=/data/logs/#g" /root/kafka_2.12-2.3.0/config/server.properties \
    #设置network.threads为CPU核数
    && sed -i 's#num.network.threads=3#num.network.threads='\
#连接上面的命令, 必须顶格开始, 且\连接符前不能有空格
"$(cat /proc/cpuinfo |grep "cores"|uniq|awk '{print $4}')"\
'#g' /root/kafka_2.12-2.3.0/config/server.properties \
    #设置io.threads为CPU线程数
    && sed -i 's#num.io.threads=8#num.io.threads='\
"$(cat /proc/cpuinfo |grep "processor"|wc -l)"\
'#g' /root/kafka_2.12-2.3.0/config/server.properties \
    #设置分区数为20
    && sed -i "s#num.partitions=1#num.partitions=$NUM_PARTITIONS#g" /root/kafka_2.12-2.3.0/config/server.properties \
    && echo 'step finished'

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["sh"]
