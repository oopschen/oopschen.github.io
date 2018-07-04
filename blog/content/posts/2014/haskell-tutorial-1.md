---
title: Haskell学习笔记一--Overview
tags:
    - haskell
    - tutorial
date: '2014-01-22 10:23:18'
udate: '2014-01-22 10:23:18'
draft: false
aliases:
    - /article/2014-01-22/haskell-tutorial-1.html
categories:
    - TECH 
---
  
为了能更好的配置xmonad,我还是学点基础的haskell编程,反正技多不压身.有兴趣的朋友和我一起来看看和探讨下这种函数编程语言.  
  
编译器  
====  
GHC是haskell的编译器,自带了一个GHCI--可交互式的命令行,类似python的命令行.如果有需要可以装个有GUI界面的HUGS.  
  
程序结构 
====  
1. module层, 让代码能够被重用  
2. declearation, 对数据类型,数据值的定义  
3. expressions, 表达式  
4. literal, 就是我们写的文本程序  

  
语法  
====    
在阅读BNF规则的时候需要用到下面的规则:  

<table>
<tr><td>[pattern]</td><td>表示可选的内容</td></tr>
<tr><td>{pattern}</td><td> 表示0活多个内容 </td></tr> 
<tr><td>(pattern)</td><td> 表示group,和正则的括号一样</td></tr>  
<tr><td>pat1 | pat2 </td><td>表示可选的</td></tr>
<tr><td>  
  <div class="td11">  
    <span class="cmmi-10">pat</span>  
    <sub>  
      <span class="cmsy-7">⟨</span>  
      <span class="cmmi-7">pat</span>  
      <span class="cmsy-7">′⟩</span>  
    </sub>    
  </div></td>  
  <td>在pat中且不在pat'中内容</td></tr>
<tr><td>pat1 | pat2 </td><td>表示可选的</td></tr>
</table>
    
haskell支持在源代码中写unicode字符.  
  
Reserved word  
=====  
case | class | data | default | deriving | do | else | foreign | if | import | in | infix | infixl | infixr | instance | let | module | newtype | of | then | type | where | \_
  
Identifier  
=====  
除了其他语言中常规的字符,还可以使用单引号当作变量名字.  

newline
=====
这里除了CR,LF,CRLF之外,form feed(12)也是被认可的换行符
  
缩进  
=====  
采用了和python类似的缩进策略, 相等的缩进表示同一层,少缩进表示往上一层,多缩进表示往下一层.

  
Prelude  
=====  
这个文件包含了通用函数的定义
  
和其他程序的区别
=====  
    a := 1  
    print a -- output 1  
    a := 2  
    print a -- output 2

这种语法在haskell里是不存在的, haskell的*=*的意义是定义这个变量为多少值,而不是给个他赋值.下面两种写法的效果是一样的.  
    a := 1  
    print a -- output 1

    print a -- output 1
    a := 1  
  
Haskell金科玉律: 定义一个返回结果的函数,然后给他输入参数  
  
简单函数  
=====  
下面我们来写第一个函数,接受一个整形把它加一返回  

    firstFunc :: Int -> Int  
    firstFunc num = num + 1
  
    
引用  
=====  
    import Data.Map as M
和python的语法差不多
