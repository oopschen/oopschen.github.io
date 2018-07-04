---
title: Haskell学习笔记一--More on function
tags:
    - Haskell
    - tutorial
    - function
date: '2014-01-24 13:27:21'
draft: false
alias:
    - /article/2014-01-24/haskell-funcion-pattern-lambda.html
categories:
    - TECH 
---
  
在haskell中我们可以对function做的更多, 这节一起来看看什么是function pattern和lambda function, 以及什么是多态类.  
  
Function Pattern  
===  
首先我们来看下我们在python的一段代码  
```Haskell
    def sumList(l) :  
        if 1 > len(l) :  
          return 0
        if 2 > len(l) :  
          return l[0] 
        return l[0] + l[1] 
```
那么用function pattern写会如何呢?  

```Haskell
    sumList :: Num a => [a] -> a  
    sumList (ele:oEle) = ele + sumList oEle  
    sumList [x] = x
    sumList [] = 0
```

这段函数该如何解读?看起来我们像是对*sumList*定义了3遍,但是每次定义的样子都不一样,这样会不会让函数的定义混乱?这时候**Funtion Pattern**就开始发挥作用了.  

先来看第一段代码:  
```Haskell
    sumList (ele:oEle) = ele + sumList oEle  
```

这段代码定义了当sumList的参数多余一个元素的时候将第一个元素的值和后续元素递归调用后的值相加.  
  
再来看第二段代码:  

```Haskell
    sumList [x] = x
```

当sumList的参数有且只有一个元素的时候返回该元素的值.  
  
最后是第三段代码:  
```Haskell
    sumList [] = 0
```
这段代码是最容易理解的,当为空数组的时候返回0.  
  
好了,这就是Funcion Pattern的功用了, 他没有定义了3次函数, 而是根据不同参数定义不同的函数, 实现了上述python的功能.  
  
Lambda  
===  
接下来我们来看看lambda, 可以理解为没有函数名字的函数, 一般用在这个函数极其简单, 且只会被使用一次.还是先来看看python是如何写lambda的:  

```Haskell
    (lambda x: x+1)(1)
```
  
再来看看haskell是如何写的:  

```Haskell
    (\ x -> x + 1) 1
```

其中**\\**表示lambda函数的开头, 其他就和一般函数定义是一样的.  

多态类(Polymorphic Types)和类构造器(Type Constructors)
===  
来看下这么一段超级奇怪的代码:  

```Haskell
    main = return ()
```

main同样是所有Haskell程序的入口, 这段代码是最简单的Haskell程序.他的功能只是把main这个变量赋值成一个类型,而这个类型是null, 也就是我们看到的**()**. 可以把他理解成python中的None.
  
再来看看关于main的一种定义:  

```Haskell
    main :: IO ()
```

咋看起来,这怎么像python中的函数调用?等等,Haskell 的函数调用也不是这样的,而且在定义中也没办法出现函数调用呀?这货到底是什么?首先,IO就是我们说的多态类, 他接受一个类型的参数, 也就是\(\). 而这段定义是说main是被IO构造出来的类型, 而IO接受一个()的参数.  
  
Maybe  
====  
我们再来看一个标准库中Maybe的模块.  

```Haskell
    data Maybe a = Nothing | Just a
```

*data*是用来定义类型的关键字, 这段代码是把a这个类型定义为Nothing或者Just a.  
  
再来看下一个例子  

```Haskell
    showPet :: Maybe (String, Int, String) -> String
    showPet Nothing		= "none"
    showPet (Just (name, age, species))	= "a " ++ species ++ " named " ++ name ++ ", aged " ++ (show age)
```

这个例子我们可以看到showPet接收一个Maybe类型的参数, 当参数为Nothing的时候返回none的字符串.而当参数的类型是Just (name, age, species)类型的时候, 他就是一个(name, age, species)类型.真是要彻底颠覆对类型(也就是type)的理解了.对这里笔者还是不十分理解,有待深入研究Maybe到底干了什么事情.
