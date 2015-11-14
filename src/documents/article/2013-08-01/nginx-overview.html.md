---
layout: post
title: Dig Nginx - Nginx 源代码初见
tags: nginx source code overview,源代码,解读
date: '2013-08-02 15:14:19'
udate: '2013-08-02 15:14:19'
category: 技术
---
最近有点时间,看了下nginx源代码,先对这部分内容做点小札记。  
  
#### 观后感 
在没有文档帮助的情况下,我大约花费4天的时间来摸清nginx是怎么工作的(c语言的经验在半年左右)。显然,nginx的源码对于我来说不是那么友好,主要体现在如下方面：   
1.函数的代码长度。在nginx的源代码里,阅读到了800+的一段函数,这情何以堪。   
2.宏名称大小写。因为个人习惯,宏都是大写的,而nginx中有许多宏都是小写。当然其中有些宏在不同的设置下确实是函数,但我以为还是大写比较容易识别。  
3.模块化的全局变量。所谓模块化就是,其实是在编译期间,对全局变量的赋值,包括变量,函数句柄等。而这些变量又是全局的,使得阅读代码的难度增加。  
  
当然,在其中也汲取到了不少东西：    
1. 利用cpu的cache line优化内存访问  
2. 局部内存池  
  
#### 模块化  
nginx的模块化可以说是伪模块化,它不是在运行时期可以添加或删除的模块,而是在编译时期,配置的模块化,当然这也是出于效率考虑。nginx的模块配置由自动生成的*ngx_modules.c*(源代码目录/objs/ngx_modules.c)决定,这个文件主要定义了全局变量*ngx_modules*这个数组。数组的元素是类型为*ngx_module_t*的全局变量。  
ngx_module_t类型包含如下几个元素：  
1. 模块名称  
2. 模块编号  
3. 模块上下文编号  
4. 模块生命周期里所需的函数指针  
5. 模块类型  
6. 模块命令,在文件配置文件解析时,用于设置变量的值  
7. 模块上下文,用于配置和保存worker时期的变量值  
  
#### nginx 初始化  
以下是nginx初始化的内容,略过一些检查变量值的步骤：
1. 初始化cycle。cycle包含整个nginx的配置文件信息。其中包含很多的步骤,包括初始化模块,解析配置文件,处理listen的老端口等等。
2. 根据配置文件fork worker进程,每个worker进程都会有各自的epoll,这和我当时预期的不太一致  
3. 主进程负责响应用户的命令,包括重启,关闭,启动等等  
3. fork 出来的worker进程则开启poll句柄  
4. 将配置文件中的listen的端口加入到poll句柄中轮询  
5. 当监听的端口被访问的时候,就进入了一般的服务器解析的过程,当然在这个过程中,这个worker进程被独占。  
  
#### 具体代码  
说了这些概念性的总结话语,还是来看看代码比较实际,下面的代码追踪是基于linux的epoll配置进行的：  

##### core/nginx.c  
所有一切的开端,这中包含了main函数。其中值得看的是两个函数：  
1. ngx_os_init, 根据不同的cpu初始化cpu cache line的大小
2. ngx_init_cycle, 初始化cycle
最后我们就到了ngx_master_process_cycle, 处理cycle的步骤
  
##### ngx_init_cycle (core/ngx_cycle.c)  
这其中的内容可以大致看过,等到后面的步骤可以细看哪些变量被初始化。  
  
##### ngx_master_process_cycle (os/unix/ngx_process_cycle.c)  
1. ngx_start_worker_processes, 负责fork出worker进程
2. ngx_start_cache_manager_processes, 负责fork出cache进程
  
##### ngx_start_worker_processes (os/unix/ngx_process_cycle.c)    
fork 出worker进程,并把channel的fd写给子进程  
  
##### ngx_worker_process_cycle (os/unix/ngx_process_cycle.c) 
ngx_worker_process_init, 负责worker进程的初始化, 而这个函数中包含对所有模块的init_process的调用,一切模块的功能就从这里开始。  
这里的调用会让ngx_event_core_module开始初始化上下文,也就是对ngx_poll_init的调用。这个函数初始化了全局变量*ngx_io*--负责对socket的io读写,全局变量*ngx_event_actions*--负责事件的处理动作,包括增加/删除事件,启用/消除事件等等, 全局变量*ngx_event_flags*--负责事件的相关标志位。
最后worker进程一直在轮询ngx_process_events_and_timers 函数。  
  
##### ngx_process_events_and_timers (event/ngx_event.c)
1. ngx_trylock_accept_mutex, 将所有listen的端口添加到epoll中  
2. ngx_process_events, 事件处理函数。它是一个宏,内容是ngx_event_ac.process_events, 也就是epoll模块中的ngx_epoll_process_events函数
  
至此,nginx完成整个启动,开始监听配置的端口。  
  
#### 请求操作  
当一个请求被epoll轮询到的时候,他会调用一个connection的read->handler函数,也就是ngx_event_accept函数。  
这个函数调用accept获取相关哦socket,并生成一个connection对象,然后对listening对象的handler进行调用,也就是ngx_http_init_connection。  
而后,并不是http模块对这个request有操作,nginx利用phase机制,让注册phase的模块对请求操作,比如rewrite,access等等。
