#!/bin/bash

#修改配置文件 start
config(){
    lockFile="/docker-entrypoint.lock"
    configFile="/root/kafka_2.12-2.3.0/config/server.properties"
    ##bin/sh方式不支持数组, 改用bin/bash方式
    specialVariable=('_zookeeper')
    if [ ! -f "$lockFile" ]; then
        touch $lockFile
        echo "初始化配置文件..."
        echo "" >> $configFile
        for i in $(env); do
            #如果变量不是以_开头, 表示非自定义的配置, 不需要作处理
            if [[ $i != _* ]]; then
                continue
            fi
            #获取配置项键, 语法:%%表示逆向最大匹配,=*表示以等号开始的字符
            key=${i%%=*}
            if [ $key == '_' ]; then
                continue
            fi
            #如果是特定的配置则不作处理
            if echo "${specialVariable[@]}" | grep -w "$key" &>/dev/null; then
                continue
            fi
            #截取字符串, 从第二个字符开始到结束; 第一个字符下划线, 用于区分是否自定义配置
            key=${key:1}
            #获取配置项值, 语法:#表示正向最小匹配,*=表示以等号结束的字符
            value=${i#*=}
            sed -i "s@^$key=@#$key=@g" $configFile
            echo "$key=$value" >> $configFile
        done
    fi
}
config
#修改配置文件 end

if [ ${_zookeeper:-true} != "false" ]; then
    echo "启动zookeeper..."
    /root/kafka_2.12-2.3.0/bin/zookeeper-server-start.sh -daemon /root/kafka_2.12-2.3.0/config/zookeeper.properties
fi
echo "启动kafka..."
/root/kafka_2.12-2.3.0/bin/kafka-server-start.sh /root/kafka_2.12-2.3.0/config/server.properties 1>/dev/stdout 2>&1
#nohup /root/kafka_2.12-2.3.0/bin/kafka-server-start.sh /root/kafka_2.12-2.3.0/config/server.properties 1>/dev/stdout 2>&1 &
exec "$@"

#常用命令
#创建主题
#/root/kafka_2.12-2.3.0/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic test
#查看主题
#/root/kafka_2.12-2.3.0/bin/kafka-topics.sh --list --zookeeper localhost:2181
#生产消息
#/root/kafka_2.12-2.3.0/bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test
#消费消息
#/root/kafka_2.12-2.3.0/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --from-beginning
#压测生产消息, 本示例表示每秒10W条消息, 共产生100W条消息, 每条消息2K字节, 消息主题test;
#结果分析: {生产消息数量} records sent, {每秒消息数量} records/sec (70.72 MB/sec), {平均延迟} ms avg latency, {最大延迟} ms max latency, 420 ms 50th, 556 ms 95th, 621 ms 99th, 640 ms 99.9th.
#/root/kafka_2.12-2.3.0/bin/kafka-producer-perf-test.sh --topic test --num-records 1000000 --record-size 2000 --throughput 100000 --producer-props bootstrap.servers=localhost:9092
#压测消费消息, 本示例表示消费100W条消息, 每次获取数据量1048576字节(即1M), 线程数10条 消息主题test
#结果分析: data.consumed.in.MB(消费总数据量,单位M), MB.sec(每秒数据量, 单位M), data.consumed.in.nMsg(消费消息数量,单位条), nMsg.sec(每秒消费消息数量, 单位条)
#/root/kafka_2.12-2.3.0/bin/kafka-consumer-perf-test.sh --broker-list localhost:9092 --topic test --fetch-size 1048576 --messages 10000000 --threads 10
#查看topic分布详情
#/root/kafka_2.12-2.3.0/bin/kafka-topics.sh --describe  --zookeeper localhost:2181 --topic test
