---
layout: post
title: 我们为什么要选择DNS服务器
tags: DNS,加快上网速度,钓鱼,安全,翻墙
date: 2013-06-06 08:46:56
udate: 2013-06-06 08:46:56
category: 技术
---
[baiduurl]: http://www.baidu.com, "百度"
[114url]: http://safe.114dns.com/index.html, "114DNS服务器"

DNS?所谓DNS,是将人类可理解的网络地址转化成计算机可理解的网络地址的协议。一般上网用户不会注意到DNS,因为当我们接入运营商(电信,联通,铁通,移动等)的时候,他们会默认给我们一个DNS服务器地址。电信的默认的DNS服务器还算过的去,但是其他的就不敢恭维了,所以我们需要更好的DNS服务器地址。  

#### 为什么
我们为什么需要选择DNS服务器？开头我们介绍了DNS的功能,具体到实际,我们用以下例子解释DNS到底帮我们干了什么。  
1. 当我们在浏览器输入[www.baidu.com][baiduurl]的时候,浏览器首先会根据**www\.baidu\.com**这个域名去DNS服务器查询他的ip地址,然后和这个ip地址进行通信
2. 当我们打不开国内网页的时候,很大一部分可能是域名无法被解析,也就是找不到1中的ip地址,无法通信
  
所以DNS服务器是多么的重要,当然如果DNS被攻陷,也就是说原本www\.baidu\.com对应的ip地址是115\.239\.210\.26,而攻陷后它对应的ip地址是1\.0\.0\.1,那么你所有看似对www\.baidu\.com的操作实际上都是在别人的服务器上进行。更甚者,当你进行账户操作的时候,你的私人信息包括密码,帐号等等都会被盗。  
  
#### 推荐的DNS
由此看来,我们很有必要选择一个安全,可靠,快速的DNS服务器。以前,博主喜欢用Google的服务器

> 8\.8\.8\.8  
> 8\.8\.4\.4  

然后,他毕竟不是本土企业,所有的域名解析都是以加快美国本土为目的,结果就是国内访问新浪都很慢。这样不是得不偿失么。  
幸好博主发现了[114DNS][114url]  

> 114\.114\.114\.114  
> 114\.114\.115\.115  

用了半年,速度是刚刚的,而且上google被墙的次数也比较少。 而且114DNS还提供了许多人性化服务,比如他有专门放病毒网站的DNS服务器地址,有防色情的DNS服务器地址,用来保护孩子也是不错的选择。  
  
#### 测试对比
1. 测试平台： debian6 64bit
2. 网络服务商： 电信
3. 带宽： 6M 
  
##### 114 DNS访问
命令
    dig @114.114.114.114 www.baidu.com  
结果  
> ; <<>> DiG 9.7.3 <<>> @114.114.114.114 www.baidu.com  
> ; (1 server found)  
> ;; global options: +cmd  
> ;; Got answer:  
> ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 30652  
> ;; flags: qr rd ra; QUERY: 1, ANSWER: 3, AUTHORITY: 0, ADDITIONAL: 0  
>   
> ;; QUESTION SECTION:  
> ;www.baidu.com.			IN	A  
>   
> ;; ANSWER SECTION:  
> www.baidu.com.		995	IN	CNAME	www.a.shifen.com.  
> www.a.shifen.com.	81	IN	A	115.239.210.27  
> www.a.shifen.com.	81	IN	A	115.239.210.26  
>   
> ;; Query time: 19 msec  
> ;; SERVER: 114.114.114.114#53(114.114.114.114)  
> ;; WHEN: Wed Jun  5 19:16:17 2013  
> ;; MSG SIZE  rcvd: 90  
  
##### Google DNS访问
命令

    dig @8.8.8.8 www.baidu.com  

结果  

> ; <<>> DiG 9.7.3 <<>> @8.8.8.8 www.baidu.com  
> ; (1 server found)  
> ;; global options: +cmd  
> ;; Got answer:  
> ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 11906  
> ;; flags: qr rd ra; QUERY: 1, ANSWER: 3, AUTHORITY: 0, ADDITIONAL: 0  
>   
> ;; QUESTION SECTION:  
> ;www.baidu.com.			IN	A  
>   
> ;; ANSWER SECTION:  
> www.baidu.com.		1041	IN	CNAME	www.a.shifen.com.  
> www.a.shifen.com.	141	IN	A	220.181.112.143  
> www.a.shifen.com.	141	IN	A	220.181.111.148  
>   
> ;; Query time: 50 msec  
> ;; SERVER: 8.8.8.8#53(8.8.8.8)  
> ;; WHEN: Wed Jun  5 19:17:47 2013  
> ;; MSG SIZE  rcvd: 90  
  
从上面的*Query time*看出,我们就节省了31毫秒。
  
#### 如何设置
##### linux
在**/etc/resolv.conf**加入下面的代码

> nameserver 114.114.114.114  
> nameserver 114.114.115.115  

##### win7
在当前网卡的属性选项卡中选择ipv4,填入dns服务器地址。当然,如果家里有路由器的话,直接在路由器管理页面里的DHCP设置里面设置DNS服务器即可。
  
#### 综述
看了这么多,我们还有什么理由不设置自己的DNS服务器,好处很多：
1. 加快上网速度
2. 保护网站安全不被钓鱼
3. 不会打不开网页
