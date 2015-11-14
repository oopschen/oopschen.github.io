---
layout: post
title: Haskell学习笔记二--理解Haskell的思路
tags: Haskell, how to work
date: '2014-01-23 17:18:00'
udate: '2014-01-23 17:18:00'
category: 技术
---
  
想要使用好一门语言, 必须先掌握他的核心思想. 对于熟悉C语言的程序员来说, 过程就是一切, 而对熟悉java语言的程序员来说对象就是一切, 那么Haskell又如何?先给大家打一支止痛针, 因为看得真的头痛.  
  
金科玉律  
===  
  
> It is often easier to code the general definition for something than to write a function that generates a specific value  
          
也就是说定义事情的特性远比实现他做什么容易么?  
  
  
有趣的例子  
===  
我们先来看一段代码

    myList :: [Int]  
    myList = 0 : 1 : [ a * b | (a, b) <- zip myList (tail myList)]
  
初看过去,这段代码究竟干了什么事情.是定义了一个函数?是定义了一个列表?还是定义了一个货?在解析这段代码之前先来补点基础知识.  
  
*:*符号在haskell中代码数组的连接符  

    1 : [2] -- output [1, 2]

  
*|*符号在haskell中代表输入,也就是说\|右边的值当作左边表达式的输入  
*<-*表示把右边的值依次赋值给左边  
  
*zip*是haskell定义的一个函数  

    zip [1,2] [3,4] -- ouput [(1,3), (2,4)]
    zip [1] [3,4] -- ouput [(1,3)]

*tail*同样也是haskell定义的一个函数  

    tail [1] -- ouput []
    tail [1,2] -- ouput [2]
    tail [1,2,3] -- ouput [2,3]
  
有了这些基本概念, 我们再来看上面的例子.第一行代码很好理解,我们声明*myList*是一个数组,数组里的元素是整型.问题是后面这段代码是个啥玩意.我们从左到右逐一拆解来看.    

    myList = 0 : 1 : [...]  

这段代码给myList赋值为一个数组, 第一个和第二个元素分别为0和1  

    [a * b |]  

这个也很好理解, 数组里的元素是a和b的乘积  

    (a, b) <- zip ..

这个表达式是把zip后的内容赋值给a, b

    myList (tail myList)
这个表达式理解起来就相对比较头疼.这里使用了myList,但是我们不是在赋值给myList的么?不会出现segment fault么?答案是否定的, 当然不会出现segment fault.这得亏得haskell的lazy解析特性, 在myList没被使用的时候他不会被解析.好了,至此这两段其貌不扬的代码做了非常复杂的工作,首先他把myList定义为\[0,1\]的列表, 当你访问myList的第3个元素的时候他通过中括号内的表达式生成一个新的list,然后取他的第三个元素,也就是0.至于为啥是0,就留给读者自己做下演算.  
  
到这里我们再回顾下上面的金科玉律,是不是没那么难理解?这种编程思路虽然比较费脑,但是却很便捷.  
  
神奇的多态(Polymorphic) 
===
我们先来回想下java中多态的应用: 

    public class A {
      public int sum(int a, int b) {
        return a + b;
      }

      public double sum(double a, double b) {
        return a + b;
      }
    }
  
这就是java中多态的简单应用, 让sum不仅可以对int也可以对double类型进行相加.  
  
Haskell中的真多态  
====  
用haskell对上述代码进行重构

    sum :: (Num a, Num b) => a -> b -> b
    sum a b = a + b
    sum (4 :: Int) 1 -- ouput 5
    sum (4 :: Double) 1 -- ouput 5.0

我们只需要定义一个函数,他会适用于多种数据类型.那他是怎么工作的呢?其实他的思想是把4这个数值定义为类型a,然后a是一个class Num, 当进行相加操作的时候,先去判断类型a是否有相加的操作(因为这里a是class Int,所以a拥有相加的操作), 然后进行class Int的相加操作并返回.  

为什么说是真多态呢?因为java中的多态是绑定在数据上的,而haskell的多态是绑定在class上的,所以才能达到上述效果.
  
语法解释  
=====  
*::*符号表示对函数的定义  

    (Num a, Num b) => a -> b -> b

表示a和b是class Num,其中ab指的是后续当中的ab, 而=>符号表示对后面的变量的类型指向. 最后一个->表示返回值,其余表示参数的个数和类型.
  
再次提醒
====  
看完这么多例子,是否更好的理解什么叫做定义而不是实现
