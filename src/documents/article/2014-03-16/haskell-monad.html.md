---
layout: post
title: Haskell学习笔记- Monad, IO和Functor 
tags: haskell, monad, io, functor
date: '2014-03-16 09:24:08'
udate: '2014-03-16 09:24:08'
category: 技术
---
  
Monad这个概念是第一次在Haskell中看到, 也是haskell中比较难理解的部分之一, 但同样也是很重要的部分. 今天就来看看Monad到底是什么货, 同时也来看看Functor和IO是什么?  
  
Monad用法  
====  
在给Monad一个正式的定义之前, 先来看看Monad的标准用法:  

    let a = Just 1 in a >>= \x -> Just (x+2) --output Just 2
  
这里我们先来回顾下lambda的用法:  

    \x -> Just (x+2)

这个函数将输入的x加2后返回, 并且把这个值包装在Just中.
  
  
对了, 这就是Monad的标准用法, 很直观的一个好处: 让代码更加的可读和简洁. 虽然我们不知道Just的实现, 但是我们可以猜到*>>=*可以将Just中的东西提取出来.  
<!-- more --> 
Monad的源码  
====  
看过了上述实例, 我们看下Monad的源码:

    class  Monad m  where
        -- | Sequentially compose two actions, passing any value produced
        -- by the first as an argument to the second.
        (>>=)       :: forall a b. m a -> (a -> m b) -> m b
        -- | Sequentially compose two actions, discarding any value produced
        -- by the first, like sequencing operators (such as the semicolon)
        -- in imperative languages.
        (>>)        :: forall a b. m a -> m b -> m b
            -- Explicit for-alls so that we know what order to
            -- give type arguments when desugaring
        -- | Inject a value into the monadic type.
        return      :: a -> m a
        -- | Fail with a message.  This operation is not part of the
        -- mathematical definition of a monad, but is invoked on pattern-match
        -- failure in a @do@ expression.
        fail        :: String -> m a
        {-# INLINE (>>) #-}
        m >> k      = m >>= \_ -> k
        fail s      = error s
  
monad其实规范了几个行为:   

- \>\>, 和1相类似, 只是将第一个参数的输出舍弃  
- return, 则是将某个值包含在类型m中  
- fail, 则是接收一个String的参数, 并返回原值  
- \>\>=, 从他的签名来看我们能明白他主要将第一个参数的值转化为第二个参数的输入, 并将第二个参数的输出作为整个表达式的输出  
  
  
从上面我们也能看出Monad的概念不是语言级别的, 也就是说他并不是语法, 而是一种编程思路, 可以理解为和设计模式类似的东西, 但却稍微有些不同.  
笔者认为Monad是对haskell语言的一种best practice,  让代码更加直观. 另外还有一个最重要的功能就是提高代码的复用率 -- 避免我们讲函数的参数在不同函数之间传递.
  
Monad实例  
=====  
我们来看看最简单的Monad的实现: Maybe  

    -- Maybe的定义
    data Maybe a  =  Nothing | Just a
      deriving (Eq, Ord)
    -- Maybe实现
    instance  Monad Maybe  where
        (Just x) >>= k      = k x
        Nothing  >>= _      = Nothing
        (Just _) >>  k      = k
        Nothing  >>  _      = Nothing
        return              = Just
        fail _              = Nothing
  
从Maybe的定义我们可以看到, Maybe类型可以携带一个a的任意类型, 并且它有两种值:  

1. Nothing, 这是一个type constructor, 可以理解为类型的构造函数, 类似于java中的class的constructor, 它不接收任何参数  
2. Just a, 同样是类型构造函数, 他接收一个任意类型的a  
  
他实现了Monad的几个函数:  
1. \>\>=, 将Just所包含的值作为第二个参数k的输入; 如果是Nothing的话, 则返回Nothing
2. return, 用Just类型构造函数包裹  
3. fail, 返回Nothing
  
  
Monad的好处  
====  
讲了这么多复杂的Monad的概念, 好像没什么可对比出来的好处, 那我们来看这种场景:

    {-
     - 输入一个整数
     - 1. + 1
     - 2. + 4
     - 3. - 5 
    -}
    addNum :: Int -> Int
    addNum x = do
      let a = x + 1 in
        let b = a + 4 in
          b - 5

如果我们需求需要对x做更多的处理的话, 那么这个函数是多么可怕!
  
如果使用Monad呢?  

    addNumM :: Int -> Int
    addNumM x = 
      maybe 0 (\x -> x) (
        Just x >>= (\z -> Just $ z + 1)
          >>=  (\z -> Just $ z + 4)
          >>=  (\z -> Just $ z - 5)
      )

如此, haskell就将整个流程串联起来, 让代码可读性大大增加.但是这个的前提是基于我们已经完全掌握了prelude中的函数, 也就是说学习haskell需要很高的学习成本, 但掌握之后会大大提高工作效率.
  
IO  
====  
IO其实和Monad关系不大, 笔者把他和Monad写在一起的原因主要是因为这两者都比较难理解, 而且IO是Monad的一个instance.  
为什么会有IO?看名字, 好似只做输入输出有关的东西. 想要理解什么是IO, 我们先要理解什么是purity. Haskell所提倡的函数编程的purity, 它的本意是指对于一个函数, 给出相同的输入, 必然会得到相同的输出. 这是不是和小时候所学的数学代数类似? 只要代数的值恒定, 那么其结果必然恒定. (当然开发这个语言的坐着本来就是个数学家!).  
  
但是, 有一定编程经验的朋友肯定知道, 编程的时候可能会有全局变量, 可能会根据条件打印文字到console. 这必然违背了haskell的purity, 如果haskell放弃这些东西的话, 那这门语言必然只能局限在数学领域, 或者认为他并不是一门语言.  
  
考虑到以上问题, haskell给出了一个IO解决方案, 也就是说IO其实是有副作用的函数, 对于给定的输入, 不能得到恒定的输出. Haskell对IO有如下限制:  
  
1. IO的副作用只会在IO被另外一个IO调用的时候才会产生  
2. main就是一个IO  
3. IO被调用返回值是它所包含的类变量的值
  
Functor  
====  
Functor其实和Monad是类似的东西, 只不过支持的东西不一样, 来看看他的定义:  

    class  Functor f  where
        fmap        :: (a -> b) -> f a -> f b
        -- | Replace all locations in the input with the same value.
        -- The default definition is @'fmap' . 'const'@, but this may be
        -- overridden with a more efficient version.
        (<$)        :: a -> f b -> f a
        (<$)        =  fmap . const

类似python的map函数.  
