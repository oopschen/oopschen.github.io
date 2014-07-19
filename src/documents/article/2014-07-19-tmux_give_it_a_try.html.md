---
layout: post
title: 尝试Tmux
tags: tmux, linux, terminals
date: 2014-07-19 19:41:48
udate: 2014-07-19 19:41:48
category: 技术
---
[tmuxsite]: http://tmux.sourceforge.net/ "Tmux Website"
  
如果不是无鼠标操作控就可以忽略这篇文章了.很高兴你也是个无鼠标操作控, 今天就来看看[tmux][tmuxsite]的神奇魔力.  
  
### 现状  
在介绍tmux之前,还是先来说说场景--当我们需要开起多个ssh来观察不同服务器的状态的时候,很多个terminal将不得不被打开,如果你是window,那么你要很辛苦的拖动个个框保持满屏,或者也可以使用第三方的tab功能,而如果你是linux,我恐怕你也不得不这么做.当然如果你是利用类似xmonad等的titling的窗口管理器,这也是可以得到解决的.  
目前,本人也是利用xmonad和urxvt来达到这个效果, 使用久了也会觉得这样是如此烦,每次想要在terminal里面干点别的事情就不得不打开新的terminal.  
  
### tmux--爽  
首先, 我们需要确定的事情是tmux不是terminal!!!它只是terminal的管理器,更准确的说是terminal复用器.  
有什么直接的好处呢?Tmux可以帮助我们解决在只打开一个terminal的时候,既可以管理多个ssh,还可以管理多个vi或者top.或许你会问,这个功能通过后台进程不是可以搞定么?回答是是的,但是tmux do better.  
  
### tmux概念  
在使用tmux之前,我们需要理解tmux中的四个概念*client*,*session*,*window*,*pane*.  
  
#### client  
client指的是我们的terminal,也就是能直接和session打交道的部分.  
  
#### session  
session则是进程的集合,也就是我们所说的多个ssh或者vi.  
  
#### window  
window是session的具体展现,可以理解为我们能看到的session.  
  
#### pane  
pane是把window切割成多个部分,也就是说我们可以在一个window中看到多个ssh.  
