---
layout: post
title: Haskell学习笔记--Expression
tags: haskell, expression
date: '2014-01-27 20:04:13'
udate: '2014-01-27 20:04:13'
category: 技术
---
  
休息了一天,今天本想再偷懒下的,还是不能太放纵自己,把这宝贵的一小时奉献给Haskell.今天来看看haskell expression的定义.  
  
Expression  
===  
全局的看下Haskell的expression的定义.  

    exp	→	infixexp :: [context =>] type	    (expression type signature)
      |	infixexp
    infixexp	→	lexp qop infixexp	    (infix operator application)
      |	- infixexp	    (prefix negation)
      |	lexp
    lexp	→	\ apat1 … apatn -> exp	    (lambda abstraction, n ≥ 1)
      |	let decls in exp	    (let expression)
      |	if exp [;] then exp [;] else exp	    (conditional)
      |	case exp of { alts }	    (case expression)
      |	do { stmts }	    (do expression)
      |	fexp
    fexp	→	[fexp] aexp	    (function application)
    aexp	→	qvar	    (variable)
      |	gcon	    (general constructor)
      |	literal
      |	( exp )	    (parenthesized expression)
      |	( exp1 , … , expk )	    (tuple, k ≥ 2)
      |	[ exp1 , … , expk ]	    (list, k ≥ 1)
      |	[ exp1 [, exp2] .. [exp3] ]	    (arithmetic sequence)
      |	[ exp | qual1 , … , qualn ]	    (list comprehension, n ≥ 1)
      |	( infixexp qop )	    (left section)
      |	( qop⟨-⟩ infixexp )	    (right section)
      |	qcon { fbind1 , … , fbindn }	    (labeled construction, n ≥ 0)
      |	aexp⟨qcon⟩ { fbind1 , … , fbindn }	    (labeled update, n  ≥  1)
  
<!-- more --> 
中缀(infix)
====  
在这里我们似乎看到了一个很熟悉的名词--infix, 表达式解析的时候我们经常能看到infix.先来回顾下后缀, 中缀和前缀的*1 + 1*的表达式:

<table>  
  <tr>  
    <td>名称</td><td>表达式</td>
  </tr>
  <tr>  
    <td>前缀</td><td>+ 1 1</td>
  </tr>
  <tr>  
    <td>中缀</td><td>1 + 1</td>
  </tr>
  <tr>  
    <td>后缀</td><td>1 1 +</td>
  </tr>
</table>
  
可以看到表达式的定义十分简单, 就两种,一种是我们上篇见过的constructor的定义,另一种就是最平常的表达式.下面我们一个接一个看lexp的定义:  
  
lambda  
====
    \ apat1 … apatn -> exp	    (lambda abstraction, n ≥ 1)
这是lambda的表达式, 以\\开头.  

例子
======
    (\ x -> x + 1) 1 --output 2

  
let  
====
    let decls in exp	    (let expression)

例子
======
    let x = 1 in x + 1 -- output 2
    show x -- x not in scope

conditional  
====
    if exp [;] then exp [;] else exp	    (conditional)

例子
======
    con :: Num x => x -> x
    con x = if x == 1 then 1 else 2
    show (con 1) -- output 1
    show (con 10) -- output 2
  
case  
====
    case exp of { alts }	    (case expression)
    alts	→	alt1 ; … ; altn	    (n ≥ 1)
    alt	→	pat -> exp [where decls]
        |	pat gdpat [where decls]
        |		    (empty alternative)
    gdpat	→	guards -> exp [ gdpat ]
    guards	→	| guard1, …, guardn	    (n ≥ 1)
    guard	→	pat <- infixexp	    (pattern guard)
        |	let decls	    (local declaration)
        |	infixexp	    (boolean guard)

例子
======
    con :: (Num x, Eq x) => x -> x
    con x = case x of
        1 -> 1  
        otherwise -> 2

    show (con 1) -- output 1
    show (con 10) -- output 2
这里要补充说明下为什么x是两种类型, 因为Num这个class并没有==的操作, 所以需要对类型a额外的定义Eq的class.

do  
====  

    do { stmts }	    (do expression)
    stmts	→	stmt1 … stmtn exp [;]	    (n ≥ 0)
    stmt	→	exp ;
      |	pat <- exp ;
      |	let decls ;
      |	;	    (empty statement)
  
function expression  
====  

    fexp	→	[fexp] aexp
  
例子  
=====

    doStat :: Num a => a -> a
    doStat x = do  
      x + 1
    show (doStat 10) --output 11

Section  
====  

section是和infixexp一样的货. 具体定义如下:  

    aexp	→	( infixexp qop )	    (left section)
          |	( qop⟨-⟩ infixexp )	    (right section)

qop中除去-符号. 我们可以把section理解为infixexp的group.

Errors  
====  
Prelude提供两种方式报错, 能让程序立马停止:  

    error     :: String -> a  
    undefined :: a
   
例子  
=====

    throwEx :: Num a => a -> a
    throwEx x =  
      error "hello world"
      x + 1

    show (throwEx 10) --output "hello world exception", must be no 11
  
  
List  
====  

    aexp	→	[ exp | qual1 , … , qualn ]	    (list comprehension, n ≥ 1)
    qual	→	pat <- exp	    (generator)
            |	let decls	    (local declaration)
            |	exp	    (boolean guard)
  
这里的generator比较好玩, 看如下的代码  

    createTuple :: (Num a, Ord a) => [a] -> [a] -> [(a, a)]
    list1 = [1, 2, 3]
    list2 = [5, 6]
    createTuple l1 l2 = [(a, b) | a <- l1, b <- l2, a > 2]
    show (createTuple list1 list2) --output ?

这里的输出的结果是  

    [(3,5), (3,6)]

为什么?其实他的解析规则是从\|开始到后的每个表达式为true的结果,所以当a是1的时候,在a>2的时候为false, 因此他不会出现在结果中.  
  
Pattern Matching  
====  
pattern matching出现在lambda, function, pattern binding, list, do 和case表达式中. haskell最终都会翻译成case的样子, 所以我们只需要关心haskell对case的处理. 他的主要作用是将变量分解成不用的名字,更方便使用.下来先来看看什么是pattern.  
  
    pat	→	lpat qconop pat	    (infix constructor)
        |	lpat
    lpat	→	apat
        |	- (integer | float)	    (negative literal)
        |	gcon apat1 … apatk	    (arity gcon  =  k, k ≥ 1)
    apat	→	var [ @ apat]	    (as pattern)
        |	gcon	    (arity gcon  =  0)
        |	qcon { fpat1 , … , fpatk }	    (labeled pattern, k ≥ 0)
        |	literal
        |	_	    (wildcard)
        |	( pat )	    (parenthesized pattern)
        |	( pat1 , … , patk )	    (tuple pattern, k ≥ 2)
        |	[ pat1 , … , patk ]	    (list pattern, k ≥ 1)
        |	~ apat	    (irrefutable pattern)
    fpat	→	qvar = pat
  
其中值得注意的是**\_**表示全匹配以及**var@\(..\)**这种格式.
  
例子  
=====

    case e of { xs@(x:rest) -> if x==0 then rest else xs }

和  

    let { xs = e } in  
    case xs of { (x:rest) -> if x==0 then rest else xs }

这两种写法是等价的. 不难看出xs被分解成x和rest变量, 在后续的表达式中被使用.  
