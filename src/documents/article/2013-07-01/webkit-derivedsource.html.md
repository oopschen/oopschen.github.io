---
layout: post
title: Dig Webcore - 代码生成机制
tags: webkit，webcore，代码生成，idl，make-generated-sources.sh
date: 2013-07-01 17:29:13
udate: 2013-07-01 17:29:13
category: 技术
---
[gperf]: http://www.gnu.org/software/gperf/manual/gperf.html#Top "GPERF DOC"
[idl]:http://www.w3.org/TR/WebIDL/ "IDL W3C"
  
一直对webkit神秘的面纱抱有极大的好奇心，但是苦于一直没时间好好的对其进行研究。最近终于的空，开始对webkit进行探索并做一些摘记。  
在刚开始的时候，由于对google的偏爱，所以选择chromium进行探究，但探究了2天始终不太有头绪，感觉chromium的代码还是太复杂，因为它对渲染层的代码完全是对webkit core的扩展，而其大部分的代码都是界面和多线程架构的，最后决定还是对Webkit的代码直接进行研究。  
  
#### 代码生成  
在webkit源代码的目录中，我们能看到很多的IDL文件，他们到底是干什么用的呢？[IDL][idl], 全称Interface Description Language，也就是说它是接口的定义文件。他将编程语言与接口定义分离，从而将语言的定义和实现分离。IDL的优势在于可以将独立的语言定义用代码的方式生成目标语言的接口，所以webkit采用IDL生成js相关的接口。  
webkit的代码生成主要靠*make-generated-sources.sh*脚本，这个脚本根据WebCore下的子目录中的idl文件和后缀为in的配置文件生成相关的.h和.cpp文件。而生成的代码则在*DerivedSources/WebCore*下。

#### GPERF
[GPERF][gperf]是GNU的一款hash函数生成工具，他能根据配置文件将key集合固定的情况下用最合理的方式生成目标语言的代码，而这些代码的功能就是对这些固定key的快读访问。这么做的目的是加快hash的运算，因为静态的代码远比运行时期动态计算hash值快。Webkit在css属性名称和css属性值上使用gperf生成代码。
  
##### GPERF列表  
1. CSSPropertyNames\.{h,cpp}  
2. CSSValueKeywords\.{h,cpp}  
3. ColorData.cpp
以上文件都是用gperf生成的hash代码，方面其他代码用key查询他的value值。
  
#### IDL  
IDL相关的代码生成脚本在*bindings/scripts*下，而IDL文件分布在各个WebCore的子文件夹下，比如dom/\*.idl。处理IDL文件分为两步：  

##### 预处理
IDL的预处理，preprocess-idls.pl 脚本负责将环境变量和in文件生成IDL的依赖关系。而这些依赖关系的表达方式可以从脚本文件里的注释说明：  

>  Outputs the dependency.
>  The format of a supplemental dependency file:
> 
>  DOMWindow.idl P.idl Q.idl R.idl
>  Document.idl S.idl
>  Event.idl
>  ...
> 
>  The above indicates that DOMWindow.idl is supplemented by P.idl, Q.idl and R.idl,
>  Document.idl is supplemented by S.idl, and Event.idl is supplemented by no IDLs.
>  The IDL that supplements another IDL (e.g. P.idl) never appears in the dependency file.
  
举例说明：  
比如我们有如下的关系  

    DOMWindow.idl P.idl Q.idl R.idl

这个例子表明DOMWindow.idl需要依赖P\.idl, Q\.idl和R\.idl这几个文件
  
##### 生成代码  
generate-bindings\.pl 脚本则将生成的依赖关系，html的属性文件（IDLAttributes\.txt）以及多个idl文件合成cpp和h文件，也就是接口。而这些文件都是以JSxxx\.h的文件名形式存在于DerivedSources/Webcore下，其中xxx是指idl的原始文件名。
  
#### 其他  
除了上述两种方式之外，make-generated-sources.sh脚本还利用python,perl脚本以及in配置文件生成特殊的cpp和h文件。具体可参考  
1. inspector/xxd.pl
2. html/parser/create-html-entity-table(python 脚本)
3. css/makegrammar.pl  
4. css/make-css-file-arrays.pl  
5. dom/make_names.pl  
6. dom/make_event_factory.pl  
7. page/make_settings.pl   
8. inspector/generate-inspector-protocol-version(python 脚本)
  
#### 总结  
看了这么多代码生成的脚本，webkit大部分还是利用perl脚本，但其中也参杂少量的python脚本，可能也是开源的缘故造成的吧。
