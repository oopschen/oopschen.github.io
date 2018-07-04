---
title: MQ的尝试 
tags:
    - rabbitMQ
    - activemq
date: '2014-05-15 19:14:32'
draft: false
alias:
    - article/2014-05-15-mq-experiment.html
categories:
    - TECH 
---
  
[rabbitmq]: https://www.rabbitmq.com "RabbitMQ"  
[activemq]: http://activemq.apache.org/ "ActiveMQ"
[msmq]: http://msdn.microsoft.com/en-us/library/ms711472(v=vs.85).aspx "MSMQ"
[zeromq]: http://zeromq.org/ "ZeroMQ"
  
long long ago, 就听说过**Message Queue**(mq), 一直没去尝试, 毕竟用到这种工具的都是分布式的场景了. 这次碰到一个很适合的场景决定适用一把mq.  
  
### 场景  
这次的场景需要由一个总控端将特定的任务分配给执行段, 当执行端完成作业后, 将这个任务从总控端中剔除.这个分配的动作则是由执行端主动去总控端获取.  
所以我把这个场景设计为三个部分:  
1. 总控端, 负责生成任务并插入mq, 并监测mq的长度, 保证适度的长度  
2. 执行端, 负责从mq中获取任务并执行, 当任务失败或者程序崩溃的时候, 刚才获取的任务则重新回归总控端, 交给其他执行端执行, 保证任务一定被完整的执行.  
3. mq, 负责任务必须被一个执行端完整的执行
  
#### 选择MQ  
从google搜索, 可以有很多mq, 比如[RabbitMQ][rabbitMQ], [ActiveMQ][activemq], [MSMQ][msmq], [ZeroMQ][zeromq]等等, 一时间还比较难选择.  
首先可以从google搜索结果的排名上排除几个, 剩下RabbitMQ和ActiveMQ.然后下载build文件的时候, RabbitMQ只要4M左右的大小而ActiveMQ则要40M, 对于没有耐性的我果断选择了RabbitMQ.  
再细看RabbitMQ的文档, 它是用erlang写的--看过一篇文章, 这门语言是Ericsson为了通信行业写的, 所以对于他的可靠性和高效比较认可.最后看看他是不是支持业务场景--RabbitMQ支持message的ack模式, 也就是说receiver可以先获取message, 然后再任务处理完后, 确认这个message被消耗.    
这下完美了, 可以开始动工了.  
  
#### 安装和体验  
对于第一次上手RabbitMQ, 过程还是比较顺利的.在Gentoo和Centos下只需要1分钟的时间就安装完毕了.  
再看配置文件, RabbitMQ的配置文件就是一个erlang的item, 格式如下  
  
    [ {app, {key, value}}, .. ]  
       
RabbitMQ基本不需要过多的配置, 采用默认的也可以, 非常方便.  
  
  
#### 问题  
在开发过程中, 遇到了一个比较蛋疼的问题. RabbitMQ对于链接有一个heartbeat机制, 也就是说, 当接收不到这个heartbeat的时候, 链接就会自动断开, message就重新被分配. 由于任务处理的时候比较长, 所以经常碰到任务处理完后, 链接已经断开, 无法ack这个message.  
而这个heartbeat可以在两个地方设置, 一个是server段的config文件, 一个是client段的参数.经过几次实验后, server段的配置优于client的参数, 也就是说当server配置为30s的时候, client即使配置成31s, 也会被重置为30s.  
  
#### 惊喜  
RabbitMQ还提供了很多plugin, 方便管理和获取更多的特性.这里就尝试了一个管理的plugin, 它自动生成一个webui的界面, 让mq的状态--队列长度, 队列连接数等等的信息一目了然.  
