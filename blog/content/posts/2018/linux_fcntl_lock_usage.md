---
title: "Linux下锁的应用"
date: 2018-07-05T11:24:33Z
draft: false
categories:
    - TECH
    - DEPPER
tags:
    - linux
    - lock
    - ftp
---
[vsftpd]: https://github.com/dagwieers/vsftpd/blob/3.0.2/sysutil.c#L1515-L1534 "vsftpd加锁"
[javalockoutput]: http://hg.openjdk.java.net/jdk8/jdk8/jdk/file/687fd7c7986d/src/share/classes/java/io/FileOutputStream.java "FileOutputStream源代码"
[javalockimpl]: http://hg.openjdk.java.net/jdk8/jdk8/jdk/file/687fd7c7986d/src/share/classes/sun/nio/ch/FileChannelImpl.java#l1005 "FileChannelImpl源代码"
[javalockdis]: http://hg.openjdk.java.net/jdk8/jdk8/jdk/file/687fd7c7986d/src/share/classes/sun/nio/ch/FileDispatcher.java#l43 "FileDispatcher源代码"
[javalockc]: http://hg.openjdk.java.net/jdk8/jdk8/jdk/file/687fd7c7986d/src/solaris/native/sun/nio/ch/FileDispatcherImpl.c#l174 "FileDispatcherImpl Native源码"

# 概述
前不久工作需要实现一个文件转递的应用系统,功能如下:  

* 数据采集方通过ftp上传文件(大小在200KB)
* 转递程序监听ftp的上传文件夹,实时转递文件到大数据平台
* 应用部署在Centos7 64bit

# 第一版实现
采用vsftpd作为ftp服务器, 配置文件夹并共享给转递程序.转递程序使用1个线程轮寻文件夹, 60个转递线程推送  
推送文件到大数据平台.

## 问题
在实际运行中,出现文件解析失败数量随着数据量增大而增多.经过多方排查, 找奥问题处在并发上: 当文件增多,  
ftp服务器写入到硬盘的速度变慢,当转递程序扫描文件夹的时候, 文件虽然已经生成,但文件内容却没有完全写入  
完毕, 从而造成读取到文件但解析失败的情况.

# 探究
那有没有系统锁可以锁住文件, 当文件在被ftp写入的时候,转递程序不去处理这个文件?  
在*Linux*系统下, 有两种锁的机制, 分别是Advisory record Lock和Mandatory lock.  

### Advisory record lock
一种需要资源竞争者约定俗成,使用同一个api去加锁才能达到资源隔离的目的锁机制.  

### Mandatory lock
一种内核保证的所有进程间的强制锁,但目前Linux下很多BUG,而且在4.5以后变成可选的特性.不建议使用.  

那我们有没有办法用这些机制去保证呢?  

## vsftpd
如果想使用Advisory record lock去保证锁的话, 必须修改vsftpd的代码,按照标准api实现加锁.  
硬着头皮去看下源码, 幸好vsftpd作者考虑到了这点, 在写入文件的时候已经加如了锁的处理.  
[具体戳这里][vsftpd]

## Java Advisory record lock
由于转递程序是Java写的, 那怎么使用fcntl呢?难道使用jni吗?会不会太复杂?
首先, 我们了解下Java里面文件锁如何添加:  
```Java
File outFile = new File("/tmp/filelock.tmp");
FileOutputStream outputStream = new FileOutputStream(outFile);
FileChannel channel = outputStream.getChannel();
FileLock lock = channel.lock();
System.out.println("lock success");
lock.release();
channel.close();
outFile.delete();
```
能不能linux下的锁共用呢?也只能先去看下源码了.  
在openjdk8的源码里,先找到*FileOutputStream*的getChannel方法的[代码][javalockoutput](L376-L381)
然后查看*FileChannelImpl*的lock()方法的[代码][javalockimpl](L1005),发现最终使用了FileDispatcher作为
锁管理.查看*FileDispatcher*的[代码][javalockdis](L43),使用了native的方法.最后我们找到文件
*FileDispatcherImpl.c*[代码][javalockc](L174-L210).到此确定了java底层的实现也是使用
Advisory record lock.

## Demo
虽然源码如此,我们还是需要写个c程序确认下
```c
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>

int main() {

  int fd = open("/tmp/filelock.tmp", O_WRONLY);
  if (0 > fd) {
    printf("open file error, %s\n", strerror(errno));
    return errno;
  }
  struct flock the_lock;
  memset(&the_lock, 0, sizeof(struct flock));
  the_lock.l_type = F_WRLCK;
  the_lock.l_whence = SEEK_SET;
  the_lock.l_start = 0;
  the_lock.l_len = 0;

  if (-1 != fcntl(fd, F_SETLKW, &the_lock)) {
    printf("lock success \n");
    sleep(30);
    printf("sleep done\n");

    memset(&the_lock, 0, sizeof(struct flock));
    the_lock.l_type = F_UNLCK;
    the_lock.l_whence = SEEK_SET;
    the_lock.l_start = 0;
    the_lock.l_len = 0;
    if (0 == fcntl(fd, F_SETLKW, &the_lock)) {
      printf("unlock success \n");
    } else {
      printf("unlock error \n");

    }

  } else {
      printf("lock error %s\n", strerror(errno));

  }
  close(fd);
}
```
经过测试确实可以和java的锁达到资源隔离的目的.至此,改造完成.

# 升华
静下来思考,锁其实非常消耗资源,能避免则避免.那这个程序能否用异步的方式去实现呢?
这里提供一种思路:利用ftp服务器的hook机制,转递端改造成服务器的模式,每次上传完成由ftp服务器主动推送
通知转递程序进行文件转递流程.这样既可以减少轮寻的次数,又能缩短文件转递的延迟,何乐而不为呢?
