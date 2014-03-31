---
layout: post
title: Haskell学习笔记--Declarations and Bindings
tags: Haskell, declarations, bindings
date: 2014-01-29 20:32:43
udate: 2014-01-29 20:32:43
category: 技术, haskell
---
即将到年三十了, 好学的年轻人还是决定在今天花一个小时提升下自己的技能. 今天来看看Haskell 2010语言规范中的Declarations和Bindings.  
Declarations  
===  
这部分在理解Haskell中很重要, 因为他诠释了haskell这门语言是如何定义事情的, 他的定义会告诉编译器把这些代码生成低级机器语言.   

    module	→	module modid [exports] where body
              |	body
    body	→	{ impdecls ; topdecls }
              |	{ impdecls }
              |	{ topdecls }
    topdecls	→	topdecl1 ; … ; topdecln	    (n ≥ 1)
    topdecl	→	type simpletype = type
              |	data [context =>] simpletype [= constrs] [deriving]
              |	newtype [context =>] simpletype = newconstr [deriving]
              |	class [scontext =>] tycls tyvar [where cdecls]
              |	instance [scontext =>] qtycls inst [where idecls]
              |	default (type1 , … , typen)	      (n ≥ 0)
              |	foreign fdecl
              |	decl
    decls	→	{ decl1 ; … ; decln }	    (n ≥ 0)
    decl	→	gendecl
              |	(funlhs | pat) rhs
    cdecls	→	{ cdecl1 ; … ; cdecln }	    (n ≥ 0)
    cdecl	→	gendecl
              |	(funlhs | var) rhs
    idecls	→	{ idecl1 ; … ; idecln }	    (n ≥ 0)
    idecl	→	(funlhs | var) rhs
              |		    (empty)
    gendecl	→	vars :: [context =>] type	    (type signature)
              |	fixity [integer] ops	    (fixity declaration)
              |		    (empty declaration)
    ops	→	op1 , … , opn	    (n ≥ 1)
    vars	→	var1 , … , varn	    (n ≥ 1)
    fixity	→	infixl | infixr | infix

从上面我们可以看到有*topdecls*和*decls*的区分, topdecls只能在module的top level中被声明, 而不能在其他的scope(比如where, let等)中被声明. Haskell把Declarations分为三个组:  
  
1. 用户定义的, 包含type, newtype, data  
2. 类型类和重载, 包含class, instance, default  
3. 层级的声明, 包含value binding, type signatures和fixity  
  
<!-- more --> 

我们来看下class **Num**在Prelude中的定义:

    class Num a  where          
        (+)    :: a -> a -> a  
        negate :: a -> a

上面的代码不仅定义了他自己, 而且定义了他相关的操作的参数类型和返回类型. 当编译器遇到操作符**\+**并且操作数为类型Num的时候, 他就会调用这里的**(\+)**方法.  
  
再来看看*instance*的用法:  

    instance Num Int  where     
        x + y       =  addInt x y  
        negate x    =  negateInt x  

这段定义把Int定义为Num的实例, 让Int继承了Num的*(\+)*和*negate*方法, 而where以后的定义是对两个方法的实现.  
  
  
Types  
=====
    type	→	btype [-> type]	    (function type)
    btype	→	[btype] atype	    (type application)
    atype	→	gtycon
            |	tyvar
            |	( type1 , … , typek )	    (tuple type, k ≥ 2)
            |	[ type ]	    (list type)
            |	( type )	    (parenthesised constructor)
    gtycon	→	qtycon
            |	()	    (unit type)
            |	[]	    (list constructor)
            |	(->)	    (function constructor)
            |	(,{,})	    (tupling constructors)
  
haskell的type系统是强类型, 并且是可以**多态的**. 注意这里指的是类型是多态的, 因为在其他编程语言中, 多态只限定在实例上. 这里我们先搞清楚两个东西:  
  
1. type, 大写字母开头
2. type variable, 小写字母开头  
  
所谓的type, 我们可以理解为对类型的定义, 比如以下代码  

    data CustomizedType = CustomizedTypeValueConstruct

这里我们定义了一个类型*CustomizedType*, 这个类型有一个构造函数CustomizedTypeValueConstruct, 表明这个类型没有任何field.那么我们如何使用这个类型呢?  

    va = CustomizedTypeValueConstruct 

如此我们就创建了一个type variable, 具有CustomizedType类型.  
  
我们再来看一个更加复杂的例子  

    data People = People {
      name :: [Char],
      age :: Int
    }
    me = People "Ray" 18
    anotherMe = People {
      name = "Ray",
      age = 18
    }

