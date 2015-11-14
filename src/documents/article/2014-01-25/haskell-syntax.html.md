---
layout: post
title: Haskell学习笔记三--语法 
tags: haskell, syntax, grammer, syntax
date: '2014-01-25 15:36:26'
udate: '2014-01-25 15:36:26'
category: 技术
---
  
这篇blog要记录下笔者在看haskell的BNF的种种, 希望能全面的了解haskell的语法规则.这里的语法规则主要指的是[Haskell 2010](http://www.haskell.org/onlinereport/haskell2010/haskellch2.html#x7-140002 "Haskell 2010 语法").  
  
Lexeme BNF  
===  

    program	→	{ lexeme | whitespace }
    lexeme	→	qvarid | qconid | qvarsym | qconsym |	literal | special | reservedop | reservedid 
    whitespace	→	whitestuff {whitestuff}
    whitestuff	→	whitechar | comment | ncomment
    whitechar	→	newline | vertab | space | tab | uniWhite
    newline	→	return linefeed | return | linefeed | formfeed
    return	→	 a carriage return
    linefeed	→	 a line feed
    vertab	→	 a vertical tab
    formfeed	→	 a form feed
    space	→	 a space
    tab	→	 a horizontal tab
    uniWhite	→	 any Unicode character defined as whitespace 

上面的BNF定义了haskell的程序是由lexeme和whitespace组成的,lexeme也给出了他自己的定义.这里值得关注的是newline中包含formfeed的定义,也就是ascii值为12的字符.其他的和其他语言类似.
  
<!-- more --> 
再来看看对comment的定义:

    comment	→	dashes [ any⟨symbol⟩ {any} ] newline
    dashes	→	-- {-}
    opencom	→	{-
    closecom	→	-}
    ncomment	→	opencom ANY seq {ncomment ANY seq} closecom
    ANY seq	→	{ANY }⟨{ANY } ( opencom | closecom ) {ANY }⟩
    ANY	→	graphic | whitechar
    any	→	graphic | space | tab
    graphic	→	small | large | symbol | digit | special | " | '

这里我们可以看出comment有两种格式,一种是以*\-\-*开头到一行结束为comment, 另一种是以*\{\-*开头,并且可以包行多行,直到以*\-\}*结束的多行comment.注意,以dash方式进行comment的时候是要除掉symbol以外的any字符,至于symbol的定义,请接着往下看.  
  
    small	→	ascSmall | uniSmall | _
    ascSmall	→	a | b | … | z
    uniSmall	→	 any Unicode lowercase letter
    large	→	ascLarge | uniLarge
    ascLarge	→	A | B | … | Z
    uniLarge	→	 any uppercase or titlecase Unicode letter
    symbol	→	ascSymbol | uniSymbol⟨special | _ | " | '⟩
    ascSymbol	→	! | # | $ | % | & | ⋆ | + | . | / | < | = | > | ? | @ |	\ | ^ | | | - | ~ | :
    uniSymbol	→	 any Unicode symbol or punctuation
    digit	→	ascDigit | uniDigit
    ascDigit	→	0 | 1 | … | 9
    uniDigit	→	 any Unicode decimal digit
    octit	→	0 | 1 | … | 7
    hexit	→	digit | A | … | F | a | … | f

这里对symbol的定义是uniSymbol中除去*\_*, *\"*, 和*\'*以外的字符, 以及ascSymbol指向的哪些字符.

**PS, 语法解析的时候应该是用贪婪的策略, 也就是越长匹配的语法越优先.比如解析器碰到==的时候, 应该把他识别为==而不是= =**  
  
变量名称和操作符  
====  
看了这么一大堆定义估计脑子都秀逗了, 所以我们来回忆下上面对lexeme的定义.

    lexeme	→	qvarid | qconid | qvarsym | qconsym |	literal | special | reservedop | reservedid 
  
接下来我们来看看这些子term到底是什么?  

    qvarid	→	[modid .] varid
    qconid	→	[modid .] conid
    qtycon	→	[modid .] tycon
    qtycls	→	[modid .] tycls
    qvarsym	→	[modid .] varsym
    qconsym	→	[modid .] consym
  
那modid又是什么?  

    varid	    	    (variables)
    conid	    	    (constructors)
    tyvar	→	varid	    (type variables)
    tycon	→	conid	    (type constructors)
    tycls	→	conid	    (type classes)
    modid	→	{conid .} conid	    (modules)
    varsym	→	( symbol⟨:⟩ {symbol} )⟨reservedop | dashes⟩
    consym	→	( : {symbol})⟨reservedop⟩
    reservedop	→	.. | : | :: | = | \ | | | <- | -> | @ | ~ | =>
    
haskell在语言的规范中就定义了6中namespace:  
  
1. variables 
2. constructors
3. type variables
4. type constructors
5. type classes
6. module names
  
  
其中variables和type variables必须以小写的字母或者下划线开头, 其他的namespace以大写字母开头.变量名称不能和type constructor的命名以及同作用域内的class同名.  
  
我们从上面的定义可以看出, varsym是一般的变量命名, 非:开头.而以:开头的名称是被当作为constructors.  
  
数字语法  
=====

    decimal	→	digit{digit}
    octal	→	octit{octit}
    hexadecimal	→	hexit{hexit}
    integer	→	decimal |	0o octal | 0O octal |	0x hexadecimal | 0X hexadecimal
    float	→	decimal . decimal [exponent] |	decimal exponent
    exponent	→	(e | E) [+ | -] decimal

上面的定义很清晰的解释了整型, 浮点, 八进制, 十六进制, 以及十进制的语法规则.
  
字符串语法  
=====  

    char	→	' (graphic⟨' | \⟩ | space | escape⟨\&⟩) '
    string	→	" {graphic⟨" | \⟩ | space | escape | gap} "
    escape	→	\ ( charesc | ascii | decimal | o octal | x hexadecimal )
    charesc	→	a | b | f | n | r | t | v | \ | " | ' | &
    ascii	→	^cntrl | NUL | SOH | STX | ETX | EOT | ENQ | ACK |	BEL | BS | HT | LF | VT | FF | CR | SO | SI | DLE |	DC1 | DC2 | DC3 | DC4 | NAK | SYN | ETB | CAN |	EM | SUB | ESC | FS | GS | RS | US | SP | DEL
    cntrl	→	ascLarge | @ | [ | \ | ] | ^ | _
    gap	→	\ whitechar {whitechar} \

这里比较奇葩的东西是**gap**, 他的作用其实就是逻辑行继续(不知道用什么词表达), 当一行的字符太多的时候我们在c语言中往往会用**\\**来另起一行,而haskell则是用两个反斜杠和当中的空格表达这个意图.
  
  
Layout  
====  
这个也是和其他语言相比比较奇怪的地方, Haskell既支持\{, \}, ; 等的语句和作用域的声明, 又支持类似python利用缩进表达作用域的声明.Layout指的就是python的缩进方式.  
  
当编译器碰到where, let, do, or of等关键字的时候,如果没有\{字符, 那么自动采用layout的模式解析, 他会先在这些关键字之后插入一个\{.  
如果后续的lexeme缩进更多, 那么不做任何处理.  
如果后续的lexeme缩进是一样的, 那么会插入一个字符**;**.
如果后续的lexeme缩进的少了, 那么会插入一个**\}**.  
当然如果语义上已经表示lexeme的结束,那么**\}**就会被插入.  
  
    .... where  
    f :: Num a => a -> a
    f1 :: Num a => a -> a

就会被翻译成以下的代码:

    .... where  
    {  
      f :: Num a => a -> a;
      f1 :: Num a => a -> a;
    }
