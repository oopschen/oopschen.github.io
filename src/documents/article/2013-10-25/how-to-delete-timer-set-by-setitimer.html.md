---
layout: post
title: 在linux下删除setitimer设置的timer
tags: setitimer, linux， timer
date: 2013-10-25 10:27:27
udate: 2013-10-25 10:27:27
category: 技术
---
  
最近的项目需要用一个timer设置超时检测，看了*timer_create*和*setitimer*的文档，选择使用比较简单的setitimer方式进行检测，当然这种方式的可移植性不太好，建议选择timer_create（基于posix标准）方式进行超时设置。后来碰到一个问题：setitimer并没有对应的删除timer的系统调用，而文档也是一句带过：  

> A timer which is set to zero (it_value is zero or the timer expires and  it_interval is zero) stops.  

上面的意思是，当it_value和it_interval的值都为0的时候，计时器自动停止，那没有方法可以手动停止么？带着这个疑问来测试下把：  
  
#### 实验设计  
1. 设定主程序监听alarm信号,打印日志  
2. 开起timer  
3. 设定主程序监听SIGUSR1事件，停止timer
4. 利用{% highlight bash %}kill -SIGUSR1 <pid> {% endhighlight %}方式停止timer  
  
预期：  
主程序停止打印日志
  
#### 1. 设置timer的值为0  
整体代码如下：  

    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <signal.h>
    #include <sys/time.h>
    #include <unistd.h>

    static struct timeval __intrvl;
    static struct timeval __timer_val;
    static struct itimerval __timer;

    void hdl(int sigNum) {
      printf("sig num %d, %ld-%ld, %ld-%ld\n", sigNum, __timer_val.tv_sec, __timer_val.tv_usec, __intrvl.tv_sec, __intrvl.tv_usec);
    }
    void hdl1(int sigNum) {
      __timer.it_value.tv_sec = __timer.it_value.tv_usec = 0;
      __timer.it_interval.tv_sec = __timer.it_interval.tv_usec = 0;
    }

    int main() {
      struct sigaction act, u_act;
      memset(&act, 0, sizeof(act));
      memset(&u_act, 0, sizeof(u_act));
      act.sa_handler = hdl;
      u_act.sa_handler = hdl1;

      if (sigaction(SIGALRM, &act, NULL)) {
        perror("aac");
        return 1;
      }

      if (sigaction(SIGUSR1, &u_act, NULL)) {
        perror("aac u");
        return 1;
      }

      memset(&__timer_val, 0, sizeof(__timer_val));
      memset(&__intrvl, 0, sizeof(__timer_val));
      memset(&__timer, 0, sizeof(__timer));

      __timer_val.tv_sec = __intrvl.tv_sec = 1;
      __timer.it_interval = __intrvl;
      __timer.it_value = __timer_val;

      if (setitimer(ITIMER_REAL, &__timer, NULL)) {
        perror("set timer");
        return 0;
      }

      while(1) {
        sleep(5);
      }
      return 0;
    }

#### 2. 重新设置timer为0的计时器，但timer为新内存地址
    void hdl1(int sigNum) {
      struct itimerval __timer1;
      memset(&__timer1, 0, sizeof(__timer1));
      if (setitimer(ITIMER_REAL, &__timer1, NULL)) {
        perror("set timer");
      }
    }

#### 3.重新设置timer为0的计时器，timer为原来内存地址
    void hdl1(int sigNum) {
      memset(&__timer, 0, sizeof(__timer));
      if (setitimer(ITIMER_REAL, &__timer, NULL)) {
        perror("set timer");
      }
    }
  
#### 实验结果  
1方式无法停止timer，而2,3 方式均可停止timer。这样的实验结果很容易让人联想到是不是这种方式只能有一个timer，而本人进行了2个timer的设置，确实只有一个timer生效,也就是说这种方式的设置timer只能设置一个，而**timer_create**的方式则可以设置多个timer。
