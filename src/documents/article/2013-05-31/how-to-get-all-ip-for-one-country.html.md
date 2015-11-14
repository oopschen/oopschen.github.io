---
layout: post
title: 如何获取某个国家的ip段分配,以及ip所对应的服务商
tags: ip段,ip拥有者,apnic, 国内ip地址库,IANA
udate: '2013-07-26 14:29:00'
date: '2013-05-31 16:45:00'
category: 技术
---
[IANAwebsite]: http://www.iana.org/ "IANA Website"

[APNICweb]: http://www.apnic.net/ "APNIC Website"
[AFRINICweb]: http://afrinic.net/ "AFRINIC Website"
[ARINweb]: http://arin.net/ "ARIN Website"
[LACNICWeb]: http://lacnic.net/ "LACNIC Website"
[RIPEweb]: http://ripe.net/ "RIPE NCC Website"

[iso3166]: http://www.iso.org/iso/home/standards/country_codes/iso-3166-1_decoding_table.htm "ISO-3166 Country Code"
[APNICformat]: http://www.apnic.net/publications/media-library/documents/resource-guidelines/rir-statistics-exchange-format#Format "APNIC IP ALLOC FORMAT"
[APNICwhois]: http://www.apnic.net/apnic-info/whois_search/using-whois "APNIC WHOIS"
[apnic_file]: http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest "APNIC Latest IP"
[rfc3921]: http://www.ietf.org/rfc/rfc3912.txt "RFC 3921"
[apnicIPV4]: /file/apnic.ipv4.tar.xz "APNIC IPV4库"

互联网在最初的时候只是一个局域网,各个国家的局域网连接起来后就变成了当今的局域网。所谓ip,就是分配给每个上网设备的一个地址,像家庭地址一样。而这个工作不可能由一个组织具体到每个设备,这样既消耗资源,又不高效。因此,一个名为[IANA][IANAwebsite],的组织负责统筹安排数字的分配（包含ip地址,端口地址,域名等等）,当然具体执行的时候,会分配到各个国家地方的办事处。而亚洲的办事处称为[APNIC][APNICweb]。说了这么多,好像没说重点,这篇博客主要记录如何获取某个国家的ip段,以及如何过滤出某些运营商的ip段。  

#### 世界IP办事处  
世界上的IP办事处总共分为以下5个,每个办事处还有下属机构。
[APNIC][APNICweb]: 是亚太地区的总办事处,下属还有各个国家的。
[AFRINIC][AFRINICweb]: 是非洲的总办事处,下属还有各个国家的。
[ARIN][ARINweb]: 是美洲的总办事处,下属还有各个国家的。
[LACNIC][LACNICweb]: 是拉丁美州的总办事处,下属还有各个国家的。
[RIPE NCC][RIPEweb]: 是欧洲和部分中亚的总办事处,下属还有各个国家的。
具体有哪些国家可以点击链接去各个网站查看明细。


#### 获取某个国家的ip段
在这之前,我们先了解下什么是**Country Code(CC)**, CC是国家代码的简称。我们通常可以在域名后看到,比如*www.google.com.hk*就代表google在香港的服务,而*wwww.google.com.sg*则是新加坡的服务,后面我们将用他来过滤ip段。[更多的CC可以参考这里][iso3166]  
Apnic负责亚洲地区的ip分配,而所有ip信息是公开的,具体参考文件[Lastes IP Allocation][apnic_file], 下面我们简单介绍下apnic的的[格式][APNICformat]：  
  
###### 备注行
**\#**在文件中表示备注,可以正常忽略,当然也有一些有用的信息,比如文档地址在哪里等
  
##### 文件头行
样例：  
> 2|apnic|20130531|29927|19850701|20130530|+1000
格式:
> version|registry|serial|records|startdate|enddate|UTCoffset
  
1. version, 表示当前的版本,目前是2
2. registry, 办事处简称,可以是afrinic, apnic, arin,iana, lacnic, ripencc其中的一个
3. serial, 可以理解成文件的id
4. records, 文件有多少条记录,不包括空行,文件头行,备注行以及概要行
5. startdate, 开始的日期,格式为yyyymmdd
6. enddate, 结束日期, 格式如上
7. UTCoffset, UTC中的距离

##### 概要行
样例：  
> apnic|*|asn|*|5214|summary
格式：   
> registry|*|type|*|count|summary
  
1. registry, 同上
2. \*,保留字段
3. type, 可以是asn,ipv4,ipv6中的一个, asn, 全称Autonomous System (AS) Numbers), 可以理解成办事处的id号
4. count, type指定类型的记录数,比如type这列为ipv4,那count列表是文件中ipv4的记录数
5. summary, 就是字符串"summary", 为了和记录行区别
  
