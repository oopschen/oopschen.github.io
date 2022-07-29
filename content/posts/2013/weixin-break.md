---
title: 微信破解研究总结 
tags: 
    - 微信
    - 破解
    - 微信协议
date: '2013-09-30 19:59:29'
draft: false
aliases:
    - article/2013-09-30/weixin-break.html
categories:
    - TECH 
---
[apk]: https://code.google.com/p/android-apktool/ "APK"
[smali]: https://code.google.com/p/smali/ "Smali"
[dalvikbytecode]: http://source.android.com/devices/tech/dalvik/dalvik-bytecode.html "Dalvik Bytecode Format"
  
  
微信作为腾讯部署移动互联网的棋子,以闪电般的速度占领了市场。而最近,我也经常发现在查看附近的人或者摇一摇的时候会出现一些广告。说实话,这种广告确实比在PC上看到的广告更具真实性,毕竟人就在附近。因此,我萌发了想要偷窥下他协议的冲动。说干咱就干。  
  
#### 理论分析  
首先想到的是抓包对协议分析,显然这是不可取的,一般IM的通信都是加密的,靠猜那是事倍功半的事情。所以,从源代码着手是比较靠谱的事情,眼下微信有两个版本：  
1. android版本  
2. iphone版本  
  
由于iphone平台的不开放性,和java的字节代码的高可读性,最终决定还是选择android平台进行源码分析。  
  
  
#### 实践  
android平台的应用不是java平台的工具能进行反编译的,两者的字节码是截然不同的,vm相差也是十万八千里。所以我们选择[APK][apk]进行反编译,意料之中的是反编译出来的东西是混淆的代码,而我们可以根据每一个按键的文字找到对应的入口。apk反编译采用的是[smali][smali]的机制,我们可以根据[Dalvik的字节码][dalvikbytecode]总结出源代码--基本能和java的源代码相对应。  
  
  
#### 微信客户端的架构  
微信客户端采用的是TCP长连接的模式,而有专属的通信协议,并且这些协议是通过JNI方式用c++代码进行封装,因此想要破解并不容易--看了一天就没什么信心再去看c++的反编译代码了。*libnetwork.so*这个文件主要封装了微信的网络操作--长连接和短链接的创建,dns的查询等等,*libMMProtocalJni.so*这个文件封装了微信的所有通信协议--包括加密和压缩。
而java代码封装了UI和网络适配器,基本流程如下：  
java代码通过适配器,调用jni;而服务端返回的内容,先通过libMMProtocalJni解密,然后回调java进行界面操作
这样的结构,确实增加了破译的难度,除非耐着性子看完**800K+**汇编代码。
  
##### libMMProtocalJni  
通过libMMProtocalJni的反汇编代码,我们可以看到关键字**aes**和**cbc**,我们有理由相信微信的底层加密是用AES的CBC模式加密,至于有多少位和密钥是什么则是封装在libnetwork中。
  
#### 另类的破解  
与其说是一种破解,不如说是模拟,我们可以把破解提到一个更高的语言级别--通过在模拟器模拟java代码从而弄清楚so文件和java之间的通信方式,进而部分破解出微信。当然,想要使用这种方式开发出类似微信群发的工具,需要在破解出so和java之间的调用后,结合使用android模拟器,通过控制jni调用从而控制微信的通信协议, 达到破解微信的目的。这个方式也有弊端,在效率上肯定比不上直接破解so文件的方式。而且当so文件里有控制并发的逻辑,那么效率会更加的低。
