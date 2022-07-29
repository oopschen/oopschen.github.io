---
title: Linux下的Ramdisk使用
tags:
    - linux
    - ramdisk
    - tmpfs
    - ramfs
    - setcap
    - capability
date: '2013-06-04 09:51:35'
draft: false
aliases:
    - article/2013-06-04/linux-ramdisk-usage.html
categories:
    - TECH
---
[redhatbug]: https://bugzilla.redhat.com/show_bug.cgi?id=648653 "Setcap 无法使用在tmpfs文件上bug"

内存技术日益发展的今天,一台电脑随随便便都有8g以上的内存,然后win系统只占了1.5G,linux也就200M,所以大部分的内存资源都是浪费的。因为大部分的软件都考虑了内存不足的情况,会把一些不必要的数据存在硬盘上,而这样小的读写对硬盘的寿命都是有害的,而且容易造成碎片,同时速度也不快。那么我们为什么不把这些临时文件存在内存里呢？这时,linux内核自带的ramdisk就非常好用。  
  
##### 使用
下面我们来看下如何在linux下使用ramdisk：  
```Bash
    mount -t tmpfs -o size=xxm,uid=xx,gid=xx tmpfs /xxx/xx
```
  
我们也可以将其配置在**/etc/fstab**下：  

> tmpfs /xxx/xxx tmpfs defaults,size=xxm,uid=xx,gid=xx 0 2
  
如果想使用ramfs则把上面的tmpfs替换成ramfs
  
##### ramfs和tmpfs区别
<table>
  <tr>
    <td></td>
    <td>Ramfs</td>
    <td>Tmpfs</td>
  </tr>

  <tr>
    <td>内存不是一下子获取,而是慢慢增长</td>
    <td>y</td>
    <td>y</td>
  </tr>

  <tr>
    <td>内存不足</td>
    <td>死机</td>
    <td>使用swap</td>
  </tr>

  <tr>
    <td>内核版本支持</td>
    <td>2.0</td>
    <td>2.4</td>
  </tr>

  <tr>
    <td>参数</td>
    <td>无,只能是root用户使用</td>
    <td>可以控制uid,gid,size,以及挂在的node绑定</td>
  </tr>
</table>
所以建议大家使用tmpfs
  
##### setcap
经在centos 6.4上测试,setcap无法在tmpfs的文件上执行,错误信息是**Operation not support**。查找相关资料后,redhat应该在11年的时候就修复了,不知道为啥centos上还是出问题,具体[bug链接][redhatbug]。同样ramfs也是使用,其他linux发行版未测试。  
  
##### 综述
ramdisk并不是万能的解药,他只适合用于加速磁盘读写频繁的应用,而且断电后ramdisk上的数据全部丢失。所以可以用它来当eclipse或chrome的工作目录。