##### 记录行
样例：  
> apnic|CN|ipv4|1.0.1.0|256|20110414|allocated
格式：
> registry|cc|type|start|value|date|status\[|extensions...\]
  
1. registry, 同上
2. cc, 上面将的CC
3. type, 同上
4. start,开始值
5. value,从start开始有几个数值
6. date, 记录被确定的日期,格式和startdate相同
7. status, 可以是allocated或者assign,至于这两者的区别就是allocated一定是在使用中的,而assign可以是预先保留,未使用
8. extensions, 额外的信息,但是必须用**|**分割
  
到这里我们就应该知道如何解析这个文件从而获取国内的ip了, **文章结尾附上脚本获取apnic的指定ip**  
  
  
#### 查询每个ip段的服务商
上面我们介绍了如何去获得指定ip段,但是这些ip段又会再分配给不同的运营商使用,比如电信,联通,移动以及各高校的固定ip。这些情形APNIC是不会知道的,也不关心,那么我们如何去解析呢？  
  
这个时候我们需要用到whois, whois主要是查询[RFC3921][rfc3921]中的对象,whosi通过建立tcp链接,遵循request和response的设计,以文本的格式传递信息,当然只允许ASCII。但是我查了很久,没有一个标准的whois协议,可能是各个办事处自己定制的。啥历史原因就不得而知了。其实说的更加透彻的话,whois是建立在数据库上的应用,每次的whois查询都是对办事处数据库的访问。  
下面是一个whois 1.0.1.0的例子:  
> % \[whois.apnic.net node-1\]  
> % Whois data copyright terms    http://www.apnic.net/db/dbcopyright.html  
>   
> inetnum:        1.0.1.0 - 1.0.1.255  
> netname:        CHINANET-FJ  
> descr:          CHINANET FUJIAN PROVINCE NETWORK  
> descr:          China Telecom  
> descr:          No.31,jingrong street  
> descr:          Beijing 100032  
> country:        CN  
> admin-c:        CA67-AP  
> tech-c:         CA67-AP  
> status:         ALLOCATED PORTABLE  
> notify:         fjnic@fjdcb.fz.fj.cn  
> remarks:        service provider  
> changed:        hm-changed@apnic.net 20110414  
> mnt-by:         APNIC-HM  
> mnt-lower:      MAINT-CHINANET-FJ  
> mnt-irt:        IRT-CHINANET-CN  
> source:         APNIC   
>   
> role:           CHINANETFJ IP ADMIN  
> address:        7,East Street,Fuzhou,Fujian,PRC  
> country:        CN  
> phone:          +86-591-83309761  
> fax-no:         +86-591-83371954  
> e-mail:         fjnic@fjdcb.fz.fj.cn  
> remarks:        send spam reports  and abuse reports  
> remarks:        to abuse@fjdcb.fz.fj.cn  
> remarks:        Please include detailed information and  
> remarks:        times in UTC  
> admin-c:        FH71-AP  
> tech-c:         FH71-AP  
> nic-hdl:        CA67-AP  
> remarks:        www.fjtelecom.com  
> notify:         fjnic@fjdcb.fz.fj.cn  
> mnt-by:         MAINT-CHINANET-FJ  
> changed:        fjnic@fjdcb.fz.fj.cn 20100108  
> source:         APNIC  
> changed:        hm-changed@apnic.net 20111114  
  
从上面我们不难看出是电信福建\(CHINANET-FJ\)的网络.  
  
#### WHOIS 进阶  
从上面的例子可以看到我们查询出的结果包含了很多不必要的信息,比如什么角色在维护。  
我们可以通过whois的参数来限制查询的范围。以下例子仅限于APNIC。
我们来看一下例子：  
{% highlight bash %}
whois -h whois.apnic.net -T inetnum -r  1.0.1.0
{% endhighlight %}
上面的例子我们可以看到*-T*, *-h*, *-r*参数：  
1. -T, 制定我们需要查询的对象的类型,如果想要其他类型可以查询[这里的教程][APNICwhois]  
2. -h, 指定查询的服务器,如果不指定,whois首先会去另一台配置的服务器查询后面跟着的查询条件是在哪台机子上,最后在从那台机子上查询信息  
3. -r, 不进行关联查询,比如一个ip地址对应一个管理人员,不加-r参数的话,会连带管理人员的信息也查询出来

###### -t 
帮助命令,whois请求whois server查询whois命令的格式。  

#### APNIC查询结果  
这里我用脚本查询了APNIC管理下的所有IP地址的运营商,供大家参考,[APNIC IPV4 IP库][apnicIPV4]\(更新时间：{{ page.udate }}\)  
###### 压缩包目录格式：  
国家代码（iso3166 的两个字符码）/运营商英文
###### 文件格式
起始IP-结束IP  
两头都包含
