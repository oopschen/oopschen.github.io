---
title: Haskell学习笔记--Typeclass
tags:
    - Haskell
    - typeclass
date: '2014-02-10 20:08:23'
udate: '2014-02-10 20:08:23'
draft: false
alias:
    - /article/2014-02-10/haskell-typeclass.html
categories:
    - TECH 
---
  
新的一年新的开始. 技术还是要连续, 继续我的haskell旅行. 今天要看看haskell中异常强大的**TypeClass**, type和class放在一起, 会有怎样的化学反应呢?  
  
首先来了解这么一个事实--Haskell中语言中没有对所有类型定义*==*操作符. 回想下其他语言, 比如c, ==的意义是对比两个内存位置, python中则是根据不同类型对比他们的内容.那么haskell为什么没有默认的实现, 它又是怎么实现的呢?  
  
在Haskell中, 所有操作符, 比如+, =, .等, 都是函数, 我想这也可能是他是最纯粹的函数语言的原因之一. 所以这些操作符都是由用户实现的, 而实现他们的正是标准库**Prelude**. 貌似扯远了, 再回到Typeclass. Haskell就是通过Typeclass从而实现了, 操作符对不同类型的支持.  
  
<!-- more --> 
先来看段完整的例子:
```Haskell
    data People = Peo {
      peoId :: Int,
      peoAge :: Int
    } deriving (Show)
    class MyEq a where
      xy :: a -> a -> Bool
    instance MyEq People where
      xy x y = (peoId x) == (peoId y)
    main = print $ show $ (Peo 1 2)
```
  
这个例子的作用:  
  
1. 定义一个名叫People的type  
2. 定义了class MyEq, 有一个操作 xy, 接收两个type为MyEq的参数, 并进行比较, 返回一个Bool值  
3. 把People定义为MyEq的实例, 并实现xy方法  
  
分解  
=====
```Haskell
    data People = Peo {
      peoId :: Int,
      peoAge :: Int
    } deriving (Show)
```
    
这段代码已经在以前的blog讲过, 这里主要提下关键字deriving, 它的功能是把People类型继承了Show这个class, 后面再分析Show有哪些操作.  
```Haskell
    class MyEq a where
      xy :: a -> a -> Bool
    instance MyEq People where
      xy x y = (peoId x) == (peoId y)
```  

这段代码定义了拥有xy操作的class MyEq, 并让type People实现MyEq的定义. 在class MyEq a中a到底指什么呢? 其实a指的是instance后的类型, 比如People, 当xy函数被调用的时候, Haskell会根据参数推测出是否是People的类型, 如果不是则会出错. 如果有多个instance呢?Haskell也还是根据参数类型, 推测使用哪个instance的实现. 这里和Java中的接口和实现类比较相似, 但是却比java智能, 因为java中需要手动判断类型从而选择某个实现, 还要利用factory的模式让代码更优雅, 而Haskell中则在语言级别就支持这种特性. 
  
至此, 我们来整理下思路, 其实Haskell它有独立的type定义和type class的定义, 并用某种方式把操作符, type和class联系起来. 这也正说明了Haskell type系统的强大. 同时也印证了编程界的一句老话--程序就是数据和逻辑的集合. Haskell中的type是数据的集合而class则是逻辑的集合, instance则是用来将两者联系起来的方式. 所以data是定义数据的样子, 而class只定义有哪些操作. 
  
Haskell不简单的class  
=====  
```Haskell
    data People = Peo {
      peoId :: Int,
      peoAge :: Int
    } deriving (Show)
    data Human = Hm {
      hId :: Int,
      hAge :: Int,
      name :: String
    } deriving (Show)
    class MyEq a where
      xy :: a -> a -> Bool
    instance MyEq People where
      xy x y =  (peoId x) == (peoId y)
    instance MyEq Human where
      xy x y =  (hId x) == (hId y)
    main = do 
      print $ show $ (Peo 1 2)
      print $ show $ (Hm 1 2 "ray")
```
  
上面这个例子实现了MyEq这个定义对多种instance实用, 因为Haskell会根据不通参数类型, 调用不同的xy实现. 另外, 我们还可以给class 默认实现, 比如:  
```Haskell
    class MyEq a where
      xy :: a -> a -> Bool
      xy x y = x == y
```
  
  
常见的的class  
=====  
Show能把大部分数据类型转化成文本.  

    show 1 -- output "1"
    show True  -- output "True"
    show "1" -- output "\"1\""

Read则是Show的逆向函数.  

    (read "1") :: Int --output 1
    (read "1") :: Double --output 2
  
data, type和newtype  
=====
```Haskell
    type MyInt = Int
    data MyType = M MyInt deriving(Eq)
    newtype NewMyType = N Int deriving(Eq)
    main = do 
      print $ show $ (M 1 == M 1) -- output "True"
      print $ show $ (M 1 == N 1) -- compile error
```
  
type是对原来类型的别名, 可以理解为c中的define; data是对数据的定义, 和c中的struct类似; newtype则是对类型的重新定义, 可以理解为重新生成一份新的type, 并且newtype只接受一个参数.
  
总结  
=====  
Haskell的编程思想和OOP不太一样, OOP把数据和操作都放在一起, 而Haskell则是将数据和操作分开, 数据可以由data, type和newtype定义, 操作则是由class和instance定义. 另外, Haskell有着极其强大的type系统, 或者我们可以将其理解为Haskell中的type是一种特别的变量, 它的type可以继承, 实例化, 比起其他语言固定的type系统要强大很多.
  
到此开头的问题也能迎刃而解了, Haskell语言中没有默认的*==*实现, 它利用typeclass系统实现对不同的type的支持.  