上面我们定义了一个People类型, 他有一个叫做name和一个叫做age的fields. 咋看起来有点像c的struct.
  
多态类型  
======  
看完上面的基础知识我们来回顾下面的代码:

    f :: Num a -> a -> a

这其中a是type variable, Num就是type. 那多态如何提现?  

    f :: a -> a

如果f被定义为这样, 那么f可以接收任意类型, 并且返回接收的类型的类型值. 这就是类型多态的好处, 有点像c++中的template类的概念, 却比他强大很多.
  
  
-> 的定义  
=====  
我们再来回顾下下面的代码:  

    f :: a -> a -> a

这段代码声明了f接受两个参数, 并返回同类型的参数. 那符号*->*会有多重意思么? 其实没有, haskell中->符号表示它左边的定义是函数的输入, 右侧的定义是函数的输出, 并不是我们所想的->是用来分割参数用的.  
  
上面的代码我们可以理解为  

    f :: a - > (a -> a)
    f 1 1 -- == (f 1) 1  

也就是说当我们调用的时候, haskell会先调用*f 1*返回一个函数, 这个函数的类型是*a -> a*, 然后再用1调用这个函数. 从而形成了类似一个函数接受多个参数的现象, 这也是haskell中比较怪异的一点, 他所有的函数只接受一个参数, 而多个参数调用的假象是利用上出原理造成的.  
  
space leak
=====  
前几篇blog中我们提到过haskell的lazy解析, 就是说当haskell碰到1 + 1 这个表达式的时候, 他只记录下这个表达式, 当引用到这个表达式的值的时候, 我们才会真正计算这个表达式的值--2. space leak是指haskell中因为过多的记录表达式, 而导致系统内存耗尽. 看如下的例子  

    sum [1..100000000]

在ghci中执行这个表达式, 足以让我的4g内存耗尽, 其实他做的事情很简单, 就是把1到100000000的数相加. 那为什么会耗尽内存呢?    

先来看下sum的源代码:  

    sum l = sum' l 0
        where
        sum' []     a = a
        sum' (x:xs) a = sum' xs (a+x)

从上米那我们不难看出, 当我们相加的数值越多, 生成的表达式*sum' xs (a + x)*就越多, 也就消耗越多的内存, 最终导致内存耗尽.那如何避免呢?  
  
seq  
======  

    seq :: a -> b -> b

他的功能就是将第一个表达式的值马上解析, 忽略lazy模式, 这样可以减少表达式的累积.  
  
我们可以把函数改写成  

    sum l = sum' 0 l
        where
        sum' a [] = a
        sum' a (x:xs) = let   
              val = a + x  
              in  
              seq val (sum' val xs)

因为val表达式的值不会累积, 所以内存消耗是个常量.  
  
其实关于这样的设计, 也说不上好坏, 只能说有很多坑, 对于不了解haskell编译器实现的人来说,  这些简直就是噩梦.  
  
(\.) 函数  
=====  
再介绍一个比较有趣的函数--*\.*  

    (.) :: (b -> c) -> (a -> b) -> a -> c

这个定义看起来似乎很复杂, 那我们拆解来看:
  
1. 接收*b -> c*类型的参数, 返回 (a -> b) -> a -> c 类型的值  
2. 接收*a -> b*类型的参数, 返回a->c类型的值  
3. 接收*a*类型的参数, 返回c类型的值  
  
我们来看个例子:  

    length . words "hello world" -- output 2
  
以下是length和words函数的定义:

    length :: [a] -> Int
    words :: String -> [String]

我们拿出纸笔来模拟haskell执行的过程:  
  
1. b -> c, 就是length函数, b为\[a\]--一个类型为a的数组, c为Int类型  
2. a -> b, 则是words函数, a为String类型, b为类型为String的数组, 也就是说1中的a类型为String  
  
所以这个表达式的返回值是2.通过这个例子我们不难发现其实*(.)*函数就是我们熟悉的管道, 让一个函数的返回值作为另一个函数的输入.  
  
部分函数  
=====  
这里我们来看一段更有意思的代码

    map (3 + ) [1,2] -- output [4, 5]

map顾名思义就是将每个list中的值当作函数的参数调用, 并返回一个list. 这段代码最离奇的是*(3 + )*这部分, 似乎是一个不完整的表达式, 难道就不会报错么?  
  
其实这个表达式在haskell中称为partial function, 我只能把他翻译成部分函数了, 它就是一个函数, 它右边的参数被认为*\+*的右侧操作符.
