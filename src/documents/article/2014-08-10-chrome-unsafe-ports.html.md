---
layout: post
title: Chrome Unsafe Port 浅析
tags: chrome, ERR_UNSAFE_PORT, port, security
date: 2014-08-10 09:30:39
udate: 2014-08-10 09:30:39
category: 技术
---
  
[chromesource]: http://src.chromium.org/viewvc/chrome/trunk/src/net/base/net_util.cc?view=markup "Chrome unsafe port source code"  
[wikipagewellknownport]: http://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers "Well Known ports"
  
最近一段时间在和docker愉快的玩耍, 但卡在一个非常奇怪的问题上面--新建了一个container, 基于centos6的image上安装了nginx一个app, 把host的6001端口映射到container的80端口, 把host的6000端口映射到6000端口.  
  
### 问题  
开起这个container后, 在chrome中访问本地6001端口, 可以看到nginx的默认欢迎页面. 而访问6000端口则不能连接--是tcp无法建立连接的那种页面. 这就非常奇怪了.  
用命令查看  
  
    docker port xxx 6000  
    
输出结果是绑定了本地的6000端口没有任何异议.可是为什么无法访问呢?  
  
### 思路  
如此只能用nc工具查看端口是否开起:  
  
    nc -v localhost 6000  
      
端口是有输出的, 这就意味着端口是开启的. 接下来只能看是不是nginx的配置问题了, 当然在部署docker的时候nginx.conf文件是经过**nginx -t**检验的. 这时候就得用curl命令来检验了.  
  
    curl http://localhost:6000  
  
由于nginx的配置了*autoIndex on*, 所以返回的页面中会有文件目录的内容. curl的结果是在预期内的, 也就是说docker的配置和nginx的配置是完全正确的.  
**是什么引发了这个问题?**  
  
### 方案  
由表面证据可以看到, 区别在chrome和curl. 为什么这两个agent会有什么区别? 好吧, 身为一个web开发者, 必须立马打开**chrome://net-internals/#events**页面查看打开6000页面的时候发生了什么问题. 结果是看到了**ERR_UNSAFE_PORT**错误, 而这个错误不会在错误页面出现, 当然console里也看不到. 迅速google了一下, 尼玛这确实是chrome干的好事情, 在[Chromium的源代码][chromesource]中确实内置这么一个功能--屏蔽一些已知的端口.  
**这是为了什么呢?**  
  
### 反思  
经过一系列的搜罗, 网上大致给出的解释是出于安全的考虑. 那到底会有怎么样的安全问题呢?(web开发者要有安全意识啊!!!)  

#### 安全问题例子  
假使我们有一个server listen在6000端口, 并接受request和response的模式, server也在防火墙后. 那么恶意攻击者可以怎么做才能伪造请求攻击server?(这里可以先思考几分钟, 看看有没有黑客的潜质!!!)
|  
|  
|  
|  
|  
|  
|  
|  
|  
|  
|  
好吧谜底揭晓:  
假如有一个pc和server在同一个内网, 恶意攻击者通过建立恶意网站利用javacript调用模拟发送请求到内网的server, 从而达到攻击的目的. 虽然要实施这个步骤需要很多条件, 但是确实是可行的, 因为chrome处于对自身安全的考虑, 建立了一个黑名单列表, 禁止访问这些端口, 这就是上面所述问题的原因.  
  
#### 如何开放这个性质  
chrome作为强大google的产品, 有入口当然会有出口, 既然默认是屏蔽的, 那么必须的可以解除这个屏蔽:  
  
    chorme --explicitly-allowed-ports=port1,port2,port3  
      
### 结论  
虽然无意间踩到这个坑, 也学到了不少. 年轻的chrome在浏览器里是顶尖的. 当然我们web开发者在开发环境做端口选择的时候还是选一些10000以上的端口. 有兴趣的朋友还可以延伸阅读一下[这篇wiki][wikipagewellknownport]. 
