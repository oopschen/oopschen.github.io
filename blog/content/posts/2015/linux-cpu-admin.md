---
title: CPU在linux下的调试 
tags:
    - cpu
    - linux
    - cpupower
date: '2015-12-04 21:21:15'
draft: false
alias:
    - /article/2015-12-04-linux-cpu-admin.html
categories:
    - TECH 
---

Window用多了,会对操作系统的一些基础知识有所淡忘.比如这期说的CPU Governor和CPU Frequency.最近误打误撞发现linux下需要对cpu做一些特殊的设置,才能使得cpu发挥最大的效能.

先介绍一个工具--**CPUPower**, CPUPower是linux下展示和设置cpu相关属性的工具.

## 实验机器

cpu: i5-480m
笔记本: thinkpad x201 nn5, 2011年款

## 应用cpupower
```Bash
  cpupower frequency-info  
```
会看到如下的提示:

> analyzing CPU 0:
  driver: acpi-cpufreq  
  CPUs which run at the same hardware frequency: 0  
  CPUs which need to have their frequency coordinated by software: 0  
  maximum transition latency: 10.0 us.  
  hardware limits: 1.20 GHz - 2.67 GHz  
  available frequency steps: 2.67 GHz, 2.67 GHz, 2.53 GHz, 2.40 GHz, 2.27 GHz, 2.13 GHz, 2.00 GHz, 1.87 GHz, 1.73 GHz, 1.60 GHz, 1.47 GHz, 1.33 GHz, 1.20 GHz  
  available cpufreq governors: userspace, ondemand, performance  
  current policy: frequency should be within 1.20 GHz and 2.67 GHz.  
                  The governor "performance" may decide which speed to use  
                  within this range.  
  current CPU frequency is 2.67 GHz (asserted by call to hardware).  
  boost state support:  
    Supported: yes  
    Active: yes  
    2200 MHz max turbo 2 active cores  
    2200 MHz max turbo 1 active cores  

从上面的输出结果可以看出cpu使用的Governor是**performance**, 当前cpu频率是2.67GHz. CPU可用的Governor有userspace, ondemand, performance, cpu可用的频率有2.67 GHz, 2.67 GHz, 2.53 GHz, 2.40 GHz, 2.27 GHz, 2.13 GHz, 2.00 GHz, 1.87 GHz, 1.73 GHz, 1.60 GHz, 1.47 GHz, 1.33 GHz, 1.20 GHz.


## CPU Governor

<table>
  <tr>
    <th>Governor</th>
    <th>说明</th>
  </tr>

  <tr>
    <td>performance</td>
    <td>使用scaling_min_freq和scaling_max_freq之间最高的频率</td>
  </tr>

  <tr>
    <td>ondemand</td>
    <td>根据当前cpu的繁忙程度调整cpu的频率</td>
  </tr>

  <tr>
    <td>userspace</td>
    <td>允许uid为root的用户设置cpu频率</td>
  </tr>
</table>

### 设置Governor
```Bash
    cpupower -c all frequency-set --governor performance
```
使用如上命令设置cpu governor为performance

### 设置频率
```Bash
    cpupower -c all frequency-set  -f 1.33GHz
```
使用如上命令设置cpu的频率为1.33GHz


## 其他
使用过程中可能会遇到一个问题,当笔记本电脑没有接电池只接AC的时候,linux默认会使用最低频率.如想突破此限制,可以在内核启动参数中添加如下参数:
```Bash
    processor.ignore_ppc=1 
```
此参数会忽略bios的限制.
