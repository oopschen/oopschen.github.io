---
layout: post
title: Nginx - CPU Cacheline 深思
tags: nginx,cache, cpu cacheline
date: 2013-09-01 19:38:24
udate: 2013-09-01 19:38:24
category: 技术
---
  
[cpucachearticle]: http://www.akkadia.org/drepper/cpumemory.pdf "原作"

在nginx的内存管理,我们会看到*ngx_align_ptr*这样的代码,从命名上来看是对指针地址的对齐操作。为什么要这么做呢？不是增加负担么？带着这样的问题,我们来看看CPU cache这个很有深度的问题。这篇博客是对[drepper][cpucachearticle]的理解和消化,有英文阅读能力的可以直接参考原文,跳过此博客。（PS：人家2007年写的,惭愧惭愧)
  
#### 内存硬件操作
这里的内存只是对同步的DRAM进行表述,对于其他的内存类型不适用。  
内存的所有操作都是由内存控制器完成,而当下内存采用行列模式,管理硬件内存地址。也就是说,当内存控制器读取或写入数据的时候,会有3步操作:    
1. precharge, 对内存充电操作  
2. RAS, 对行的选择  
3. CAS, 对列的选择   
  
最后才能开始读取或写入这个单元的数据, 然而这几个操作相对cpu的运行速度是很慢很慢的。所以出于充分利用cpu的目的,硬件发展中在cpu中加入了L1,L2,L3的缓存。每级缓存的访问速度是递减的,而容量是递增的,他们的访问速度都是内存的10倍以上。这样CPU不用等待缓慢的内存数据,而直接从高速的缓存中取。也就是说缓存的命中率决定CPU的效率。同时,对内存的读取和写入也不视一个字节一个字节写入,而是一串字节,我们通常称为**cache line**。这样的设计是基于相邻的东西更有可能被使用的原则,这样也就提高了CPU的利用率。  
  
#### Cache line  
首先我们来看看Cache line的结构：  
1. tag,用于区分不同内存地址的标签  
2. set,用于在tag中选择不同的集合  
3. offseet, 用于一个cache line中开始的位置  
  
如上面说内存每访问一个地址都会一并把cache line大小的数据从ram中读取到缓存中。那么,当cpu读取数据的时候首先会从缓存中取,而这个取的速度必须很快,不然就失去了缓存的意义。因此,缓存的大小都很小,这也是出于对速度的要求,因为对大量的缓存比对需要很多时间。  
这个时候人们总会用索引的方式,加快比对,这也就是上述结构的意义。CPU用set过滤出一小部分的地址,然后用offset和tag比对是否为请求的数据。  
通过cache line的实现,CPU实现了预提取数据的功能。当然如果那个原则被打破,这样的设计也是低效的。
  
#### 实践  
理论虽如此,我们来看看实际代码表现如何？  
##### cache line大小  
首先要解决的问题就是获取CPU cache line的大小。我们以linux为例：    

    cat /sys/devices/system/cpu/cpu0/cache/index0/coherency_line_size   

这个文件记录了CPU的cache line大小,单位是字节。这个文件的目录下还存在着一些其他文件  
> coherency_line_size  
> level  
> number_of_sets  
> physical_line_partition  
> shared_cpu_list  
> shared_cpu_map  
> size  
> type  
> ways_of_associativity  
这些文件分别说明了缓存的类型,等级,几路set和共享缓存的CPU等等信息
  
##### 代码论证  
既然缓存只是提高了CPU获取速度的速度,那么我们可以设计如下的代码来检验这个理论。  
1. CPU按字节对内存进行访问  
2. 不同的代码分配到不同的CPU核上去,减少系统调度带来的干扰   
3. 对比组为缓存对齐的指针和随机的指针  
  
##### 缓存对齐的代码  

    #define _GNU_SOURCE
    #include <sched.h>

    #include <stdlib.h>
    #include <stdint.h>
    #define ngx_align_ptr(p, a)                                                   \
        (u_char *) (((uintptr_t) (p) + ((uintptr_t) a - 1)) & ~((uintptr_t) a - 1))
    #define CACHELINE_SIZE_BYTES 64
    // 10M
    #define TOTOAL_SIZE_BYTES 10485760

    int main() {
      cpu_set_t cpuset;
      CPU_ZERO(&cpuset);
      CPU_SET(0, &cpuset);
      sched_setaffinity(0, sizeof(cpu_set_t), &cpuset);

      // malloc ptr
      uint8_t * ptr, * alignedPtr;
      uint32_t i = 0;
      int ret = 0;
      uint32_t size = (CACHELINE_SIZE_BYTES + TOTOAL_SIZE_BYTES) / sizeof(uint8_t),
               loopSize = TOTOAL_SIZE_BYTES / sizeof(uint8_t);
      ptr = calloc(size, sizeof(uint8_t));
      if (!ptr) {
        return 1;
      }

      // align ptr
      alignedPtr = ngx_align_ptr(ptr, CACHELINE_SIZE_BYTES);

      // loop till end
      for (; i<loopSize - 1; i++) {
        ret += alignedPtr[i];
      }
      free(ptr);
      return ret;
    }
  
  
##### 随机的指针  

    #define _GNU_SOURCE
    #include <sched.h>

    #include <stdlib.h>
    #include <stdint.h>
    #define ngx_align_ptr(p, a)                                                   \
      (u_char *) (((uintptr_t) (p) + ((uintptr_t) a - 1)) & ~((uintptr_t) a - 1))
    #define CACHELINE_SIZE_BYTES 64
    // 10M
    #define TOTOAL_SIZE_BYTES 10485760

    int main() {
      cpu_set_t cpuset;
      CPU_ZERO(&cpuset);
      CPU_SET(1, &cpuset);
      sched_setaffinity(0, sizeof(cpu_set_t), &cpuset);

      // malloc ptr
      uint8_t * ptr, * alignedPtr;
      uint32_t i = 0;
      int ret = 0;
      uint32_t size = (CACHELINE_SIZE_BYTES + TOTOAL_SIZE_BYTES) / sizeof(uint8_t),
               loopSize = TOTOAL_SIZE_BYTES / sizeof(uint8_t);
      ptr = calloc(size, sizeof(uint8_t));
      if (!ptr) {
        return 1;
      }

      // align ptr
      alignedPtr = ptr;

      // loop till end
      for (; i<loopSize - 1; i++) {
        ret += alignedPtr[i];
      }
      free(ptr);
      return ret;
    }
  
##### 运行结果  
我们用如下命令编译:  

    clang -Wall -O2 xxx.c -o xxx

这里我们不用优化,因为优化会将循环拉取的代码简化,达不到实验效果。最终我们用**time -p**检测效率,缓存对齐的代码快了一倍。这就是效率的提升。  
  
#### 总结  
通过上面理论的理解和实验的结果,我们可以在编程的时候做如下考虑：  
1. 数据类型在设计的时候,可以和cache line对齐  
2. 访问数据类型的时候,按定义的顺序访问,以减少不必要的缓存不命中  
3. 对遍历的情景,我们可以采用这种方式,提高效率  
  
当然计算机的世界没有万金油,这种方式并不适合觉多多数的场景,memcache就没有采用这种方式。个人猜想大概是因为,memcache的场景都是离散随机的,并不会因为cache line而提升效率,反而会因为这种方式带来的内存碎片降低效果。  
