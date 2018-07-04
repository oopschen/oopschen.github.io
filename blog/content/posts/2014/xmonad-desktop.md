---
title: linux xmonad 小试 
tags:
    - xmonad
    - gentoo
    - linuxdesktop
    - tiling
date: 2014-01-21 10:02:11
draft: false
alias:
    - article/2014-01-21/xmonad-desktop.html
categories:
    - 杂谈
---
  
[config]: https://github.com/oopschen/linuxmisc/blob/master/.xmonad/xmonad.hs "默认Xmonad配置"  
  
一直在用xfce和docky构成的类mac os的桌面系统,最近看腻了,换个新鲜的玩玩。不搜不知道,一搜吓一跳,桌面系统已经有很多版本了,比如基于box概念的gnome,kde,xfce,基于tiling概念的xmonad,awesome等。今天我就来玩玩xmonad的桌面。  
  
特点  
====  
这个桌面主要吸引我的地方特点:  

1. 他可以抛弃鼠标操作,完全用键盘操作每个应用的排列和大小  
2. 支持多显示器显示不同的workspace  
3. 占用资源少,稳定,启动快  
  
唯一不足的就是它用的是Haskell的这种函数语言(对笔者来说真TM晦涩),所以我又要多学一门语言么,咋就不用点流行的,python也好啊。  
  
  
快捷键介绍  
====  
<table>
<tr><td> *快捷键* </td><td> *说明* </td></tr>
<tr><td> mod-shift-return </td><td> 打开terminal </td></tr>
<tr><td> mod-space </td><td> 改变窗口的layout </td></tr>
<tr><td> mod-j,mod-k </td><td> 在窗口间切换 </td></tr>
<tr><td> mod-comma,mod-period </td><td> 在一个pane中的窗口数 </td></tr>
<tr><td> mod-h,mod-l </td><td> 改变窗口的宽度 </td></tr>
<tr><td> mod-shift-c </td><td> 关闭窗口 </td></tr>
<tr><td> mod-shift-q </td><td> 退出整个桌面 </td></tr>
<tr><td> mod-1,..,mod-9 </td><td> 在9个workspace之间切换 </td></tr>
</table>
  
更多请查看[这里](http://www.haskell.org/haskellwiki/File:Xmbindings.png "快捷键")
  
  
配置文件  
====  
*~/.xmonad/xmonad.hs*是本地的配置文件,在编辑完后可以用  
```Java
    xmonad --recompile  
```  
    
来确定自己的语法有木有错误。  
  
当编辑haskell文件的时候需要注意的是一个tab==8个空格。默认的Mod键是Alt.附上笔者[默认的配置][config]
  
最终成品  
====  
![桌面截图](<%= @getUrl("/file/desktop.png") %>)
