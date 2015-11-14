---
layout: post
title: Mysql使用index基本原则
tags: mysql, index, cluster index, secondary index
date: '2014-07-23 09:24:37'
udate: '2014-07-23 09:24:37'
category: 技术
---
  
用了蛮久的mysql,竟然对如何优化index还没有掌握,今天闲下来看看这块东西,然后总结以下.这里所表述的mysql指的是innodb的engine.  

### mysql index分类  
Mysql的index分为cluster index和secondary index, 可以翻译为聚簇索引和二级索引.所谓的聚簇索引是指主键栏作为索引值的索引, 而所有非聚簇索引则是二级索引.  
  
#### cluster index  
Mysql根据如下规则建立聚簇索引:  
  
- 如果有定义主键, 则使用主键建立索引  
- 如果没有定义主键, 选取第一个*UNIQUE*的栏建立索引
- 如果以上两个条件均不满足, 则mysql默认建立一个隐藏的rowid作为建立索引的依据  

#### secondary index  
二级索引是建立在cluster index之上的索引, 它包含建立自身索引的列和主键, 因此, 主键过大会造成二级索引过大, 最终导致磁盘占用量变大.  
Myql如果选择使用二级索引, 那么它先根据二级索引查找主键, 由于主键和数据在同一个页上, 从而加快了数据的查找和比较.  
  
  
### mysql如何使用index  
Mysql首先根据查询语句做优化, 如果table的数据量很小(比如几条数据),那么mysql会选择遍历整个表.如果数据量很大, 它优先选择根据索引过滤后数据量较小的索引.那么我们建立索引索引的时候应该遵循哪些规则?  
  
#### 尽可能的覆盖查询语句中的查询条件
由于mysql可以选取部分index的列作为索引条件,因此如下两个查询条件可以共用同一个索引但是不要忘记, 增加列意味着容量的增加.  

    select * from db.tbl where c1 = 1 and c2 = 2;  
    
和  
  
    select * from db.tbl where c1 = 1;  
    
所以语句  
  
    create index inx_c1_c2 on db.tbl(c1, c2);  
    
  
### 工具  
理论上的理解还不够, 现实的问题需要显示来解决, 所以在每次使用sql前, 可以用explain的看下使用的所以是不是我们所期望的, explain只能用于select语句.非select语句,比如update和delete, 我们可以把where语句后的条件放入select进行explain.  
